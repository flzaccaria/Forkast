-- Add difficulty and time_estimate columns to dish (FR-14 v0.6).
-- Both are optional single-choice fields from fixed enums:
--   difficulty: 'facile', 'medio', 'difficile'
--   time_estimate: 'veloce', 'medio', 'lento'
ALTER TABLE dish ADD COLUMN difficulty TEXT;
ALTER TABLE dish ADD COLUMN time_estimate TEXT;

-- Old "attributo" tags and their dish_tag links are NOT deleted.
-- They remain in the database as archived data, no longer surfaced in the UI.
-- If a free-form tagging feature is reintroduced, they can be recovered from
-- the tag table (WHERE "group" = 'attributo') and the dish_tag join rows.
