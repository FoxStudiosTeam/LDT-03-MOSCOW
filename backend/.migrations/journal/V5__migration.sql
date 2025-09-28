
ALTER TABLE journal.project_schedule_items
  DROP COLUMN title;

ALTER TABLE journal.project_schedule
  DROP CONSTRAINT project_schedule_works_uuid_fk;

ALTER TABLE journal.project_schedule
  DROP COLUMN work_uuid;

ALTER TABLE journal.project_schedule_items
  ADD COLUMN work_uuid uuid
      ;

UPDATE journal.project_schedule_items
  SET work_uuid = '9de7154d-f217-4aad-81e3-9133acbf92ef'
  WHERE work_uuid IS NULL;

ALTER TABLE journal.project_schedule_items
  ALTER COLUMN work_uuid SET NOT NULL;
  

alter table journal.project_schedule_items
    add constraint project_schedule_items_works_uuid_fk
        foreign key (work_uuid) references norm.works;






