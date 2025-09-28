



ALTER TABLE journal.punishment
      DROP COLUMN punishment_status;

ALTER TABLE journal.punishment
      ADD COLUMN punishment_status integer NOT NULL;



ALTER TABLE journal.project_schedule_items
ADD COLUMN measurement integer;

UPDATE journal.project_schedule_items
SET measurement = 0;

ALTER TABLE journal.project_schedule_items
ALTER COLUMN measurement SET NOT NULL;



