alter table journal.project_schedule_items
    add constraint project_schedule_items_measurements_id_fk
        foreign key (measurement) references norm.measurements;