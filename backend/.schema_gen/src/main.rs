use schema_reader::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt()
        // .with_env_filter(tracing_subscriber::EnvFilter::new("debug"))
        .init();
    let schema = Schema::from_dir("./backend/.schema")?;
    tracing::info!("Schema with {} tables and {} types loaded from dir!", schema.get_tables().len(), schema.get_types().len());
    let rust_path = "./backend/libs/schema/src/generated";
    std::fs::create_dir_all(rust_path).ok();
    orm::generators::generate_rust_bindings(&schema, rust_path)
        .inspect_err(|e| tracing::error!("Failed to generate rust bindings!: {}", e))?;
    tracing::info!("Rust bindings generated!");
    let splitted = schema.split_by_schema();
    let migration_path = "./backend/.migrations";

    for (schema_name, schema_def) in splitted {
        let migration_path = format!("{migration_path}/{schema_name}");
        std::fs::create_dir_all(&migration_path).ok();
        orm::generators::generate_migration(schema_def, migration_path, None)
            .inspect_err(|e| tracing::error!("Failed to generate migration!: {}", e))?;
    }
    Ok(())
}


