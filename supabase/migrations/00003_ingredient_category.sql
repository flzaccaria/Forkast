-- Supermarket aisle on the ingredient (open point resolved).
--
-- Fixed predefined list on the client side (lib/core/reparto.dart): here the
-- field is a nullable TEXT, with no CHECK, so the evolution of the list remains
-- a product decision in the client and does not require a migration for each
-- aisle. "No aisle" = NULL.

ALTER TABLE ingredient
    ADD COLUMN IF NOT EXISTS category TEXT;
