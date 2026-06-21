-- Server-side household bootstrap (replaces the client-side local insert).
--
-- The old flow inserted household + membership locally in drift and let
-- PowerSync upload them, but RLS blocks the upload because the device is not
-- yet a member of any household (chicken-and-egg → 403 on household).
--
-- This SECURITY DEFINER function creates both rows atomically under elevated
-- privileges — the same pattern used for pairing (00002_pairing.sql).
-- Idempotent: if the device already has a membership, it returns the existing
-- household_id without creating anything.

CREATE OR REPLACE FUNCTION bootstrap_household()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_device    UUID := auth.uid();
    v_household UUID;
BEGIN
    IF v_device IS NULL THEN
        RAISE EXCEPTION 'not_authenticated';
    END IF;

    -- Idempotent: if already a member, return existing household.
    SELECT household_id INTO v_household
    FROM membership
    WHERE device_id = v_device
    LIMIT 1;

    IF v_household IS NOT NULL THEN
        RETURN v_household;
    END IF;

    -- Create household + membership atomically.
    v_household := gen_random_uuid();

    INSERT INTO household (id, default_guests, week_start_day, auto_regen,
                           created_at, updated_at)
    VALUES (v_household, 4, 1, FALSE, now(), now());

    INSERT INTO membership (id, household_id, device_id, role,
                            joined_at, updated_at)
    VALUES (gen_random_uuid(), v_household, v_device, 'member', now(), now());

    RETURN v_household;
END;
$$;

GRANT EXECUTE ON FUNCTION bootstrap_household() TO authenticated;
