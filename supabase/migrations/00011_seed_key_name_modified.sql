-- L2: Add seed_key and name_modified to ingredient and dish tables.
-- seed_key is a stable slug identifying seeded content for localization.
-- name_modified flags that the user renamed a seeded entry (stops auto-translation).

ALTER TABLE ingredient ADD COLUMN seed_key TEXT;
ALTER TABLE ingredient ADD COLUMN name_modified BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE dish ADD COLUMN seed_key TEXT;
ALTER TABLE dish ADD COLUMN name_modified BOOLEAN NOT NULL DEFAULT false;
