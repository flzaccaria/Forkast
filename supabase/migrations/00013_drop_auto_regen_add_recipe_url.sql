-- Migration 00013: drop unused auto_regen from household, add recipe_url to dish
--
-- auto_regen was never read by the regeneration logic (FR-21 v0.6: always
-- automatic and invisible). Removing dead column.
--
-- recipe_url: optional link to an external recipe (FR-14 / P9).

-- 1. Drop auto_regen from household
ALTER TABLE household DROP COLUMN IF EXISTS auto_regen;

-- 2. Update bootstrap function to remove auto_regen from INSERT.
--    Must DROP first because the original returns UUID and CREATE OR REPLACE
--    cannot change the return type (Postgres error 42P13).
DROP FUNCTION IF EXISTS bootstrap_household();
CREATE FUNCTION bootstrap_household()
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_device    UUID := auth.uid();
  v_household UUID;
BEGIN
  IF v_device IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT household_id INTO v_household FROM membership WHERE device_id = v_device LIMIT 1;
  IF v_household IS NOT NULL THEN RETURN v_household; END IF;
  v_household := gen_random_uuid();
  INSERT INTO household (id, default_guests, week_start_day, created_at, updated_at)
    VALUES (v_household, 4, 1, now(), now());
  INSERT INTO membership (id, household_id, device_id, role, joined_at, updated_at)
    VALUES (gen_random_uuid(), v_household, v_device, 'member', now(), now());
  RETURN v_household;
END $$;
REVOKE ALL ON FUNCTION bootstrap_household() FROM public;
GRANT EXECUTE ON FUNCTION bootstrap_household() TO authenticated;

-- 3. Add recipe_url to dish
ALTER TABLE dish ADD COLUMN IF NOT EXISTS recipe_url TEXT;
