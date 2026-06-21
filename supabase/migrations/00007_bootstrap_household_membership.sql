-- 00007: bootstrap household+membership via SECURITY DEFINER (no RLS chicken-and-egg).
CREATE OR REPLACE FUNCTION bootstrap_household()
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_device    UUID := auth.uid();
  v_household UUID;
BEGIN
  IF v_device IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT household_id INTO v_household FROM membership WHERE device_id = v_device LIMIT 1;
  IF v_household IS NOT NULL THEN RETURN v_household; END IF;   -- idempotente
  v_household := gen_random_uuid();
  INSERT INTO household (id, default_guests, week_start_day, auto_regen, created_at, updated_at)
    VALUES (v_household, 4, 1, false, now(), now());
  INSERT INTO membership (id, household_id, device_id, role, joined_at, updated_at)
    VALUES (gen_random_uuid(), v_household, v_device, 'member', now(), now());
  RETURN v_household;
END $$;
REVOKE ALL ON FUNCTION bootstrap_household() FROM public;
GRANT EXECUTE ON FUNCTION bootstrap_household() TO authenticated;