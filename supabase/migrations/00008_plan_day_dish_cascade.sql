-- Add ON DELETE CASCADE to plan_day_dish.dish_id → dish(id).
--
-- dish_ingredient and dish_tag already cascade; plan_day_dish was missing it.
-- The repository deletes plan_day_dish rows before the dish today, but the FK
-- should be a safety net in case a dish is ever removed by another path.

ALTER TABLE plan_day_dish
    DROP CONSTRAINT plan_day_dish_dish_id_fkey,
    ADD  CONSTRAINT plan_day_dish_dish_id_fkey
         FOREIGN KEY (dish_id) REFERENCES dish(id) ON DELETE CASCADE;
