// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl Attachments {
    pub fn into_active(self) -> ActiveAttachments {
        ActiveAttachments {
            original_filename: Set(self.original_filename),
            uuid: Set(self.uuid),
            base_entity_uuid: Set(self.base_entity_uuid),
            file_uuid: Set(self.file_uuid),
            content_type: Set(self.content_type),
        }
    }
}

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "utoipa_gen", derive(utoipa::ToSchema))]
#[derive(Clone, Debug, FromRow)]
pub struct Attachments {
    pub original_filename: String,
    pub uuid: uuid::Uuid,
    pub base_entity_uuid: uuid::Uuid,
    pub file_uuid: uuid::Uuid,
    pub content_type: Option<String>,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveAttachments {
    pub original_filename: Optional<String>,
    pub uuid: Optional<uuid::Uuid>,
    pub base_entity_uuid: Optional<uuid::Uuid>,
    pub file_uuid: Optional<uuid::Uuid>,
    pub content_type: Optional<Option<String>>,
}

impl ActiveAttachments {
    pub fn into_attachments(self) -> Option<Attachments> {
        Some(Attachments {
            original_filename: self.original_filename.into_option()?,
            uuid: self.uuid.into_option()?,
            base_entity_uuid: self.base_entity_uuid.into_option()?,
            file_uuid: self.file_uuid.into_option()?,
            content_type: self.content_type.into_option()?,
        })
    }
}

pub trait OrmAttachments<DB: OrmDB> {
    fn attachments<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveAttachments>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXAttachments<'c, DB: OrmDB> {
    fn attachments(&'c mut self) -> TxSelector<'c, DB, ActiveAttachments>;
}

impl TableSelector for ActiveAttachments {
    const TABLE_NAME: &'static str = "attachments";
    const TABLE_SCHEMA: &'static str = "attachment";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "uuid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "original_filename" => self.original_filename.is_set(),
            "uuid" => self.uuid.is_set(),
            "base_entity_uuid" => self.base_entity_uuid.is_set(),
            "file_uuid" => self.file_uuid.is_set(),
            "content_type" => self.content_type.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "original_filename",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "uuid",
                nullable: false,
                default: Some("gen_random_uuid()"),
                is_unique: false,
                is_primary: true,
            },
            ColumnDef{
                name: "base_entity_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "file_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "content_type",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmAttachments<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn attachments<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveAttachments>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXAttachments<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn attachments(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveAttachments>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveAttachments 
{
    type NonActive = Attachments;
    async fn save<'e,E>(self, exec: E, mode: SaveMode) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Postgres> ,for<'q> <sqlx::Postgres as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Postgres>  {
        match mode {
            Insert => self.insert(exec).await,
            Update => self.update(exec).await,
            Upsert => self.upsert(exec).await
        }
    }

    fn complete_query<'s, 'q, T>(&'s self, mut q: QueryAs<'q, sqlx::Postgres, T, <sqlx::Postgres as sqlx::Database>::Arguments<'q>>)
        -> sqlx::query::QueryAs<'q,sqlx::Postgres,T, <sqlx::Postgres as sqlx::Database>::Arguments<'q> > where 's: 'q {
        if let Set(v) = &self.original_filename {tracing::debug!("Binded original_filename"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.base_entity_uuid {tracing::debug!("Binded base_entity_uuid"); q = q.bind(v);}
        if let Set(v) = &self.file_uuid {tracing::debug!("Binded file_uuid"); q = q.bind(v);}
        if let Set(v) = &self.content_type {tracing::debug!("Binded content_type"); q = q.bind(v);}
        q
    }
    
    async fn insert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Postgres> ,for<'q> <sqlx::Postgres as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Postgres>  {
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::insert_for(&self)?;
        tracing::debug!("Insert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_one(exec)
            .await;
        match r {
            Ok(v) => Ok(Some(v)),
            Err(e) if e.as_database_error()
                .and_then(|d| d.code()) == Some(std::borrow::Cow::Borrowed("23505")) => {
                // 23505 = unique_violation
                Ok(None)
            }
            Err(e) => Err(e.into())
        }
    }
    async fn upsert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Postgres> ,for<'q> <sqlx::Postgres as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Postgres>  {
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::upsert_for(&self)?;
        tracing::debug!("Upsert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    async fn update<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Postgres> ,for<'q> <sqlx::Postgres as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Postgres>  {
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::update_for(&self)?;
        tracing::debug!("Update sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn select_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Postgres>
    {
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::select_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn delete_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Postgres>
    {
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::delete_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    
    async fn count<'e, E>(exec: E) -> Result<i64, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Postgres> {
        use sqlx::Row;
        let sql = <Self as SqlBuilder<sqlx::Postgres>>::count();
        let rec = sqlx::query(&sql)
            .fetch_one(exec)
            .await?.get(0);
        Ok(rec)
    }
}

#[cfg(feature="mysql")]
impl OrmAttachments<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn attachments<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveAttachments>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXAttachments<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn attachments(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveAttachments>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveAttachments 
{
    type NonActive = Attachments;
    async fn save<'e,E>(self, exec: E, mode: SaveMode) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::MySql> ,for<'q> <sqlx::MySql as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::MySql>  {
        match mode {
            Insert => self.insert(exec).await,
            Update => self.update(exec).await,
            Upsert => self.upsert(exec).await
        }
    }

    fn complete_query<'s, 'q, T>(&'s self, mut q: QueryAs<'q, sqlx::MySql, T, <sqlx::MySql as sqlx::Database>::Arguments<'q>>)
        -> sqlx::query::QueryAs<'q,sqlx::MySql,T, <sqlx::MySql as sqlx::Database>::Arguments<'q> > where 's: 'q {
        if let Set(v) = &self.original_filename {tracing::debug!("Binded original_filename"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.base_entity_uuid {tracing::debug!("Binded base_entity_uuid"); q = q.bind(v);}
        if let Set(v) = &self.file_uuid {tracing::debug!("Binded file_uuid"); q = q.bind(v);}
        if let Set(v) = &self.content_type {tracing::debug!("Binded content_type"); q = q.bind(v);}
        q
    }
    
    async fn insert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::MySql> ,for<'q> <sqlx::MySql as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::MySql>  {
        let sql = <Self as SqlBuilder<sqlx::MySql>>::insert_for(&self)?;
        tracing::debug!("Insert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_one(exec)
            .await;
        match r {
            Ok(v) => Ok(Some(v)),
            Err(e) if e.as_database_error()
                .and_then(|d| d.code()) == Some(std::borrow::Cow::Borrowed("23505")) => {
                // 23505 = unique_violation
                Ok(None)
            }
            Err(e) => Err(e.into())
        }
    }
    async fn upsert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::MySql> ,for<'q> <sqlx::MySql as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::MySql>  {
        let sql = <Self as SqlBuilder<sqlx::MySql>>::upsert_for(&self)?;
        tracing::debug!("Upsert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    async fn update<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::MySql> ,for<'q> <sqlx::MySql as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::MySql>  {
        let sql = <Self as SqlBuilder<sqlx::MySql>>::update_for(&self)?;
        tracing::debug!("Update sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn select_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::MySql>
    {
        let sql = <Self as SqlBuilder<sqlx::MySql>>::select_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn delete_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::MySql>
    {
        let sql = <Self as SqlBuilder<sqlx::MySql>>::delete_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    
    async fn count<'e, E>(exec: E) -> Result<i64, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::MySql> {
        use sqlx::Row;
        let sql = <Self as SqlBuilder<sqlx::MySql>>::count();
        let rec = sqlx::query(&sql)
            .fetch_one(exec)
            .await?.get(0);
        Ok(rec)
    }
}

#[cfg(feature="sqlite")]
impl OrmAttachments<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn attachments<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveAttachments>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXAttachments<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn attachments(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveAttachments>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveAttachments 
{
    type NonActive = Attachments;
    async fn save<'e,E>(self, exec: E, mode: SaveMode) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Sqlite> ,for<'q> <sqlx::Sqlite as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Sqlite>  {
        match mode {
            Insert => self.insert(exec).await,
            Update => self.update(exec).await,
            Upsert => self.upsert(exec).await
        }
    }

    fn complete_query<'s, 'q, T>(&'s self, mut q: QueryAs<'q, sqlx::Sqlite, T, <sqlx::Sqlite as sqlx::Database>::Arguments<'q>>)
        -> sqlx::query::QueryAs<'q,sqlx::Sqlite,T, <sqlx::Sqlite as sqlx::Database>::Arguments<'q> > where 's: 'q {
        if let Set(v) = &self.original_filename {tracing::debug!("Binded original_filename"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.base_entity_uuid {tracing::debug!("Binded base_entity_uuid"); q = q.bind(v);}
        if let Set(v) = &self.file_uuid {tracing::debug!("Binded file_uuid"); q = q.bind(v);}
        if let Set(v) = &self.content_type {tracing::debug!("Binded content_type"); q = q.bind(v);}
        q
    }
    
    async fn insert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Sqlite> ,for<'q> <sqlx::Sqlite as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Sqlite>  {
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::insert_for(&self)?;
        tracing::debug!("Insert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_one(exec)
            .await;
        match r {
            Ok(v) => Ok(Some(v)),
            Err(e) if e.as_database_error()
                .and_then(|d| d.code()) == Some(std::borrow::Cow::Borrowed("23505")) => {
                // 23505 = unique_violation
                Ok(None)
            }
            Err(e) => Err(e.into())
        }
    }
    async fn upsert<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Sqlite> ,for<'q> <sqlx::Sqlite as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Sqlite>  {
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::upsert_for(&self)?;
        tracing::debug!("Upsert sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    async fn update<'e,E>(self, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error> 
    where E: Executor<'e, Database = sqlx::Sqlite> ,for<'q> <sqlx::Sqlite as sqlx::Database>::Arguments<'q> :Default+sqlx::IntoArguments<'q, sqlx::Sqlite>  {
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::update_for(&self)?;
        tracing::debug!("Update sql: {}", sql);
        let incomplete = sqlx::query_as::<_, Self::NonActive>(&sql);
        let complete = self.complete_query(incomplete);
        let r = complete
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn select_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Sqlite>
    {
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::select_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }

    async fn delete_by_pk<'e, E>(pk: &Self::TypePK, exec: E) -> Result<Option<Self::NonActive>, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Sqlite>
    {
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::delete_by_pk();
        let r = sqlx::query_as::<_, Self::NonActive>(&sql)
            .bind(pk)
            .fetch_optional(exec)
            .await?;
        Ok(r)
    }
    
    async fn count<'e, E>(exec: E) -> Result<i64, anyhow::Error>
    where
        E: Executor<'e, Database = sqlx::Sqlite> {
        use sqlx::Row;
        let sql = <Self as SqlBuilder<sqlx::Sqlite>>::count();
        let rec = sqlx::query(&sql)
            .fetch_one(exec)
            .await?.get(0);
        Ok(rec)
    }
}
