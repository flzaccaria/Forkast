-- Return the expiry alongside the code so the client does not need to
-- hardcode the validity duration.
--
-- CREATE OR REPLACE cannot change the return type of an existing function,
-- so we DROP first and recreate.

DROP FUNCTION IF EXISTS create_pairing_code();

CREATE FUNCTION create_pairing_code()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_device     UUID := auth.uid();
    v_household  UUID;
    v_code       TEXT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    IF v_device IS NULL THEN
        RAISE EXCEPTION 'not_authenticated';
    END IF;

    SELECT household_id INTO v_household
    FROM membership
    WHERE device_id = v_device
    LIMIT 1;

    IF v_household IS NULL THEN
        RAISE EXCEPTION 'no_household';
    END IF;

    v_expires_at := now() + INTERVAL '10 minutes';

    LOOP
        v_code := lpad((floor(random() * 1000000))::INT::TEXT, 6, '0');
        BEGIN
            INSERT INTO pairing_code (id, household_id, code, expires_at, consumed, created_at)
            VALUES (gen_random_uuid(), v_household, v_code,
                    v_expires_at, FALSE, now());
            EXIT;
        EXCEPTION WHEN unique_violation THEN
            -- retry with another code
        END;
    END LOOP;

    RETURN json_build_object('code', v_code, 'expires_at', v_expires_at);
END;
$$;

GRANT EXECUTE ON FUNCTION create_pairing_code() TO authenticated;
