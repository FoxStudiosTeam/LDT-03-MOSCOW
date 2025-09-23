use chrono::Utc;
use orm::prelude::*;
use schema::prelude::*;
use sqlx::Pool;
use uuid::Uuid;


use crate::helpers::password::{hash_password, verify_password};
use crate::{AppDB, AppErr, IntoAppErr};

pub(crate) trait IOrm {
    async fn create_org(&self, name: &String) -> Result<Option<Orgs>, AppErr>;
    async fn delete_org(&self, uuid: Uuid) -> Result<bool, AppErr>;
    async fn get_orgs(&self) -> Result<Vec<Orgs>, AppErr>;
    async fn create_user(&self, 
        login: &String, 
        password: &String, 
        email: String,
        fcs: String,
        role: String,
        org: Uuid,
    ) -> Result<Option<Users>, AppErr>;
    async fn verify_user(&self, login: &String, password: &String) -> Result<Option<Users>, AppErr>;
    async fn delete_user(&self, user: ActiveUsers) -> Result<Option<Users>, AppErr>;
    async fn insert_update_user(&self, user: ActiveUsers) -> Result<Option<Users>, AppErr>;
}

impl IOrm for Orm<Pool<AppDB>>
where 
{
    // todo: returns ok even if its already deleted. ignore
    async fn delete_org(&self, uuid: Uuid) -> Result<bool, AppErr> {
        self
            .orgs()
            .save(ActiveOrgs { 
                uuid: Set(uuid), 
                is_deleted: Set(true),
                ..Default::default() 
            }, Update)
            .await.into_app_err().map(|v|v.is_some())
    }

    async fn get_orgs(&self) -> Result<Vec<Orgs>, AppErr> {
        self.orgs().select("WHERE is_deleted = false").fetch().await.into_app_err()
    }
    
    async fn create_org(&self, name: &String) -> Result<Option<Orgs>, AppErr> {
        self.orgs()
            .save(ActiveOrgs {
                name: Set(name.to_string()),
                ..Default::default()
        }, Insert).await.into_app_err()
    }
    async fn create_user(
        &self, 
        login: &String, 
        password: &String, 
        email: String,
        fcs: String,
        role: String,
        org: Uuid,
    ) -> Result<Option<Users>, AppErr> {
        tracing::info!("Creating user: {} with org {}", login, org);
        let created = sqlx::query_as::<_, Users>(r#"INSERT INTO auth.users (uuid, login, email, fcs, password, role, org, is_deleted, updated_at, created_at)
            SELECT gen_random_uuid(), $1, $2, $3, $4, $5, $6, false, now(), now()
            WHERE NOT EXISTS (
                SELECT 1
                FROM auth.users u
                WHERE u.is_deleted = false
                AND (u.login = $1 OR u.email = $2)
            ) RETURNING *;"#)
            .bind(login).bind(email).bind(fcs).bind(hash_password(password)?).bind(role).bind(org)
            .fetch_optional(self.get_executor()).await?;
        if created.is_none() {
            tracing::info!("User exists: {}", login);
        } else {
            tracing::info!("Created user: {}", login);
        }
        Ok(created)
    }

    async fn verify_user(&self, login: &String, password: &String) -> Result<Option<Users>, AppErr> {
        tracing::info!("Verifying password for {}", login);
        let Some(user) = self.users().select("WHERE $1 IN (login, email) AND is_deleted = false").bind(login).fetch().await.into_app_err()?.into_iter().next() else {
            tracing::info!("User not found: {}", login);
            return Ok(None)
        };
        if verify_password(&password, &user.password)? {
            tracing::info!("Password correct for {}", login);
            Ok(Some(user))
        } else {
            tracing::info!("Password wrong for {}", login);
            Ok(None)
        }
    }

    async fn delete_user(&self, mut user: ActiveUsers) -> Result<Option<Users>, AppErr> {
        tracing::info!("Deleting user: {:?}", user.login);
        user.is_deleted = Set(true);
        self.users()
            .save(user, Update).await
            .into_app_err()
            .map(|v|v.into_iter().next())
    }

    async fn insert_update_user(&self, mut user: ActiveUsers) -> Result<Option<Users>, AppErr> {
        tracing::info!("Updating user: {:?}", user.login);
        user.updated_at = Set(Utc::now().naive_utc());
        self.users().save(user, Update).await.into_app_err()
    }
}

