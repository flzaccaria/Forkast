-- 00006: fix infinite recursion in RLS (42P17) + sblocca il bootstrap.

CREATE OR REPLACE FUNCTION auth_household_ids()
RETURNS SETOF UUID
LANGUAGE sql SECURITY DEFINER SET search_path = public STABLE AS $$
  SELECT household_id FROM membership WHERE device_id = auth.uid();
$$;
REVOKE ALL ON FUNCTION auth_household_ids() FROM public;
GRANT EXECUTE ON FUNCTION auth_household_ids() TO authenticated;

-- household: un device può creare il proprio primo household (vuoto), poi si auto-aggiunge.
DROP POLICY IF EXISTS household_access ON household;
CREATE POLICY household_select ON household FOR SELECT USING (id IN (SELECT auth_household_ids()));
CREATE POLICY household_insert ON household FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY household_update ON household FOR UPDATE USING (id IN (SELECT auth_household_ids())) WITH CHECK (id IN (SELECT auth_household_ids()));
CREATE POLICY household_delete ON household FOR DELETE USING (id IN (SELECT auth_household_ids()));

-- membership: niente auto-riferimento; consenti di aggiungere te stesso (bootstrap) o altri al tuo household.
DROP POLICY IF EXISTS membership_access ON membership;
CREATE POLICY membership_select ON membership FOR SELECT USING (household_id IN (SELECT auth_household_ids()));
CREATE POLICY membership_insert ON membership FOR INSERT WITH CHECK (device_id = auth.uid() OR household_id IN (SELECT auth_household_ids()));
CREATE POLICY membership_update ON membership FOR UPDATE USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
CREATE POLICY membership_delete ON membership FOR DELETE USING (household_id IN (SELECT auth_household_ids()));

-- tutte le altre tabelle: stessa logica di prima, ma via funzione (nessun cambio di comportamento, nessuna ricorsione).
DROP POLICY IF EXISTS ingredient_access       ON ingredient;
CREATE POLICY ingredient_access       ON ingredient       FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS tag_access             ON tag;
CREATE POLICY tag_access              ON tag              FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS dish_access            ON dish;
CREATE POLICY dish_access             ON dish             FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS dish_tag_access        ON dish_tag;
CREATE POLICY dish_tag_access         ON dish_tag         FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS dish_ingredient_access ON dish_ingredient;
CREATE POLICY dish_ingredient_access  ON dish_ingredient  FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS week_plan_access      ON week_plan;
CREATE POLICY week_plan_access        ON week_plan        FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS plan_day_access       ON plan_day;
CREATE POLICY plan_day_access         ON plan_day         FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS plan_day_dish_access  ON plan_day_dish;
CREATE POLICY plan_day_dish_access    ON plan_day_dish    FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS shopping_list_access  ON shopping_list;
CREATE POLICY shopping_list_access    ON shopping_list    FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS list_generated_row_access ON list_generated_row;
CREATE POLICY list_generated_row_access ON list_generated_row FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS list_override_access  ON list_override;
CREATE POLICY list_override_access    ON list_override    FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS list_manual_item_access ON list_manual_item;
CREATE POLICY list_manual_item_access ON list_manual_item FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));
DROP POLICY IF EXISTS list_check_access     ON list_check;
CREATE POLICY list_check_access       ON list_check       FOR ALL USING (household_id IN (SELECT auth_household_ids())) WITH CHECK (household_id IN (SELECT auth_household_ids()));