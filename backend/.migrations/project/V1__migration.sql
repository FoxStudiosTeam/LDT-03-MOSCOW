



CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.project (
  status integer
    
    
     NOT NULL
    ,
  polygon jsonb
    
    
    
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  foreman uuid
    
    
    
    ,
  address text
    
    
    
    ,
  ssk uuid
    
    
    
    
);
CREATE SCHEMA IF NOT EXISTS project;
CREATE TABLE IF NOT EXISTS project.iko_relationship (
  project uuid
    
    
     NOT NULL
    ,
  user_uuid uuid
    
    
    
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid()
);
