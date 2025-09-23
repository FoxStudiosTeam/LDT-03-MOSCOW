



CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.measurements (
  id integer
     PRIMARY KEY
    
     NOT NULL
    ,
  title text
    
    
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
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.punishment_statuses (
  id integer
     PRIMARY KEY
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.work_category (
  kpgz integer
    
    
     NOT NULL
    ,
  id integer
    
    
    
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  title text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.works (
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  work_category uuid
    
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.regulation_docs (
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  title text
    
    
    
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.kpgz (
  id bigint
     PRIMARY KEY
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    ,
  code text
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.report_statuses (
  title text
    
    
     NOT NULL
    ,
  id integer
     PRIMARY KEY
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.reports (
  check_date date
    
    
    
    ,
  report_date date
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  project_schedule_item uuid
    
    
     NOT NULL
    ,
  status integer
    
    
     NOT NULL
    
);
CREATE SCHEMA IF NOT EXISTS norm;
CREATE TABLE IF NOT EXISTS norm.materials (
  volume float8
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  project_schedule_item uuid
    
    
     NOT NULL
    ,
  delivery_date date
    
    
     NOT NULL
    ,
  measurement integer
    
    
     NOT NULL
    ,
  title text
    
    
     NOT NULL
    
);
