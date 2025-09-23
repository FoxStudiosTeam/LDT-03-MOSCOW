use bb8::PooledConnection;
use bb8_redis::{RedisConnectionManager, redis::{AsyncCommands, RedisError}};
use chrono::Utc;
use tracing::info;
use uuid::Uuid;

use crate::{AppErr, CFG};
use auth_jwt::prelude::RefreshTokenRecord;



#[derive(Clone)]
pub struct RedisConn{
    pub pool: bb8::Pool<RedisConnectionManager>
}

impl RedisConn {
    pub async fn new(conn_string: String) -> Self {
        let redis_client = RedisConnectionManager::new(conn_string).expect("Can't connect to redis!");
        RedisConn{
            pool: bb8::Pool::builder().build(redis_client).await.expect("Can't create pool for redis!")
        }
    }
}


const REFRESH_TOKEN_PREFIX : &str = "RTID";
const USER_TOKEN_PAIR_PREFIX : &str = "UTPP";

fn rtid_to_key(rtid: &Uuid) -> String{
    format!("{}::{}", REFRESH_TOKEN_PREFIX, rtid.simple())
}   

fn user_to_key(user: &Uuid) -> String{
    format!("{}::{}", USER_TOKEN_PAIR_PREFIX, user.simple())
}

pub(crate) trait RedisTokens {
    fn set_refresh(&self, record: RefreshTokenRecord) -> impl std::future::Future<Output = Result<(), AppErr>> + Send;
    #[allow(unused)]
    fn get_refresh(&self, rtid: String) -> impl std::future::Future<Output = Result<Option<RefreshTokenRecord>, AppErr>> + Send;
    fn rm_refresh(&self, rtid: &Uuid) -> impl std::future::Future<Output = Result<(), AppErr>> + Send;
    fn rm_all_refresh(&self, user: &Uuid) -> impl std::future::Future<Output = Result<(), AppErr>> + Send;
    fn pop_refresh(&self, rtid: &Uuid) -> impl std::future::Future<Output = Result<Option<RefreshTokenRecord>, AppErr>> + Send;
    fn get_refresh_conn(&self, rtid: String, conn : &mut PooledConnection<'_, RedisConnectionManager>) -> impl std::future::Future<Output = Result<Option<RefreshTokenRecord>, AppErr>> + Send;
}


impl RedisTokens for RedisConn {
    async fn set_refresh(&self, record: RefreshTokenRecord) -> Result<(), AppErr>
    {
        let mut conn = self.pool.get().await?;
        let now = Utc::now().timestamp();
        let user_key = user_to_key(&record.uuid);
        let valid_values: Vec<String> = conn.zrangebyscore(user_key.clone(), now, "+inf").await?;
        if valid_values.len() >= CFG.MAX_LIVE_SESSIONS { // ERASE ALL SESSIONS
            for rtid_key in valid_values {
                let _: Result<(), RedisError> = conn.del(rtid_key).await;
            }
            let _: () = conn.zrembyscore(user_key.clone(), "-inf", "+inf").await?;
        } else { // ERASE OUTDATED SESSIONS
            let _: () = conn.zrembyscore(user_key.clone(), "-inf", now).await?;
        }
        let _: () = conn.zadd(user_key.clone(), rtid_to_key(&record.rtid), now + CFG.REFRESH_TOKEN_LIFETIME as i64).await?;
        let _: () = conn.set_ex(rtid_to_key(&record.rtid), serde_json::to_string(&record)?, CFG.REFRESH_TOKEN_LIFETIME).await?;
        Ok(())
    }

    async fn get_refresh(&self, rtid: String) -> Result<Option<RefreshTokenRecord>, AppErr>
    {
        let mut conn = self.pool.get().await?;
        self.get_refresh_conn(rtid, &mut conn).await
    }

    async fn get_refresh_conn(&self, rtid: String, conn : &mut PooledConnection<'_, RedisConnectionManager>) -> Result<Option<RefreshTokenRecord>, AppErr>
    {
        let s : Option<String> = conn.get(rtid).await?;
        let Some(s) = s else {return Ok(None)};
        let v = serde_json::from_str(s.as_str())?;
        Ok(v)
    }

    async fn rm_refresh(&self, rtid: &Uuid) -> Result<(), AppErr> {
        let rtid_key = rtid_to_key(rtid);
        let mut conn = self.pool.get().await?;
        if let Ok(Some(record)) = self.get_refresh_conn(rtid_key.clone(), &mut conn).await {
            let _: Result<(), RedisError> = conn.zrem(user_to_key(&record.uuid), rtid_key.clone()).await;
        }
        let _: Result<(), RedisError> = conn.del(rtid_key).await;
        Ok(())
    }

    async fn rm_all_refresh(&self, user: &Uuid) -> Result<(), AppErr> {
        let mut conn = self.pool.get().await?;
        info!("Removing all refresh tokens!");
        let user_key = user_to_key(user);
        let keys: Vec<String> = conn.zrangebyscore(user_key.clone(), "-inf", "+inf").await?;
        for rtid_key in keys {
            let _: Result<(), RedisError> = conn.del(rtid_key).await;
        }
        Ok(())
    }

    async fn pop_refresh(&self, rtid: &Uuid) -> Result<Option<RefreshTokenRecord>, AppErr>
    {
        info!("Popping refresh for {rtid}");
        let rtid_key = rtid_to_key(rtid);
        let mut conn = self.pool.get().await?;
        if let Ok(record) = self.get_refresh_conn(rtid_key.clone(), &mut conn).await {
            let Some(record) = record else {return Ok(None)};
            info!("Record found!");
            let _: Result<(), RedisError> = conn.zrem(user_to_key(&record.uuid), rtid_key.clone()).await;
            let _: Result<(), RedisError> = conn.del(rtid_key).await;
            return Ok(Some(record))
        }
        // let _: Result<(), RedisError> = conn.del(rtid_key);
        info!("No record!");
        Ok(None)
    }
}