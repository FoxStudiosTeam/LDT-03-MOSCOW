rust_lint:
	cargo clippy
rust_test:
	cargo test
install_refinery:
	cargo install refinery_cli
setup_migrations:
	refinery setup
migrate:
	refinery migrate -p ./backend/.migrations --table-name refinery_monorepo_history 
gen:
	cargo run --bin schema_gen
yml:
	cargo run --bin yaml_from_db -- ./backend/.schema attachment journal norm product project --ignore-nullability