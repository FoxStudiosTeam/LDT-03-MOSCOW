



CREATE SCHEMA IF NOT EXISTS attachment;
CREATE TABLE IF NOT EXISTS attachment.attachments (
  original_filename text
    
    
     NOT NULL
    ,
  uuid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  base_entity_uuid uuid
    
    
     NOT NULL
    ,
  file_uuid uuid
    
    
     NOT NULL
    ,
  content_type text
    
    
    
    
);
