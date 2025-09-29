CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule
(
    start_date   date,
    uuid         uuid default gen_random_uuid() not null
        primary key,
    end_date     date,
    project_uuid uuid                           not null,
    work_category    uuid                           not null
);

CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment
(
    custom_number     text,
    project           uuid                           not null,
    punish_datetime   timestamp                      not null,
    uuid              uuid default gen_random_uuid() not null
        primary key,
    punishment_status integer                        not null
);

CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment_item
(
    punishment             uuid                           not null,
    uuid                   uuid default gen_random_uuid() not null
        primary key,
    correction_date_fact   date,
    correction_date_info   text,
    is_suspend             boolean                        not null,
    comment                text,
    punish_datetime        timestamp                      not null,
    regulation_doc         uuid,
    correction_date_plan   date                           not null,
    title                  text                           not null,
    punishment_item_status integer                        not null,
    place                  text                           not null
);

CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule_items
(
    project_schedule_uuid uuid                           not null,
    created_by            uuid                           not null,
    is_completed          boolean                        not null,
    uuid                  uuid default gen_random_uuid() not null
        primary key,
    start_date            date                           not null,
    end_date              date                           not null,
    target_volume         double precision               not null,
    updated_by            uuid,
    is_draft              boolean                        not null,
    is_deleted            boolean                        not null,
    measurement           integer                        not null,
    title                 text                           not null
);