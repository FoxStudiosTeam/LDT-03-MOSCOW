use schema_reader::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt::init();
    let schema = Schema::from_dir("./backend/.schema")?;
    tracing::info!("Schema with {} tables and {} types loaded from dir!", schema.get_tables().len(), schema.get_types().len());
    let rust_path = "./backend/libs/schema/src/generated";
    std::fs::create_dir_all(rust_path).ok();
    orm::generators::generate_rust_bindings(&schema, rust_path)
        .inspect_err(|e| tracing::error!("Failed to generate rust bindings!: {}", e))?;
    tracing::info!("Rust bindings generated!");
    let migration_path = "./backend/.migrations";
    std::fs::create_dir_all(migration_path).ok();
    orm::generators::generate_migration(schema, migration_path, None)
        .inspect_err(|e| tracing::error!("Failed to generate migration!: {}", e))?;
    Ok(())
}
