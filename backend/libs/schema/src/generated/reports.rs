// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl Reports {
    pub fn into_active(self) -> ActiveReports {
        ActiveReports {
            check_date: Set(self.check_date),
            report_date: Set(self.report_date),
            uuid: Set(self.uuid),
            project_schedule_item: Set(self.project_schedule_item),
            status: Set(self.status),
        }
    }
}

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "utoipa_gen", derive(utoipa::ToSchema))]
#[derive(Clone, Debug, FromRow)]
pub struct Reports {
    pub check_date: Option<chrono::NaiveDate>,
    pub report_date: chrono::NaiveDate,
    pub uuid: uuid::Uuid,
    pub project_schedule_item: uuid::Uuid,
    pub status: i32,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveReports {
    pub check_date: Optional<Option<chrono::NaiveDate>>,
    pub report_date: Optional<chrono::NaiveDate>,
    pub uuid: Optional<uuid::Uuid>,
    pub project_schedule_item: Optional<uuid::Uuid>,
    pub status: Optional<i32>,
}

impl ActiveReports {
    pub fn into_reports(self) -> Option<Reports> {
        Some(Reports {
            check_date: self.check_date.into_option()?,
            report_date: self.report_date.into_option()?,
            uuid: self.uuid.into_option()?,
            project_schedule_item: self.project_schedule_item.into_option()?,
            status: self.status.into_option()?,
        })
    }
}

pub trait OrmReports<DB: OrmDB> {
    fn reports<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveReports>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXReports<'c, DB: OrmDB> {
    fn reports(&'c mut self) -> TxSelector<'c, DB, ActiveReports>;
}

impl TableSelector for ActiveReports {
    const TABLE_NAME: &'static str = "reports";
    const TABLE_SCHEMA: &'static str = "norm";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "uuid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "check_date" => self.check_date.is_set(),
            "report_date" => self.report_date.is_set(),
            "uuid" => self.uuid.is_set(),
            "project_schedule_item" => self.project_schedule_item.is_set(),
            "status" => self.status.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "check_date",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "report_date",
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
                name: "project_schedule_item",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "status",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmReports<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn reports<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveReports>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXReports<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn reports(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveReports>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveReports 
{
    type NonActive = Reports;
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
        if let Set(v) = &self.check_date {tracing::debug!("Binded check_date"); q = q.bind(v);}
        if let Set(v) = &self.report_date {tracing::debug!("Binded report_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.project_schedule_item {tracing::debug!("Binded project_schedule_item"); q = q.bind(v);}
        if let Set(v) = &self.status {tracing::debug!("Binded status"); q = q.bind(v);}
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
impl OrmReports<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn reports<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveReports>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXReports<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn reports(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveReports>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveReports 
{
    type NonActive = Reports;
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
        if let Set(v) = &self.check_date {tracing::debug!("Binded check_date"); q = q.bind(v);}
        if let Set(v) = &self.report_date {tracing::debug!("Binded report_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.project_schedule_item {tracing::debug!("Binded project_schedule_item"); q = q.bind(v);}
        if let Set(v) = &self.status {tracing::debug!("Binded status"); q = q.bind(v);}
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
impl OrmReports<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn reports<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveReports>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXReports<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn reports(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveReports>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveReports 
{
    type NonActive = Reports;
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
        if let Set(v) = &self.check_date {tracing::debug!("Binded check_date"); q = q.bind(v);}
        if let Set(v) = &self.report_date {tracing::debug!("Binded report_date"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.project_schedule_item {tracing::debug!("Binded project_schedule_item"); q = q.bind(v);}
        if let Set(v) = &self.status {tracing::debug!("Binded status"); q = q.bind(v);}
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
