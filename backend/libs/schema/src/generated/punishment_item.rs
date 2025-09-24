// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
#![allow(unused)]
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

impl PunishmentItem {
    pub fn into_active(self) -> ActivePunishmentItem {
        ActivePunishmentItem {
            punishment: Set(self.punishment),
            uuid: Set(self.uuid),
            correction_date_fact: Set(self.correction_date_fact),
            correction_date_info: Set(self.correction_date_info),
            is_suspend: Set(self.is_suspend),
            comment: Set(self.comment),
            punish_datetime: Set(self.punish_datetime),
            regulation_doc: Set(self.regulation_doc),
            correction_date_plan: Set(self.correction_date_plan),
            title: Set(self.title),
            punishment_item_status: Set(self.punishment_item_status),
            place: Set(self.place),
        }
    }
}

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "utoipa_gen", derive(utoipa::ToSchema))]
#[derive(Clone, Debug, FromRow)]
pub struct PunishmentItem {
    pub punishment: uuid::Uuid,
    pub uuid: uuid::Uuid,
    pub correction_date_fact: Option<chrono::NaiveDate>,
    pub correction_date_info: Option<String>,
    pub is_suspend: bool,
    pub comment: Option<String>,
    pub punish_datetime: chrono::NaiveDateTime,
    pub regulation_doc: Option<uuid::Uuid>,
    pub correction_date_plan: chrono::NaiveDate,
    pub title: String,
    pub punishment_item_status: i32,
    pub place: String,
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActivePunishmentItem {
    pub punishment: Optional<uuid::Uuid>,
    pub uuid: Optional<uuid::Uuid>,
    pub correction_date_fact: Optional<Option<chrono::NaiveDate>>,
    pub correction_date_info: Optional<Option<String>>,
    pub is_suspend: Optional<bool>,
    pub comment: Optional<Option<String>>,
    pub punish_datetime: Optional<chrono::NaiveDateTime>,
    pub regulation_doc: Optional<Option<uuid::Uuid>>,
    pub correction_date_plan: Optional<chrono::NaiveDate>,
    pub title: Optional<String>,
    pub punishment_item_status: Optional<i32>,
    pub place: Optional<String>,
}

impl ActivePunishmentItem {
    pub fn into_punishment_item(self) -> Option<PunishmentItem> {
        Some(PunishmentItem {
            punishment: self.punishment.into_option()?,
            uuid: self.uuid.into_option()?,
            correction_date_fact: self.correction_date_fact.into_option()?,
            correction_date_info: self.correction_date_info.into_option()?,
            is_suspend: self.is_suspend.into_option()?,
            comment: self.comment.into_option()?,
            punish_datetime: self.punish_datetime.into_option()?,
            regulation_doc: self.regulation_doc.into_option()?,
            correction_date_plan: self.correction_date_plan.into_option()?,
            title: self.title.into_option()?,
            punishment_item_status: self.punishment_item_status.into_option()?,
            place: self.place.into_option()?,
        })
    }
}

pub trait OrmPunishmentItem<DB: OrmDB> {
    fn punishment_item<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActivePunishmentItem>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXPunishmentItem<'c, DB: OrmDB> {
    fn punishment_item(&'c mut self) -> TxSelector<'c, DB, ActivePunishmentItem>;
}

impl TableSelector for ActivePunishmentItem {
    const TABLE_NAME: &'static str = "punishment_item";
    const TABLE_SCHEMA: &'static str = "journal";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "uuid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "punishment" => self.punishment.is_set(),
            "uuid" => self.uuid.is_set(),
            "correction_date_fact" => self.correction_date_fact.is_set(),
            "correction_date_info" => self.correction_date_info.is_set(),
            "is_suspend" => self.is_suspend.is_set(),
            "comment" => self.comment.is_set(),
            "punish_datetime" => self.punish_datetime.is_set(),
            "regulation_doc" => self.regulation_doc.is_set(),
            "correction_date_plan" => self.correction_date_plan.is_set(),
            "title" => self.title.is_set(),
            "punishment_item_status" => self.punishment_item_status.is_set(),
            "place" => self.place.is_set(),
            _ => unreachable!("Unknown field name: {}", field_name),
        }
    }
    fn columns() -> &'static [ColumnDef] {
        &[
            ColumnDef{
                name: "punishment",
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
                name: "correction_date_fact",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "correction_date_info",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "is_suspend",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "comment",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "punish_datetime",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "regulation_doc",
                nullable: true,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "correction_date_plan",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "title",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "punishment_item_status",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "place",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmPunishmentItem<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn punishment_item<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActivePunishmentItem>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXPunishmentItem<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn punishment_item(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActivePunishmentItem>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActivePunishmentItem 
{
    type NonActive = PunishmentItem;
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
        if let Set(v) = &self.punishment {tracing::debug!("Binded punishment"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_fact {tracing::debug!("Binded correction_date_fact"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_info {tracing::debug!("Binded correction_date_info"); q = q.bind(v);}
        if let Set(v) = &self.is_suspend {tracing::debug!("Binded is_suspend"); q = q.bind(v);}
        if let Set(v) = &self.comment {tracing::debug!("Binded comment"); q = q.bind(v);}
        if let Set(v) = &self.punish_datetime {tracing::debug!("Binded punish_datetime"); q = q.bind(v);}
        if let Set(v) = &self.regulation_doc {tracing::debug!("Binded regulation_doc"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_plan {tracing::debug!("Binded correction_date_plan"); q = q.bind(v);}
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.punishment_item_status {tracing::debug!("Binded punishment_item_status"); q = q.bind(v);}
        if let Set(v) = &self.place {tracing::debug!("Binded place"); q = q.bind(v);}
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
impl OrmPunishmentItem<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn punishment_item<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActivePunishmentItem>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXPunishmentItem<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn punishment_item(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActivePunishmentItem>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActivePunishmentItem 
{
    type NonActive = PunishmentItem;
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
        if let Set(v) = &self.punishment {tracing::debug!("Binded punishment"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_fact {tracing::debug!("Binded correction_date_fact"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_info {tracing::debug!("Binded correction_date_info"); q = q.bind(v);}
        if let Set(v) = &self.is_suspend {tracing::debug!("Binded is_suspend"); q = q.bind(v);}
        if let Set(v) = &self.comment {tracing::debug!("Binded comment"); q = q.bind(v);}
        if let Set(v) = &self.punish_datetime {tracing::debug!("Binded punish_datetime"); q = q.bind(v);}
        if let Set(v) = &self.regulation_doc {tracing::debug!("Binded regulation_doc"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_plan {tracing::debug!("Binded correction_date_plan"); q = q.bind(v);}
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.punishment_item_status {tracing::debug!("Binded punishment_item_status"); q = q.bind(v);}
        if let Set(v) = &self.place {tracing::debug!("Binded place"); q = q.bind(v);}
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
impl OrmPunishmentItem<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn punishment_item<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActivePunishmentItem>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXPunishmentItem<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn punishment_item(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActivePunishmentItem>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActivePunishmentItem 
{
    type NonActive = PunishmentItem;
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
        if let Set(v) = &self.punishment {tracing::debug!("Binded punishment"); q = q.bind(v);}
        if let Set(v) = &self.uuid {tracing::debug!("Binded uuid"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_fact {tracing::debug!("Binded correction_date_fact"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_info {tracing::debug!("Binded correction_date_info"); q = q.bind(v);}
        if let Set(v) = &self.is_suspend {tracing::debug!("Binded is_suspend"); q = q.bind(v);}
        if let Set(v) = &self.comment {tracing::debug!("Binded comment"); q = q.bind(v);}
        if let Set(v) = &self.punish_datetime {tracing::debug!("Binded punish_datetime"); q = q.bind(v);}
        if let Set(v) = &self.regulation_doc {tracing::debug!("Binded regulation_doc"); q = q.bind(v);}
        if let Set(v) = &self.correction_date_plan {tracing::debug!("Binded correction_date_plan"); q = q.bind(v);}
        if let Set(v) = &self.title {tracing::debug!("Binded title"); q = q.bind(v);}
        if let Set(v) = &self.punishment_item_status {tracing::debug!("Binded punishment_item_status"); q = q.bind(v);}
        if let Set(v) = &self.place {tracing::debug!("Binded place"); q = q.bind(v);}
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
