rust_lint:
	cargo clippy
rust_test:
	cargo test
install_refinery:
	cargo install refinery_cli
setup_migrations:
	refinery setup
gen:
	cargo run --bin schema_gen
yml:
	cargo run --bin yaml_from_db -- ./backend/.schema attachment journal norm product project
migrate_attachment:
	refinery migrate -p ./backend/.migrations/attachment --table-name refinery_attachment_history
migrate_journal:
	refinery migrate -p ./backend/.migrations/journal --table-name refinery_journal_history
migrate_norm:
	refinery migrate -p ./backend/.migrations/norm --table-name refinery_norm_history 
migrate_product:
	refinery migrate -p ./backend/.migrations/product --table-name refinery_product_history
migrate_project:
	refinery migrate -p ./backend/.migrations/project --table-name refinery_project_history
migrate_fk:
	refinery migrate -p ./backend/.migrations/fk --table-name refinery_fk_history
migrate:
	make migrate_attachment
	make migrate_journal
	make migrate_norm
	make migrate_product
	make migrate_project
	make migrate_fk