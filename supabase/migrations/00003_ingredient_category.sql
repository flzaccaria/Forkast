-- Reparto del supermercato sull'ingrediente (punto aperto risolto).
--
-- Lista fissa predefinita lato client (lib/core/reparto.dart): qui il campo è
-- un TEXT nullable, senza CHECK, così l'evoluzione dell'elenco resta una scelta
-- di prodotto nel client e non richiede una migrazione per ogni reparto.
-- "Senza reparto" = NULL.

ALTER TABLE ingredient
    ADD COLUMN IF NOT EXISTS category TEXT;
