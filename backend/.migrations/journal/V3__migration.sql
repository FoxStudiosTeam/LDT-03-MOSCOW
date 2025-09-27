ALTER TABLE journal.project_schedule_items
  DROP CONSTRAINT project_schedule_items_works_uuid_fk;


  ALTER TABLE journal.project_schedule_items
    DROP COLUMN work_uuid;






  ALTER TABLE journal.project_schedule
    ADD COLUMN work_uuid uuid
      ;
  alter table journal.project_schedule
    add constraint project_schedule_works_uuid_fk
        foreign key (work_uuid) references norm.works;


UPDATE journal.project_schedule
  SET work_uuid = '9de7154d-f217-4aad-81e3-9133acbf92ef'
  WHERE work_uuid IS NULL;

  ALTER TABLE journal.project_schedule
      ALTER COLUMN work_uuid SET NOT NULL;

