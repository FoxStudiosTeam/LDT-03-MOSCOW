// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl ReportStatuses {
    pub fn into_active(self) -> ActiveReportStatuses {
        ActiveReportStatuses {
            title: Set(self.title),
            id: Set(self.id),
        }
    }
}

#[cfg(not(feature="serde"))]
#[derive(Clone, Debug, FromRow)]
pub struct ReportStatuses {
    pub title: String,
    pub id: i32,
}

#[cfg(feature="serde")]
#[derive(serde::Serialize, serde::Deserialize)]
#[derive(Clone, Debug, FromRow)]
pub struct ReportStatuses {
    pub title: String,
    pub id: i32,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveReportStatuses {
    pub title: Optional<String>,
    pub id: Optional<i32>,
}

impl ActiveReportStatuses {
    pub fn into_report_statuses(self) -> Option<ReportStatuses> {
        Some(ReportStatuses {
            title: self.title.into_option()?,
            id: self.id.into_option()?,
        })
    }
}

pub trait OrmReportStatuses<DB: OrmDB> {
    fn report_statuses<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveReportStatuses>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXReportStatuses<'c, DB: OrmDB> {
    fn report_statuses(&'c mut self) -> TxSelector<'c, DB, ActiveReportStatuses>;
}

impl TableSelector for ActiveReportStatuses {
    const TABLE_NAME: &'static str = "report_statuses";
    const TABLE_SCHEMA: &'static str = "norm";
    type TypePK = i32;
    fn pk_column() -> &'static str {
        "id"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "title" => self.title.is_set(),
            "id" => self.id.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "title",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "id",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: true,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmReportStatuses<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn report_statuses<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveReportStatuses>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXReportStatuses<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn report_statuses(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveReportStatuses>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveReportStatuses 
{
    type NonActive = ReportStatuses;
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
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.id {tracing::debug!("Binded id"); q = q.bind(v);}
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
impl OrmReportStatuses<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn report_statuses<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveReportStatuses>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXReportStatuses<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn report_statuses(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveReportStatuses>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveReportStatuses 
{
    type NonActive = ReportStatuses;
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
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.id {tracing::debug!("Binded id"); q = q.bind(v);}
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
impl OrmReportStatuses<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn report_statuses<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveReportStatuses>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXReportStatuses<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn report_statuses(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveReportStatuses>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveReportStatuses 
{
    type NonActive = ReportStatuses;
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
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.id {tracing::debug!("Binded id"); q = q.bind(v);}
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
