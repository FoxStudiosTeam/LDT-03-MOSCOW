



CREATE SCHEMA IF NOT EXISTS product;
CREATE TABLE IF NOT EXISTS product.product (
  title text
    
    
     NOT NULL
    ,
  guid uuid
     PRIMARY KEY
    
     NOT NULL
     DEFAULT gen_random_uuid(),
  updated_at timestamp
    
    
     NOT NULL
     DEFAULT LOCALTIMESTAMP,
  created_at timestamp
    
    
     NOT NULL
     DEFAULT LOCALTIMESTAMP,
  count integer
    
    
     NOT NULL
    
);
