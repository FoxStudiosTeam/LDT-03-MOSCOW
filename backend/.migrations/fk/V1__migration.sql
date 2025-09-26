alter table project.iko_relationship
    add constraint iko_relationship_project_uuid_fk
        foreign key (project) references project.project;

alter table project.iko_relationship
    add constraint iko_relationship_users_uuid_fk
        foreign key (user_uuid) references auth.users;

alter table project.project
    add constraint project_project_statuses_id_fk
        foreign key (status) references norm.project_statuses;

alter table project.project
    add constraint project_users_uuid_fk
        foreign key (foreman) references auth.users;

alter table project.project
    add constraint project_users_uuid_fk_2
        foreign key (ssk) references auth.users;

alter table norm.materials
    add constraint materials_measurements_id_fk
        foreign key (measurement) references norm.measurements;

alter table norm.materials
    add constraint materials_project_schedule_items_uuid_fk
        foreign key (project_schedule_item) references journal.project_schedule_items;

alter table norm.reports
    add constraint reports_project_schedule_items_uuid_fk
        foreign key (project_schedule_item) references journal.project_schedule_items;

alter table norm.reports
    add constraint reports_report_statuses_id_fk
        foreign key (status) references norm.report_statuses;

alter table norm.work_category
    add constraint work_category_kpgz_id_fk
        foreign key (kpgz) references norm.kpgz;

alter table norm.works
    add constraint works_work_category_uuid_fk
        foreign key (work_category) references norm.work_category;

alter table journal.project_schedule
    add constraint project_schedule_project_uuid_fk
        foreign key (project_uuid) references project.project;

alter table journal.project_schedule_items
    add constraint project_schedule_items_project_schedule_uuid_fk
        foreign key (project_schedule_uuid) references journal.project_schedule;

alter table journal.project_schedule_items
    add constraint project_schedule_items_works_uuid_fk
        foreign key (work_uuid) references norm.works;

alter table journal.punishment
    add constraint punishment_project_uuid_fk
        foreign key (project) references project.project;

alter table journal.punishment
    add constraint punishment_punishment_statuses_id_fk
        foreign key (punishment_status) references norm.punishment_statuses;

alter table journal.punishment_item
    add constraint punishment_item_punishment_statuses_id_fk
        foreign key (punishment_item_status) references norm.punishment_statuses;

alter table journal.punishment_item
    add constraint punishment_item_punishment_uuid_fk
        foreign key (punishment) references journal.punishment;

alter table journal.punishment_item
    add constraint punishment_item_regulation_docs_uuid_fk
        foreign key (regulation_doc) references norm.regulation_docs;

