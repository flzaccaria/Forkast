-- Make rounding_kind optional on ingredient, aligned with category (already nullable).
-- Eliminates Postgres error 23502 when a client syncs an ingredient without
-- rounding_kind (e.g. q.b. items seeded before the fix).
-- The CHECK is updated to allow NULL alongside the three valid values.

ALTER TABLE ingredient
    ALTER COLUMN rounding_kind DROP NOT NULL;

ALTER TABLE ingredient
    DROP CONSTRAINT IF EXISTS ingredient_rounding_kind_check;

ALTER TABLE ingredient
    ADD CONSTRAINT ingredient_rounding_kind_check
    CHECK (rounding_kind IS NULL OR rounding_kind IN ('whole', 'weight', 'volume'));
