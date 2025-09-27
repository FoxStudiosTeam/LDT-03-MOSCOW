





  ALTER TABLE journal.project_schedule_items
    ADD COLUMN title text
      
      
      ;
  UPDATE journal.project_schedule_items
  SET title = 'Some title'
  WHERE title IS NULL;
  ALTER TABLE journal.project_schedule_items
      ALTER COLUMN title SET NOT NULL;






