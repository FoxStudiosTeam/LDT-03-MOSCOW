  

  ALTER TABLE norm.materials
    DROP COLUMN project_schedule_item;


  ALTER TABLE norm.materials
    ADD COLUMN project uuid;
  
  UPDATE norm.materials
    SET project = '62930a96-2431-438c-8162-56962eec4ba9' WHERE project IS NULL;
      
  ALTER TABLE norm.materials
    ALTER COLUMN project SET NOT NULL
      ;


alter table norm.materials
    add constraint materials_project_uuid_fk
        foreign key (project) references project.project;