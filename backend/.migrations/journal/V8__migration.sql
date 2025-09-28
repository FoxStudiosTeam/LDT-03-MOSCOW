  ALTER TABLE journal.project_schedule
    ADD COLUMN work_category uuid;

UPDATE journal.project_schedule
  SET work_category = 'e69da216-707d-4a2e-83bd-16c2c539d8f0'
  WHERE work_category IS NULL;
  
ALTER TABLE journal.project_schedule
  ALTER COLUMN work_category
  SET NOT NULL;

ALTER TABLE journal.project_schedule
  ADD CONSTRAINT project_schedule_work_category_fk
  FOREIGN KEY (work_category)
  REFERENCES norm.work_category (uuid);







