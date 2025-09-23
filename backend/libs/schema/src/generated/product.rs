// THIS FILE IS GENERATED, NOT FOR MANUAL EDIT
use sqlx::{Executor, FromRow};
use sqlx::query::QueryAs;
use orm::prelude::*;
use sqlx::Pool;
use sqlx::types::*;

#[derive(Clone, Debug, FromRow)]
pub struct Product {
    pub title: String,
    pub guid: uuid::Uuid,
    pub updated_at: chrono::NaiveDateTime,
    pub created_at: chrono::NaiveDateTime,
    pub count: i32,
}

impl Product {
    pub fn into_active(self) -> ActiveProduct {
        ActiveProduct {
            title: Set(self.title),
            guid: Set(self.guid),
            updated_at: Set(self.updated_at),
            created_at: Set(self.created_at),
            count: Set(self.count),
        }
    }
}

#[derive(Clone,Debug, Default, FromRow)]
pub struct ActiveProduct {
    pub title: Optional<String>,
    pub guid: Optional<uuid::Uuid>,
    pub updated_at: Optional<chrono::NaiveDateTime>,
    pub created_at: Optional<chrono::NaiveDateTime>,
    pub count: Optional<i32>,
}

impl ActiveProduct {
    pub fn into_product(self) -> Option<Product> {
        Some(Product {
            title: self.title.into_option()?,
            guid: self.guid.into_option()?,
            updated_at: self.updated_at.into_option()?,
            created_at: self.created_at.into_option()?,
            count: self.count.into_option()?,
        })
    }
}

pub trait OrmProduct<DB: OrmDB> {
    fn product<'e>(&'e self) -> DBSelector<'e, DB, Pool<DB>, ActiveProduct>
    where 
        &'e Pool<DB>: Executor<'e, Database = DB>;
}

pub trait OrmTXProduct<'c, DB: OrmDB> {
    fn product(&'c mut self) -> TxSelector<'c, DB, ActiveProduct>;
}

impl TableSelector for ActiveProduct {
    const TABLE_NAME: &'static str = "product";
    const TABLE_SCHEMA: &'static str = "product";
    type TypePK = uuid::Uuid;
    fn pk_column() -> &'static str {
        "guid"
    }
    fn is_field_set(&self, field_name: &str) -> bool {
        match field_name {
            "title" => self.title.is_set(),
            "guid" => self.guid.is_set(),
            "updated_at" => self.updated_at.is_set(),
            "created_at" => self.created_at.is_set(),
            "count" => self.count.is_set(),
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
                name: "guid",
                nullable: false,
                default: Some("gen_random_uuid()"),
                is_unique: false,
                is_primary: true,
            },
            ColumnDef{
                name: "updated_at",
                nullable: false,
                default: Some("LOCALTIMESTAMP"),
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "created_at",
                nullable: false,
                default: Some("LOCALTIMESTAMP"),
                is_unique: false,
                is_primary: false,
            },
            ColumnDef{
                name: "count",
                nullable: false,
                default: None,
                is_unique: false,
                is_primary: false,
            },
        ]
    }
}

#[cfg(feature="postgres")]
impl OrmProduct<sqlx::Postgres> for Orm<Pool<sqlx::Postgres>>
{
    fn product<'e>(&'e self) -> DBSelector<'e, sqlx::Postgres, Pool<sqlx::Postgres>, ActiveProduct>
    where 
        &'e Pool<sqlx::Postgres>: Executor<'e, Database = sqlx::Postgres>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="postgres")]
impl<'c> OrmTXProduct<'c, sqlx::Postgres> for OrmTX<sqlx::Postgres>
{
    fn product(&'c mut self) -> TxSelector<'c, sqlx::Postgres, ActiveProduct>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="postgres")]
impl ModelOps<sqlx::Postgres> for ActiveProduct 
{
    type NonActive = Product;
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
        if let Set(v) = &self.guid {tracing::debug!("Binded guid"); q = q.bind(v);}
        if let Set(v) = &self.updated_at {tracing::debug!("Binded updated_at"); q = q.bind(v);}
        if let Set(v) = &self.created_at {tracing::debug!("Binded created_at"); q = q.bind(v);}
        if let Set(v) = &self.count {tracing::debug!("Binded count"); q = q.bind(v);}
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
impl OrmProduct<sqlx::MySql> for Orm<Pool<sqlx::MySql>>
{
    fn product<'e>(&'e self) -> DBSelector<'e, sqlx::MySql, Pool<sqlx::MySql>, ActiveProduct>
    where 
        &'e Pool<sqlx::MySql>: Executor<'e, Database = sqlx::MySql>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="mysql")]
impl<'c> OrmTXProduct<'c, sqlx::MySql> for OrmTX<sqlx::MySql>
{
    fn product(&'c mut self) -> TxSelector<'c, sqlx::MySql, ActiveProduct>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="mysql")]
impl ModelOps<sqlx::MySql> for ActiveProduct 
{
    type NonActive = Product;
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
        if let Set(v) = &self.guid {tracing::debug!("Binded guid"); q = q.bind(v);}
        if let Set(v) = &self.updated_at {tracing::debug!("Binded updated_at"); q = q.bind(v);}
        if let Set(v) = &self.created_at {tracing::debug!("Binded created_at"); q = q.bind(v);}
        if let Set(v) = &self.count {tracing::debug!("Binded count"); q = q.bind(v);}
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
impl OrmProduct<sqlx::Sqlite> for Orm<Pool<sqlx::Sqlite>>
{
    fn product<'e>(&'e self) -> DBSelector<'e, sqlx::Sqlite, Pool<sqlx::Sqlite>, ActiveProduct>
    where 
        &'e Pool<sqlx::Sqlite>: Executor<'e, Database = sqlx::Sqlite>
    {
        DBSelector::new(&self.get_executor())
    }
}

#[cfg(feature="sqlite")]
impl<'c> OrmTXProduct<'c, sqlx::Sqlite> for OrmTX<sqlx::Sqlite>
{
    fn product(&'c mut self) -> TxSelector<'c, sqlx::Sqlite, ActiveProduct>
    {
        TxSelector::new(self.get_inner())
    }
}

#[cfg(feature="sqlite")]
impl ModelOps<sqlx::Sqlite> for ActiveProduct 
{
    type NonActive = Product;
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
        if let Set(v) = &self.guid {tracing::debug!("Binded guid"); q = q.bind(v);}
        if let Set(v) = &self.updated_at {tracing::debug!("Binded updated_at"); q = q.bind(v);}
        if let Set(v) = &self.created_at {tracing::debug!("Binded created_at"); q = q.bind(v);}
        if let Set(v) = &self.count {tracing::debug!("Binded count"); q = q.bind(v);}
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
