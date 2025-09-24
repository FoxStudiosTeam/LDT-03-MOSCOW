



CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment_item (
  punishment uuid
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  correction_date_fact date
    
    
    
    ,
  correction_date_info text
    
    
    
    ,
  is_suspend boolean
    
    
     NOT NULL
    ,
  comment text
    
    
    
    ,
  punish_datetime timestamp
    
    
     NOT NULL
    ,
  regulation_doc uuid
    
    
    
    ,
  correction_date_plan date
    
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    ,
  punishment_item_status integer
    
    
     NOT NULL
    ,
  place text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule_items (
  project_schedule_uuid uuid
    
    
     NOT NULL
    ,
  created_by uuid
    
    
     NOT NULL
    ,
  is_completed boolean
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  work_uuid uuid
    
    
     NOT NULL
    ,
  start_date date
    
    
     NOT NULL
    ,
  end_date date
    
    
     NOT NULL
    ,
  target_volume float8
    
    
     NOT NULL
    ,
  updated_by uuid
    
    
    
    ,
  is_draft boolean
    
    
     NOT NULL
    ,
  is_deleted boolean
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.punishment (
  custom_number text
    
    
    
    ,
  project uuid
    
    
     NOT NULL
    ,
  punish_datetime timestamp
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid()
);
CREATE SCHEMA IF NOT EXISTS journal;
CREATE TABLE IF NOT EXISTS journal.project_schedule (
  start_date date
    
    
    
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  end_date date
    
    
    
    ,
  project_uuid uuid
    
    
     NOT NULL
    
);
