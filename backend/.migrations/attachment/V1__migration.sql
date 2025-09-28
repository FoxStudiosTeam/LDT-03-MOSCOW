CREATE SCHEMA IF NOT EXISTS attachment;
CREATE TABLE IF NOT EXISTS attachment.attachments
(
    original_filename text                           not null,
    uuid              uuid default gen_random_uuid() not null
        primary key,
    base_entity_uuid  uuid                           not null,
    file_uuid         uuid                           not null,
    content_type      text
);
