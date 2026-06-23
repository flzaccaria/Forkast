-- P6: Support for seed ingredient catalog at household creation.

-- 1. Add seeded_at column to household.
-- Non-null once the ingredient catalog has been seeded for this household.
-- The flag propagates via sync so paired devices skip seeding.
ALTER TABLE household ADD COLUMN seeded_at TIMESTAMPTZ;

-- 2. Update redeem_pairing_code to exclude ingredients and tags from the
-- "device_has_data" check. Seed ingredients are auto-populated at household
-- creation and should not block a device from pairing. Only user-created
-- content (dishes, week_plans) constitutes real data worth protecting.
CREATE OR REPLACE FUNCTION redeem_pairing_code(p_code TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_device    UUID := auth.uid();
    v_household UUID;
    v_old       RECORD;
BEGIN
    IF v_device IS NULL THEN
        RAISE EXCEPTION 'not_authenticated';
    END IF;

    SELECT household_id INTO v_household
    FROM pairing_code
    WHERE code = p_code
      AND consumed = FALSE
      AND expires_at > now()
    FOR UPDATE;

    IF v_household IS NULL THEN
        RAISE EXCEPTION 'invalid_or_expired_code';
    END IF;

    -- Already a member: idempotent operation.
    IF EXISTS (SELECT 1 FROM membership
               WHERE device_id = v_device AND household_id = v_household) THEN
        UPDATE pairing_code SET consumed = TRUE WHERE code = p_code;
        RETURN v_household;
    END IF;

    -- Block if the device already owns user-created content (dishes or plans).
    -- Ingredients and tags are excluded: they may be auto-populated seed data
    -- and losing them on pairing is acceptable.
    IF EXISTS (
        SELECT 1 FROM membership m
        WHERE m.device_id = v_device
          AND (
              EXISTS (SELECT 1 FROM dish      d WHERE d.household_id = m.household_id) OR
              EXISTS (SELECT 1 FROM week_plan w WHERE w.household_id = m.household_id)
          )
    ) THEN
        RAISE EXCEPTION 'device_has_data';
    END IF;

    -- Remove the device's memberships and any households left without members
    -- (its empty bootstrap households). Cascade-clean orphaned seed data.
    FOR v_old IN SELECT household_id FROM membership WHERE device_id = v_device LOOP
        DELETE FROM membership
        WHERE device_id = v_device AND household_id = v_old.household_id;
        IF NOT EXISTS (SELECT 1 FROM membership WHERE household_id = v_old.household_id) THEN
            DELETE FROM ingredient WHERE household_id = v_old.household_id;
            DELETE FROM tag WHERE household_id = v_old.household_id;
            DELETE FROM household WHERE id = v_old.household_id;
        END IF;
    END LOOP;

    INSERT INTO membership (id, household_id, device_id, role, joined_at, updated_at)
    VALUES (gen_random_uuid(), v_household, v_device, 'member', now(), now());

    UPDATE pairing_code SET consumed = TRUE WHERE code = p_code;

    RETURN v_household;
END;
$$;
