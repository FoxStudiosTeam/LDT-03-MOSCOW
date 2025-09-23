


    ALTER TABLE journal.punishment
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE journal.punishment
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();




    ALTER TABLE journal.project_schedule
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE journal.project_schedule
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();








    ALTER TABLE norm.regulation_docs
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE norm.regulation_docs
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();


    ALTER TABLE project.iko_relationship
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE project.iko_relationship
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();
      
      
      
      ;

    ALTER TABLE norm.reports
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE norm.reports
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();






    ALTER TABLE journal.punishment_item
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE journal.punishment_item
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();




    ALTER TABLE norm.works
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE norm.works
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();




    ALTER TABLE norm.work_category
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE norm.work_category
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();








    ALTER TABLE norm.materials
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE norm.materials
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();




    ALTER TABLE attachment.attachments
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE attachment.attachments
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();




    ALTER TABLE project.project
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE project.project
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();






    ALTER TABLE journal.project_schedule_items
      ALTER COLUMN uuid TYPE uuid;


    ALTER TABLE journal.project_schedule_items
      ALTER COLUMN uuid SET DEFAULT gen_random_uuid();





