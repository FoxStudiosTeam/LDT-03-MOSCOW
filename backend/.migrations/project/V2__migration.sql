




    ALTER TABLE project.project
      ALTER COLUMN polygon TYPE jsonb;

    ALTER TABLE project.project
      ALTER COLUMN polygon SET NOT NULL;



    ALTER TABLE project.project
      ALTER COLUMN address TYPE text;

    ALTER TABLE project.project
      ALTER COLUMN address SET NOT NULL;






