CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.project_statuses
(
    title text    not null,
    id    integer not null
        primary key
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.punishment_statuses
(
    id    integer not null
        primary key,
    title text    not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.report_statuses
(
    title text    not null,
    id    integer not null
        primary key
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.measurements
(
    id    integer not null
        primary key,
    title text    not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.materials
(
    volume                double precision               not null,
    uuid                  uuid default gen_random_uuid() not null
        primary key,
    project_schedule_item uuid                           not null,
    delivery_date         date                           not null,
    measurement           integer                        not null,
    title                 text                           not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.kpgz
(
    id    bigint not null
        primary key,
    title text   not null,
    code  text   not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.work_category
(
    kpgz  integer                        not null,
    uuid  uuid default gen_random_uuid() not null
        primary key,
    title text                           not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.regulation_docs
(
    uuid  uuid default gen_random_uuid() not null
        primary key,
    title text                           not null
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.reports
(
    check_date            date,
    report_date           date                           not null,
    uuid                  uuid default gen_random_uuid() not null
        primary key,
    project_schedule_item uuid                           not null,
    status                integer                        not null
);
