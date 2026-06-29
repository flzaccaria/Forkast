-- Migration 00014: P14 auto_assigned on plan_day_dish + P15 recurring ingredients
--
-- P14: tracks which dishes were auto-inserted by "Sorprendimi" for undo support.
-- P15: always_in_list + default_qty on ingredient; list_recurring_exclusion table
--      for per-week suppression of recurring items.

-- 1. P14: auto_assigned flag on plan_day_dish
ALTER TABLE plan_day_dish ADD COLUMN IF NOT EXISTS auto_assigned BOOLEAN DEFAULT false;

-- 2. P15: recurring ingredient fields
ALTER TABLE ingredient ADD COLUMN IF NOT EXISTS always_in_list BOOLEAN DEFAULT false;
ALTER TABLE ingredient ADD COLUMN IF NOT EXISTS default_qty REAL;

-- 3. P15: per-week recurring exclusion
CREATE TABLE IF NOT EXISTS list_recurring_exclusion (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id    UUID         NOT NULL REFERENCES shopping_list(id),
    ingredient_id       UUID         NOT NULL REFERENCES ingredient(id),
    household_id        UUID         NOT NULL,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(shopping_list_id, ingredient_id)
);

CREATE INDEX IF NOT EXISTS idx_list_recurring_exclusion_list
    ON list_recurring_exclusion(shopping_list_id);

-- 4. RLS on list_recurring_exclusion
ALTER TABLE list_recurring_exclusion ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_own_household" ON list_recurring_exclusion
    FOR SELECT USING (household_id IN (SELECT auth_household_ids()));
CREATE POLICY "insert_own_household" ON list_recurring_exclusion
    FOR INSERT WITH CHECK (household_id IN (SELECT auth_household_ids()));
CREATE POLICY "update_own_household" ON list_recurring_exclusion
    FOR UPDATE USING (household_id IN (SELECT auth_household_ids()));
CREATE POLICY "delete_own_household" ON list_recurring_exclusion
    FOR DELETE USING (household_id IN (SELECT auth_household_ids()));

-- 5. PowerSync publication
ALTER PUBLICATION powersync ADD TABLE list_recurring_exclusion;
