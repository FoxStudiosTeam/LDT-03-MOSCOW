
use std::collections::{HashMap, HashSet};

use clap::Parser;
use serde::{Deserialize, Serialize};
use serde_yaml;
use sqlx::{postgres::PgPoolOptions, prelude::FromRow};
use tracing::info;
use utils::env_config;


env_config!(
    ".env" => pub(crate) ENV = pub(crate) Env {
        DB_URL: String,
    }
);



#[derive(clap::Parser, Debug)]
struct Args {
    out_dir: String,
    #[clap(long, action = clap::ArgAction::SetTrue)]
    ignore_nullability: bool,
    schemas: Vec<String>,
}



#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mappings = HashMap::from([
        ("timestamp without time zone".to_string(), "timestamp".to_string()),
        ("double precision".to_string(), "float8".to_string()),
    ]);
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::new("debug"))
        .init();
    let Args{out_dir, ignore_nullability, schemas} = Args::parse();
    info!("Connecting to DB");
    let pool = PgPoolOptions::new()
        .connect(&ENV.DB_URL).await?;

    let mut raw_tables: HashMap<String, RawTables> = HashMap::new();

    let mut allowed = hashbrown::HashSet::with_capacity(schemas.len());
    allowed.extend(schemas);

    let rows = sqlx::query_as::<_, PgRowDefinition>(
            "SELECT table_schema, table_name, column_name, data_type, column_default, is_nullable
            FROM information_schema.columns
            WHERE table_schema NOT IN ('information_schema','pg_catalog')
            ORDER BY table_schema, table_name"
        )
        .fetch_all(&pool)
        .await?;
    let pk_rows = sqlx::query_as::<_, (String, String, String)>(
        "SELECT kcu.table_schema, kcu.table_name, kcu.column_name
        FROM information_schema.table_constraints tco
        JOIN information_schema.key_column_usage kcu
        ON kcu.constraint_name = tco.constraint_name
        AND kcu.constraint_schema = tco.constraint_schema
        WHERE tco.constraint_type = 'PRIMARY KEY'"
    )
    .fetch_all(&pool)
    .await?
    .into_iter()
    .collect::<HashSet<(String, String, String)>>();

    let uq_rows: HashSet<(String, String, String)> = sqlx::query_as::<_, (String, String, String)>(
        "SELECT kcu.table_schema, kcu.table_name, kcu.column_name
        FROM information_schema.table_constraints tco
        JOIN information_schema.key_column_usage kcu
        ON kcu.constraint_name = tco.constraint_name
        AND kcu.constraint_schema = tco.constraint_schema
        WHERE tco.constraint_type = 'UNIQUE'"
    )
    .fetch_all(&pool)
    .await?
    .into_iter()
    .collect::<HashSet<(String, String, String)>>();

    for row in rows {
        if !allowed.contains(&row.table_schema) {continue;}
        let PgRowDefinition {
            table_schema,
            table_name,
            column_name,
            data_type,
            column_default,
            is_nullable,
        } = row;
        let e = raw_tables.entry(table_schema.clone())
            .or_insert(RawTables::default());
        let data_type = mappings.get(&data_type).cloned().unwrap_or(data_type);
        let nullable = if ignore_nullability {None} else if is_nullable == "YES" {Some(true)} else {None};
        let f = Field {
            is_primary: if pk_rows.contains(&(table_schema.clone(), table_name.clone(), column_name.clone())) {Some(true)} else {None},
            is_unique: if uq_rows.contains(&(table_schema.clone(), table_name.clone(), column_name.clone())) {Some(true)} else {None},
            name: column_name,
            type_name: data_type,
            default: column_default,
            nullable, //: if is_nullable == "YES" {Some(true)} else {None},
        };
        e.tables.entry(table_name).or_insert(vec![]).push(f);
    }
    let mut tables: HashMap<String, Tables> = HashMap::new();
    for (schema, vals) in raw_tables {
        for (table_name, fields) in vals.tables {
            let table = Table {
                extends: None,
                name: table_name,
                schema: schema.clone(),
                fields,
            };
            tables.entry(schema.clone()).or_insert(Tables::default()).tables.push(table);
        }
    }
    for (schema, tables) in tables {
        let yaml_str = serde_yaml::to_string(&tables);
        std::fs::write(format!("{}/{}.yaml", out_dir, schema), yaml_str.unwrap()).unwrap();
    }
    Ok(())
}

#[derive(Serialize, Deserialize, FromRow)]
struct PgRowDefinition {
    table_schema: String,
    table_name: String,
    column_name: String,
    data_type: String,
    column_default: Option<String>,
    is_nullable: String,
}


#[derive(Serialize)]
struct Table {
    name: String,
    schema: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    extends: Option<String>,
    fields: Vec<Field>,
}
#[derive(Default)]
struct RawTables {
    tables: HashMap<String, Vec<Field>>,
}

#[derive(Serialize, Default)]
struct Tables {
    tables: Vec<Table>,
}

#[derive(Serialize)]
pub struct Field {
    pub name: String,
    #[serde(rename = "type")]
    pub type_name: String,
    #[serde(rename = "isPrimary", skip_serializing_if = "Option::is_none")]
    pub is_primary: Option<bool>,
    #[serde(rename = "default", skip_serializing_if = "Option::is_none")]
    pub default: Option<String>,
    #[serde(rename = "nullable", skip_serializing_if = "Option::is_none")]
    pub nullable: Option<bool>,
    #[serde(rename = "isUnique", skip_serializing_if = "Option::is_none")]
    pub is_unique: Option<bool>
}
