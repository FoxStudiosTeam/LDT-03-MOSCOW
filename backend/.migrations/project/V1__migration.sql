CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.project
(
    status     integer                           not null,
    polygon    jsonb                             not null,
    uuid       uuid    default gen_random_uuid() not null
        primary key,
    foreman    uuid,
    address    text                              not null,
    ssk        uuid,
    is_active  boolean default false             not null,
    created_by uuid
);

CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.iko_relationship
(
    project   uuid                           not null,
    user_uuid uuid,
    uuid      uuid default gen_random_uuid() not null
        primary key
);
