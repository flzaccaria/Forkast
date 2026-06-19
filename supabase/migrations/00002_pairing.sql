-- 00002_pairing.sql
-- Abbinamento dei dispositivi (ADR-006) tramite codice generato dal primo
-- telefono. Le RLS filtrano per membership, quindi un dispositivo nuovo NON
-- potrebbe inserirsi da solo nell'household altrui (chicken-and-egg). Queste
-- funzioni SECURITY DEFINER incapsulano l'unica operazione privilegiata,
-- restando chiamabili via supabase.rpc() con il JWT (anonimo) del dispositivo.

-- ------------------------------------------------------------
-- Allinea il vincolo di week_start_day alla convenzione client
-- (DateTime.weekday: 1 = lunedì … 7 = domenica). Lo schema iniziale usava
-- 0..6, incompatibile con i valori scritti oggi dall'app.
-- ------------------------------------------------------------
ALTER TABLE household DROP CONSTRAINT IF EXISTS household_week_start_day_check;
ALTER TABLE household
    ADD CONSTRAINT household_week_start_day_check CHECK (week_start_day BETWEEN 1 AND 7);
ALTER TABLE household ALTER COLUMN week_start_day SET DEFAULT 1;

-- ------------------------------------------------------------
-- create_pairing_code: chiamata dal dispositivo "che invita". Ricava il suo
-- household dalla membership, genera un codice a 6 cifre valido 10 minuti.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_pairing_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_device    UUID := auth.uid();
    v_household UUID;
    v_code      TEXT;
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

    -- Codice a 6 cifre; riprova in caso di collisione sull'indice UNIQUE.
    LOOP
        v_code := lpad((floor(random() * 1000000))::INT::TEXT, 6, '0');
        BEGIN
            INSERT INTO pairing_code (id, household_id, code, expires_at, consumed, created_at)
            VALUES (gen_random_uuid(), v_household, v_code,
                    now() + INTERVAL '10 minutes', FALSE, now());
            EXIT;
        EXCEPTION WHEN unique_violation THEN
            -- riprova con un altro codice
        END;
    END LOOP;

    RETURN v_code;
END;
$$;

-- ------------------------------------------------------------
-- redeem_pairing_code: chiamata dal secondo dispositivo. Valida il codice ed
-- entra nell'household di chi ha invitato ("adotta A"): le membership e gli
-- household vuoti propri del dispositivo vengono rimossi, così da restare a
-- household singolo. Se il dispositivo ha già dati propri si blocca, per non
-- orfanarli.
-- ------------------------------------------------------------
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

    -- Già membro: operazione idempotente.
    IF EXISTS (SELECT 1 FROM membership
               WHERE device_id = v_device AND household_id = v_household) THEN
        UPDATE pairing_code SET consumed = TRUE WHERE code = p_code;
        RETURN v_household;
    END IF;

    -- Blocca se il dispositivo possiede già dati propri (eviterebbe di
    -- orfanarli unendosi a un altro household).
    IF EXISTS (
        SELECT 1 FROM membership m
        WHERE m.device_id = v_device
          AND (
              EXISTS (SELECT 1 FROM dish        d WHERE d.household_id = m.household_id) OR
              EXISTS (SELECT 1 FROM ingredient  i WHERE i.household_id = m.household_id) OR
              EXISTS (SELECT 1 FROM tag         t WHERE t.household_id = m.household_id) OR
              EXISTS (SELECT 1 FROM week_plan   w WHERE w.household_id = m.household_id)
          )
    ) THEN
        RAISE EXCEPTION 'device_has_data';
    END IF;

    -- Rimuove le membership del dispositivo e gli household rimasti senza
    -- membri (i suoi household vuoti del bootstrap).
    FOR v_old IN SELECT household_id FROM membership WHERE device_id = v_device LOOP
        DELETE FROM membership
        WHERE device_id = v_device AND household_id = v_old.household_id;
        IF NOT EXISTS (SELECT 1 FROM membership WHERE household_id = v_old.household_id) THEN
            DELETE FROM household WHERE id = v_old.household_id;
        END IF;
    END LOOP;

    INSERT INTO membership (id, household_id, device_id, role, joined_at, updated_at)
    VALUES (gen_random_uuid(), v_household, v_device, 'member', now(), now());

    UPDATE pairing_code SET consumed = TRUE WHERE code = p_code;

    RETURN v_household;
END;
$$;

GRANT EXECUTE ON FUNCTION create_pairing_code() TO authenticated;
GRANT EXECUTE ON FUNCTION redeem_pairing_code(TEXT) TO authenticated;
