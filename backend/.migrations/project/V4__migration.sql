

  ALTER TABLE project.project
    DROP COLUMN ssk;


  ALTER TABLE project.project
    ADD COLUMN created_at timestamp
      
      
       NOT NULL
       DEFAULT LOCALTIMESTAMP;




