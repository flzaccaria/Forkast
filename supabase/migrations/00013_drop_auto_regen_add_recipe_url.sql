-- Migration 00013: drop unused auto_regen from household, add recipe_url to dish
--
-- auto_regen was never read by the regeneration logic (FR-21 v0.6: always
-- automatic and invisible). Removing dead column.
--
-- recipe_url: optional link to an external recipe (FR-14 / P9).

-- 1. Drop auto_regen from household
ALTER TABLE household DROP COLUMN IF EXISTS auto_regen;

-- 2. Update bootstrap function to remove auto_regen from INSERT
CREATE OR REPLACE FUNCTION bootstrap_household()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_device_id uuid := auth.uid();
  v_household_id uuid;
BEGIN
  -- Idempotent: if the device already has a membership, do nothing.
  IF EXISTS (SELECT 1 FROM public.membership WHERE device_id = v_device_id) THEN
    RETURN;
  END IF;

  v_household_id := gen_random_uuid();

  INSERT INTO public.household (id, default_guests, week_start_day, created_at, updated_at)
  VALUES (v_household_id, 4, 0, now(), now());

  INSERT INTO public.membership (id, household_id, device_id, role, joined_at, updated_at)
  VALUES (gen_random_uuid(), v_household_id, v_device_id, 'owner', now(), now());
END;
$$;

-- 3. Add recipe_url to dish
ALTER TABLE dish ADD COLUMN IF NOT EXISTS recipe_url TEXT;
