ALTER TABLE journal.punishment
      DROP COLUMN punishment_status;

ALTER TABLE journal.punishment
      ADD COLUMN punishment_status integer NOT NULL;
