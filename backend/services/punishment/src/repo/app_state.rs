use axum_extra::extract::CookieJar;
use orm::prelude::*;
use sqlx::*;
use uuid::Uuid;
use crate::{AppErr, helpers::{cookie::TokenCookie, password::hash_password}, repo::{orm::IOrm, redis::{RedisConn, RedisTokens}}};
use auth_jwt::prelude::*;

pub type AppDB = Postgres;


#[derive(Clone)]
pub struct AppState {
    pub orm: Orm<Pool<AppDB>>,
    pub redis: RedisConn
}

impl AppState {
    pub fn new(
        orm: Orm<sqlx::Pool<AppDB>>,
        redis: RedisConn,
    ) -> Self {
        Self {
            orm,
            redis
        }
    }
}

use schema::prelude::*;

impl AppState {
    pub async fn get_orgs(&self) -> Result<Vec<Orgs>, AppErr> {
        tracing::info!("Getting orgs");
        let r = self.orm.get_orgs().await;
        tracing::info!("Result: {:?}", r.as_ref().map(|v| v.len()).ok());
        r
    }
    pub async fn delete_org(&self, uuid: Uuid) -> Result<bool, AppErr> {
        tracing::info!("Deleting org: {}", uuid);
        let r= self.orm.delete_org(uuid).await;
        tracing::info!("Result: {:?}", r.as_ref().map(|v| v.clone()).ok());
        r
    }
    pub async fn create_org(&self, name: &String) -> Result<Option<Uuid>, AppErr> { 
        tracing::info!("Creating org: {}", name);
        let r= self.orm
            .create_org(name).await
            .map(|v| v.map(|v| v.uuid));
        tracing::info!("Result: {:?}", r.as_ref().map(|v| v.clone()).ok());
        r
    }
    pub async fn register_account(
        &self, 
        login: &String, 
        password: &String, 
        email: String,
        fcs: String,
        role: String,
        org: Uuid,
    ) -> Result<Option<Users>, AppErr> {
        let u = self.orm.create_user(login, password, email, fcs, role, org).await?;
        let Some(new_user) = u else {
            return Ok(None)
        };
        Ok(Some(new_user))
    }

    pub async fn login(&self, login: &String, password: &String) -> Result<Option<TokenPair>, AppErr> {
        let u = self.orm.verify_user(login, password).await?;
        let Some(user) = u else { return Ok(None) };
        Ok(Some(self.generate_tokens(user.uuid, &user.role, user.org).await?))
    }

    pub async fn delete_account(&self, login: &String, password: &String) -> Result<bool, AppErr> {
        tracing::info!("Deleting user: {}", login);
        let u = self.orm.verify_user(login, password).await?;
        let Some(u) = u else { return Ok(false) };
        let u = self.orm.delete_user(u.into_active()).await?;
        let Some(u) = u else {return Ok(false)};
        self.redis.rm_all_refresh(&u.uuid).await?;
        tracing::info!("Deleted user: {}", login);
        Ok(true)
    }

    pub async fn change_password(&self, login: &String, old_password: &String, new_password: String) -> Result<bool, AppErr> { 
        let u = self.orm.verify_user(login, old_password).await?;
        let Some(mut user) = u else { return Ok(false) };
        user.password = hash_password(&new_password)?;
        let uuid = user.uuid.clone();
        self.orm.insert_update_user(user.into_active()).await?;
        self.redis.rm_all_refresh(&uuid).await?;
        Ok(true)
    }

    pub async fn generate_tokens(&self, uuid: Uuid, role: &String, org: Uuid) -> Result<TokenPair, AppErr> {
        let rtid = Uuid::new_v4();
        let refresh_record = RefreshTokenRecord {
            rtid,
            org: org.clone(),
            role: role.clone(),
            uuid: uuid.clone()
        };
        self.redis.set_refresh(refresh_record).await?;
        let access_payload = AccessTokenPayload::new(uuid, role.clone(), org, crate::CFG.ACCESS_TOKEN_LIFETIME as i64);
        let access_token = TokenEncoder::encode_access(access_payload)?;
        let refresh_token = rtid.simple().to_string();
        Ok(TokenPair { access_token: AccessTokenResponse::new(access_token, crate::CFG.ACCESS_TOKEN_LIFETIME as i64), refresh_token})
    }

    pub async fn logout(
        &self,
        jar: &mut CookieJar
    ) -> Result<bool, AppErr> {
        let Some(refresh) = jar.pop_refresh() else {return Ok(false)};
        let rtid = Uuid::parse_str(&refresh)?;
        self.redis.rm_refresh(&rtid).await?;
        Ok(true)
    }

    pub async fn refresh_token(
        &self, 
        jar: &mut CookieJar 
    ) -> Result<Option<TokenPair>, AppErr> {
        let Some(refresh) = jar.pop_refresh() else {return Ok(None)};
        let rtid = Uuid::parse_str(&refresh)?;
        let Some(record) = self.redis.pop_refresh(&rtid).await? else {return Ok(None)};
        Ok(Some(self.generate_tokens(record.uuid, &record.role, record.org).await?))
    }
}
