CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment_item (
  punishment uuid
    
    
     NOT NULL
    ,
  correction_date_fact date
    
    
     NOT NULL
    ,
  correction_date_plan date
    
    
     NOT NULL
    ,
  is_suspend boolean
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  place text
    
    
     NOT NULL
    ,
  correction_date_info text
    
    
     NOT NULL
    ,
  comment text
    
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    ,
  punish_datetime timestamp
    
    
     NOT NULL
    ,
  punishment_item_status integer
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS product;
CREATE TABLE IF NOT EXISTS product.product (
  title text
    
    
     NOT NULL
    ,
  created_at timestamp
    
    
     NOT NULL
     DEFAULT LOCALTIMESTAMP,
  count integer
    
    
     NOT NULL
    ,
  updated_at timestamp
    
    
     NOT NULL
     DEFAULT LOCALTIMESTAMP,
  guid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid()
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.punishment_statuses (
  title text
    
    
     NOT NULL
    ,
  id integer
     PRIMARY KEY
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.measurements (
  title text
    
    
     NOT NULL
    ,
  id integer
     PRIMARY KEY
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment (
  custom_number text
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  punish_datetime timestamp
    
    
     NOT NULL
    ,
  project uuid
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS attachment;
CREATE TABLE IF NOT EXISTS attachment.attachments (
  base_entity_uuid uuid
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  content_type text
    
    
     NOT NULL
    ,
  original_filename text
    
    
     NOT NULL
    ,
  file_uuid uuid
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule_items (
  is_draft boolean
    
    
     NOT NULL
    ,
  updated_by uuid
    
    
     NOT NULL
    ,
  is_completed boolean
    
    
     NOT NULL
    ,
  created_by uuid
    
    
     NOT NULL
    ,
  target_volume float8
    
    
     NOT NULL
    ,
  work_uuid uuid
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  end_date date
    
    
     NOT NULL
    ,
  start_date date
    
    
     NOT NULL
    ,
  project_schedule_uuid uuid
    
    
     NOT NULL
    ,
  is_deleted boolean
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.work_category (
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    ,
  kpgz integer
    
    
     NOT NULL
    ,
  id integer
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.project (
  polygon jsonb
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  foreman uuid
    
    
     NOT NULL
    ,
  iko uuid
    
    
     NOT NULL
    ,
  ssk uuid
    
    
     NOT NULL
    ,
  address text
    
    
     NOT NULL
    ,
  status integer
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.kpgz (
  code text
    
    
     NOT NULL
    ,
  id integer
     PRIMARY KEY
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.materials (
  measurement integer
    
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    ,
  volume float8
    
    
     NOT NULL
    ,
  project_schedule_item uuid
    
    
     NOT NULL
    ,
  delivery_date date
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.works (
  title text
    
    
     NOT NULL
    ,
  work_category uuid
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule (
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
    ,
  start_date date
    
    
     NOT NULL
    ,
  end_date date
    
    
     NOT NULL
    ,
  project_uuid uuid
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.project_statuses (
  title text
    
    
     NOT NULL
    ,
  id integer
     PRIMARY KEY
    
     NOT NULL
    
);


