    ALTER TABLE journal.project_schedule_items
      ALTER COLUMN updated_by TYPE uuid;

    ALTER TABLE journal.project_schedule_items
      ALTER COLUMN updated_by DROP NOT NULL;

    ALTER TABLE journal.punishment
      ALTER COLUMN custom_number TYPE text;

    ALTER TABLE journal.punishment
      ALTER COLUMN custom_number DROP NOT NULL;

    ALTER TABLE attachment.attachments
      ALTER COLUMN content_type TYPE text;

    ALTER TABLE attachment.attachments
      ALTER COLUMN content_type DROP NOT NULL;

    ALTER TABLE journal.project_schedule
      ALTER COLUMN start_date TYPE date;

    ALTER TABLE journal.project_schedule
      ALTER COLUMN start_date DROP NOT NULL;

    ALTER TABLE journal.project_schedule
      ALTER COLUMN end_date TYPE date;

    ALTER TABLE journal.project_schedule
      ALTER COLUMN end_date DROP NOT NULL;

    ALTER TABLE norm.work_category
      ALTER COLUMN id TYPE integer;

    ALTER TABLE norm.work_category
      ALTER COLUMN id DROP NOT NULL;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN correction_date_fact TYPE date;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN correction_date_fact DROP NOT NULL;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN correction_date_info TYPE text;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN correction_date_info DROP NOT NULL;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN comment TYPE text;

    ALTER TABLE journal.punishment_item
      ALTER COLUMN comment DROP NOT NULL;

    ALTER TABLE journal.punishment_item
      ADD COLUMN regulation_doc uuid;

    ALTER TABLE project.project
      DROP COLUMN iko;

    ALTER TABLE project.project
      ALTER COLUMN polygon TYPE jsonb;

    ALTER TABLE project.project
      ALTER COLUMN polygon DROP NOT NULL;

    ALTER TABLE project.project
      ALTER COLUMN foreman TYPE uuid;

    ALTER TABLE project.project
      ALTER COLUMN foreman DROP NOT NULL;

    ALTER TABLE project.project
      ALTER COLUMN address TYPE text;

    ALTER TABLE project.project
      ALTER COLUMN address DROP NOT NULL;

    ALTER TABLE project.project
      ALTER COLUMN ssk TYPE uuid;

    ALTER TABLE project.project
      ALTER COLUMN ssk DROP NOT NULL;

CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.iko_relationship (
  project uuid NOT NULL,
  user_uuid uuid,
  uuid uuid PRIMARY KEY NOT NULL
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.regulation_docs (
  uuid uuid PRIMARY KEY NOT NULL,
  title text
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.reports (
  check_date date,
  report_date date NOT NULL,
  uuid uuid PRIMARY KEY NOT NULL,
  project_schedule_item uuid NOT NULL,
  status integer NOT NULL
);

CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.report_statuses (
  title text NOT NULL,
  id integer PRIMARY KEY NOT NULL
);
