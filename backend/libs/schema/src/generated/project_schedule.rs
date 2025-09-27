// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl ProjectSchedule {
    pub fn into_active(self) -> ActiveProjectSchedule {
        ActiveProjectSchedule {
            start_date: Set(self.start_date),
            uuid: Set(self.uuid),
            end_date: Set(self.end_date),
            project_uuid: Set(self.project_uuid),
            work_uuid: Set(self.work_uuid),
        }
    }
}

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "utoipa_gen", derive(utoipa::ToSchema))]
#[derive(Clone, Debug, FromRow)]
pub struct ProjectSchedule {
    pub start_date: Option<chrono::NaiveDate>,
    pub uuid: uuid::Uuid,
    pub end_date: Option<chrono::NaiveDate>,
    pub project_uuid: uuid::Uuid,
    pub work_uuid: uuid::Uuid,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveProjectSchedule {
    pub start_date: Optional<Option<chrono::NaiveDate>>,
    pub uuid: Optional<uuid::Uuid>,
    pub end_date: Optional<Option<chrono::NaiveDate>>,
    pub project_uuid: Optional<uuid::Uuid>,
    pub work_uuid: Optional<uuid::Uuid>,
}

impl ActiveProjectSchedule {
    pub fn into_project_schedule(self) -> Option<ProjectSchedule> {
        Some(ProjectSchedule {
            start_date: self.start_date.into_option()?,
            uuid: self.uuid.into_option()?,
            end_date: self.end_date.into_option()?,
            project_uuid: self.project_uuid.into_option()?,
            work_uuid: self.work_uuid.into_option()?,
        })
    }
}

pub trait OrmProjectSchedule<DB: OrmDB> {
    fn project_schedule<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveProjectSchedule>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXProjectSchedule<'c, DB: OrmDB> {
    fn project_schedule(&'c mut self) -> TxSelector<'c, DB, ActiveProjectSchedule>;
}

impl TableSelector for ActiveProjectSchedule {
    const TABLE_NAME: &'static str = "project_schedule";
    const TABLE_SCHEMA: &'static str = "journal";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "uuid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "start_date" => self.start_date.is_set(),
            "uuid" => self.uuid.is_set(),
            "end_date" => self.end_date.is_set(),
            "project_uuid" => self.project_uuid.is_set(),
            "work_uuid" => self.work_uuid.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "start_date",
                nullable: true,
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
                name: "end_date",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "project_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "work_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmProjectSchedule<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn project_schedule<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveProjectSchedule>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXProjectSchedule<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn project_schedule(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveProjectSchedule>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveProjectSchedule 
{
    type NonActive = ProjectSchedule;
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
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.project_uuid {tracing::debug!("Binded project_uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
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
impl OrmProjectSchedule<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn project_schedule<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveProjectSchedule>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXProjectSchedule<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn project_schedule(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveProjectSchedule>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveProjectSchedule 
{
    type NonActive = ProjectSchedule;
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
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.project_uuid {tracing::debug!("Binded project_uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
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
impl OrmProjectSchedule<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn project_schedule<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveProjectSchedule>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXProjectSchedule<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn project_schedule(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveProjectSchedule>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveProjectSchedule 
{
    type NonActive = ProjectSchedule;
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
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.project_uuid {tracing::debug!("Binded project_uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
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
