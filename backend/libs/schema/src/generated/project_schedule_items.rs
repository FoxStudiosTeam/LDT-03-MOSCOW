// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl ProjectScheduleItems {
    pub fn into_active(self) -> ActiveProjectScheduleItems {
        ActiveProjectScheduleItems {
            project_schedule_uuid: Set(self.project_schedule_uuid),
            created_by: Set(self.created_by),
            is_completed: Set(self.is_completed),
            uuid: Set(self.uuid),
            work_uuid: Set(self.work_uuid),
            start_date: Set(self.start_date),
            end_date: Set(self.end_date),
            target_volume: Set(self.target_volume),
            measurement: Set(self.measurement),
            updated_by: Set(self.updated_by),
            is_draft: Set(self.is_draft),
            is_deleted: Set(self.is_deleted),
        }
    }
}

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "utoipa_gen", derive(utoipa::ToSchema))]
#[derive(Clone, Debug, FromRow)]
pub struct ProjectScheduleItems {
    pub project_schedule_uuid: uuid::Uuid,
    pub created_by: uuid::Uuid,
    pub is_completed: bool,
    pub uuid: uuid::Uuid,
    pub work_uuid: uuid::Uuid,
    pub start_date: chrono::NaiveDate,
    pub end_date: chrono::NaiveDate,
    pub target_volume: f64,
    pub measurement: i32,
    pub updated_by: Option<uuid::Uuid>,
    pub is_draft: bool,
    pub is_deleted: bool,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveProjectScheduleItems {
    pub project_schedule_uuid: Optional<uuid::Uuid>,
    pub created_by: Optional<uuid::Uuid>,
    pub is_completed: Optional<bool>,
    pub uuid: Optional<uuid::Uuid>,
    pub work_uuid: Optional<uuid::Uuid>,
    pub start_date: Optional<chrono::NaiveDate>,
    pub end_date: Optional<chrono::NaiveDate>,
    pub target_volume: Optional<f64>,
    pub measurement: Optional<i32>,
    pub updated_by: Optional<Option<uuid::Uuid>>,
    pub is_draft: Optional<bool>,
    pub is_deleted: Optional<bool>,
}

impl ActiveProjectScheduleItems {
    pub fn into_project_schedule_items(self) -> Option<ProjectScheduleItems> {
        Some(ProjectScheduleItems {
            project_schedule_uuid: self.project_schedule_uuid.into_option()?,
            created_by: self.created_by.into_option()?,
            is_completed: self.is_completed.into_option()?,
            uuid: self.uuid.into_option()?,
            work_uuid: self.work_uuid.into_option()?,
            start_date: self.start_date.into_option()?,
            end_date: self.end_date.into_option()?,
            target_volume: self.target_volume.into_option()?,
            measurement: self.measurement.into_option()?,
            updated_by: self.updated_by.into_option()?,
            is_draft: self.is_draft.into_option()?,
            is_deleted: self.is_deleted.into_option()?,
        })
    }
}

pub trait OrmProjectScheduleItems<DB: OrmDB> {
    fn project_schedule_items<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveProjectScheduleItems>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXProjectScheduleItems<'c, DB: OrmDB> {
    fn project_schedule_items(&'c mut self) -> TxSelector<'c, DB, ActiveProjectScheduleItems>;
}

impl TableSelector for ActiveProjectScheduleItems {
    const TABLE_NAME: &'static str = "project_schedule_items";
    const TABLE_SCHEMA: &'static str = "journal";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "uuid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "project_schedule_uuid" => self.project_schedule_uuid.is_set(),
            "created_by" => self.created_by.is_set(),
            "is_completed" => self.is_completed.is_set(),
            "uuid" => self.uuid.is_set(),
            "work_uuid" => self.work_uuid.is_set(),
            "start_date" => self.start_date.is_set(),
            "end_date" => self.end_date.is_set(),
            "target_volume" => self.target_volume.is_set(),
            "measurement" => self.measurement.is_set(),
            "updated_by" => self.updated_by.is_set(),
            "is_draft" => self.is_draft.is_set(),
            "is_deleted" => self.is_deleted.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "project_schedule_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "created_by",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "is_completed",
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
                name: "work_uuid",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "start_date",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "end_date",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "target_volume",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "measurement",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "updated_by",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "is_draft",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "is_deleted",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmProjectScheduleItems<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn project_schedule_items<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveProjectScheduleItems>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXProjectScheduleItems<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn project_schedule_items(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveProjectScheduleItems>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveProjectScheduleItems 
{
    type NonActive = ProjectScheduleItems;
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
        if let Set(v) = &self.project_schedule_uuid {tracing::debug!("Binded project_schedule_uuid"); q = q.bind(v);}
        if let Set(v) = &self.created_by {tracing::debug!("Binded created_by"); q = q.bind(v);}
        if let Set(v) = &self.is_completed {tracing::debug!("Binded is_completed"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.target_volume {tracing::debug!("Binded target_volume"); q = q.bind(v);}
        if let Set(v) = &self.measurement {tracing::debug!("Binded measurement"); q = q.bind(v);}
        if let Set(v) = &self.updated_by {tracing::debug!("Binded updated_by"); q = q.bind(v);}
        if let Set(v) = &self.is_draft {tracing::debug!("Binded is_draft"); q = q.bind(v);}
        if let Set(v) = &self.is_deleted {tracing::debug!("Binded is_deleted"); q = q.bind(v);}
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
impl OrmProjectScheduleItems<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn project_schedule_items<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveProjectScheduleItems>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXProjectScheduleItems<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn project_schedule_items(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveProjectScheduleItems>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveProjectScheduleItems 
{
    type NonActive = ProjectScheduleItems;
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
        if let Set(v) = &self.project_schedule_uuid {tracing::debug!("Binded project_schedule_uuid"); q = q.bind(v);}
        if let Set(v) = &self.created_by {tracing::debug!("Binded created_by"); q = q.bind(v);}
        if let Set(v) = &self.is_completed {tracing::debug!("Binded is_completed"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.target_volume {tracing::debug!("Binded target_volume"); q = q.bind(v);}
        if let Set(v) = &self.measurement {tracing::debug!("Binded measurement"); q = q.bind(v);}
        if let Set(v) = &self.updated_by {tracing::debug!("Binded updated_by"); q = q.bind(v);}
        if let Set(v) = &self.is_draft {tracing::debug!("Binded is_draft"); q = q.bind(v);}
        if let Set(v) = &self.is_deleted {tracing::debug!("Binded is_deleted"); q = q.bind(v);}
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
impl OrmProjectScheduleItems<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn project_schedule_items<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveProjectScheduleItems>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXProjectScheduleItems<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn project_schedule_items(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveProjectScheduleItems>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveProjectScheduleItems 
{
    type NonActive = ProjectScheduleItems;
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
        if let Set(v) = &self.project_schedule_uuid {tracing::debug!("Binded project_schedule_uuid"); q = q.bind(v);}
        if let Set(v) = &self.created_by {tracing::debug!("Binded created_by"); q = q.bind(v);}
        if let Set(v) = &self.is_completed {tracing::debug!("Binded is_completed"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.work_uuid {tracing::debug!("Binded work_uuid"); q = q.bind(v);}
        if let Set(v) = &self.start_date {tracing::debug!("Binded start_date"); q = q.bind(v);}
        if let Set(v) = &self.end_date {tracing::debug!("Binded end_date"); q = q.bind(v);}
        if let Set(v) = &self.target_volume {tracing::debug!("Binded target_volume"); q = q.bind(v);}
        if let Set(v) = &self.measurement {tracing::debug!("Binded measurement"); q = q.bind(v);}
        if let Set(v) = &self.updated_by {tracing::debug!("Binded updated_by"); q = q.bind(v);}
        if let Set(v) = &self.is_draft {tracing::debug!("Binded is_draft"); q = q.bind(v);}
        if let Set(v) = &self.is_deleted {tracing::debug!("Binded is_deleted"); q = q.bind(v);}
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
