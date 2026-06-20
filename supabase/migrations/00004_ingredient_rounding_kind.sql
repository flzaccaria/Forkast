-- Explicit rounding behaviour per ingredient (replaces the unit-string
-- allowlist in lib/core/scaling.dart).
--
-- Three kinds:
--   'whole'  — round up to the nearest integer (eggs, cans, bunches…)
--   'weight' — round up: g → nearest 10, kg → nearest 0.1
--   'volume' — round up: ml → nearest 10, l/cl/dl → nearest 0.1
--
-- Backfill is NON-DESTRUCTIVE: existing rows are classified from their
-- current unit string, then the column is made NOT NULL.

-- 1. Add the column as nullable first.
ALTER TABLE ingredient
    ADD COLUMN IF NOT EXISTS rounding_kind TEXT;

-- 2. Backfill from the existing unit.
UPDATE ingredient SET rounding_kind = 'whole'
WHERE rounding_kind IS NULL
  AND lower(trim(unit)) IN (
      'pz', 'pezzo', 'pezzi',
      'fetta', 'fette',
      'spicchio', 'spicchi'
  );

UPDATE ingredient SET rounding_kind = 'volume'
WHERE rounding_kind IS NULL
  AND lower(trim(unit)) IN ('l', 'ml', 'cl', 'dl');

UPDATE ingredient SET rounding_kind = 'weight'
WHERE rounding_kind IS NULL;

-- 3. Now enforce NOT NULL + CHECK.
ALTER TABLE ingredient
    ALTER COLUMN rounding_kind SET NOT NULL;

ALTER TABLE ingredient
    ADD CONSTRAINT ingredient_rounding_kind_check
    CHECK (rounding_kind IN ('whole', 'weight', 'volume'));
