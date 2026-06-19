-- 00001_initial_schema.sql
-- Initial schema: all tables with household_id, client-generated UUIDs, LWW timestamps.

-- ============================================================
-- household
-- ============================================================
CREATE TABLE household (
    id              UUID PRIMARY KEY,
    name            TEXT,
    default_guests  INT          NOT NULL DEFAULT 4,
    week_start_day  INT          NOT NULL DEFAULT 0 CHECK (week_start_day BETWEEN 0 AND 6),
    auto_regen      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ============================================================
-- membership
-- ============================================================
CREATE TABLE membership (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    device_id       UUID         NOT NULL,
    role            TEXT         NOT NULL DEFAULT 'member',
    joined_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_membership_household ON membership(household_id);
CREATE INDEX idx_membership_device    ON membership(device_id);

-- ============================================================
-- pairing_code  (server-side only, NOT synced via PowerSync)
-- ============================================================
CREATE TABLE pairing_code (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    code            TEXT         NOT NULL UNIQUE,
    expires_at      TIMESTAMPTZ  NOT NULL,
    consumed        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_pairing_code_household ON pairing_code(household_id);

-- ============================================================
-- ingredient
-- ============================================================
CREATE TABLE ingredient (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    name            TEXT         NOT NULL,
    unit            TEXT         NOT NULL,
    is_qb           BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(household_id, name)
);

CREATE INDEX idx_ingredient_household ON ingredient(household_id);

-- ============================================================
-- tag
-- ============================================================
CREATE TABLE tag (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    name            TEXT         NOT NULL,
    "group"         TEXT         NOT NULL CHECK ("group" IN ('portata', 'attributo')),
    color           TEXT,
    sort_order      INT          NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(household_id, name)
);

CREATE INDEX idx_tag_household ON tag(household_id);

-- ============================================================
-- dish
-- ============================================================
CREATE TABLE dish (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    name            TEXT         NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_dish_household ON dish(household_id);

-- ============================================================
-- dish_tag
-- ============================================================
CREATE TABLE dish_tag (
    id              UUID PRIMARY KEY,
    dish_id         UUID         NOT NULL REFERENCES dish(id) ON DELETE CASCADE,
    tag_id          UUID         NOT NULL REFERENCES tag(id) ON DELETE CASCADE,
    household_id    UUID         NOT NULL REFERENCES household(id),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(dish_id, tag_id)
);

CREATE INDEX idx_dish_tag_household ON dish_tag(household_id);
CREATE INDEX idx_dish_tag_dish      ON dish_tag(dish_id);

-- ============================================================
-- dish_ingredient
-- ============================================================
CREATE TABLE dish_ingredient (
    id              UUID PRIMARY KEY,
    dish_id         UUID         NOT NULL REFERENCES dish(id) ON DELETE CASCADE,
    ingredient_id   UUID         NOT NULL REFERENCES ingredient(id),
    household_id    UUID         NOT NULL REFERENCES household(id),
    qty_base4       REAL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(dish_id, ingredient_id)
);

CREATE INDEX idx_dish_ingredient_household  ON dish_ingredient(household_id);
CREATE INDEX idx_dish_ingredient_dish       ON dish_ingredient(dish_id);
CREATE INDEX idx_dish_ingredient_ingredient ON dish_ingredient(ingredient_id);

-- ============================================================
-- week_plan
-- ============================================================
CREATE TABLE week_plan (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    year            INT          NOT NULL,
    week            INT          NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(household_id, year, week)
);

CREATE INDEX idx_week_plan_household ON week_plan(household_id);

-- ============================================================
-- plan_day
-- ============================================================
CREATE TABLE plan_day (
    id              UUID PRIMARY KEY,
    week_plan_id    UUID         NOT NULL REFERENCES week_plan(id) ON DELETE CASCADE,
    household_id    UUID         NOT NULL REFERENCES household(id),
    day_of_week     INT          NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    guests          INT          NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(week_plan_id, day_of_week)
);

CREATE INDEX idx_plan_day_household ON plan_day(household_id);
CREATE INDEX idx_plan_day_week_plan ON plan_day(week_plan_id);

-- ============================================================
-- plan_day_dish
-- ============================================================
CREATE TABLE plan_day_dish (
    id              UUID PRIMARY KEY,
    plan_day_id     UUID         NOT NULL REFERENCES plan_day(id) ON DELETE CASCADE,
    dish_id         UUID         NOT NULL REFERENCES dish(id),
    household_id    UUID         NOT NULL REFERENCES household(id),
    sort_order      INT          NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_plan_day_dish_household ON plan_day_dish(household_id);
CREATE INDEX idx_plan_day_dish_plan_day  ON plan_day_dish(plan_day_id);

-- ============================================================
-- shopping_list
-- ============================================================
CREATE TABLE shopping_list (
    id              UUID PRIMARY KEY,
    household_id    UUID         NOT NULL REFERENCES household(id),
    week_plan_id    UUID         NOT NULL REFERENCES week_plan(id),
    generated_at    TIMESTAMPTZ  NOT NULL,
    plan_hash       TEXT         NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_shopping_list_household ON shopping_list(household_id);
CREATE INDEX idx_shopping_list_week_plan ON shopping_list(week_plan_id);

-- ============================================================
-- list_generated_row
-- ============================================================
CREATE TABLE list_generated_row (
    id                UUID PRIMARY KEY,
    shopping_list_id  UUID         NOT NULL REFERENCES shopping_list(id) ON DELETE CASCADE,
    ingredient_id     UUID         NOT NULL REFERENCES ingredient(id),
    household_id      UUID         NOT NULL REFERENCES household(id),
    qty               REAL,
    unit              TEXT         NOT NULL,
    is_qb             BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_list_gen_row_household     ON list_generated_row(household_id);
CREATE INDEX idx_list_gen_row_shopping_list ON list_generated_row(shopping_list_id);

-- ============================================================
-- list_override
-- ============================================================
CREATE TABLE list_override (
    id                UUID PRIMARY KEY,
    shopping_list_id  UUID         NOT NULL REFERENCES shopping_list(id) ON DELETE CASCADE,
    ingredient_id     UUID         NOT NULL REFERENCES ingredient(id),
    household_id      UUID         NOT NULL REFERENCES household(id),
    qty_override      REAL,
    removed           BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE(shopping_list_id, ingredient_id)
);

CREATE INDEX idx_list_override_household ON list_override(household_id);

-- ============================================================
-- list_manual_item
-- ============================================================
CREATE TABLE list_manual_item (
    id                UUID PRIMARY KEY,
    shopping_list_id  UUID         NOT NULL REFERENCES shopping_list(id) ON DELETE CASCADE,
    household_id      UUID         NOT NULL REFERENCES household(id),
    name              TEXT         NOT NULL,
    qty               REAL,
    unit              TEXT,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_list_manual_household ON list_manual_item(household_id);

-- ============================================================
-- list_check
-- ============================================================
CREATE TABLE list_check (
    id                UUID PRIMARY KEY,
    shopping_list_id  UUID         NOT NULL REFERENCES shopping_list(id) ON DELETE CASCADE,
    ingredient_id     UUID,
    manual_item_id    UUID         REFERENCES list_manual_item(id) ON DELETE CASCADE,
    household_id      UUID         NOT NULL REFERENCES household(id),
    checked           BOOLEAN      NOT NULL DEFAULT TRUE,
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CHECK (
        (ingredient_id IS NOT NULL AND manual_item_id IS NULL) OR
        (ingredient_id IS NULL AND manual_item_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX idx_list_check_ingredient
    ON list_check(shopping_list_id, ingredient_id)
    WHERE ingredient_id IS NOT NULL;

CREATE UNIQUE INDEX idx_list_check_manual
    ON list_check(shopping_list_id, manual_item_id)
    WHERE manual_item_id IS NOT NULL;

CREATE INDEX idx_list_check_household ON list_check(household_id);

-- ============================================================
-- RLS: household isolation on every table (except pairing_code)
-- ============================================================
ALTER TABLE household        ENABLE ROW LEVEL SECURITY;
ALTER TABLE membership       ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredient       ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag              ENABLE ROW LEVEL SECURITY;
ALTER TABLE dish             ENABLE ROW LEVEL SECURITY;
ALTER TABLE dish_tag         ENABLE ROW LEVEL SECURITY;
ALTER TABLE dish_ingredient  ENABLE ROW LEVEL SECURITY;
ALTER TABLE week_plan        ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_day         ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_day_dish    ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list    ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_generated_row ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_override    ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_manual_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_check       ENABLE ROW LEVEL SECURITY;

CREATE POLICY household_access ON household
    FOR ALL USING (id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY membership_access ON membership
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY ingredient_access ON ingredient
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY tag_access ON tag
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY dish_access ON dish
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY dish_tag_access ON dish_tag
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY dish_ingredient_access ON dish_ingredient
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY week_plan_access ON week_plan
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY plan_day_access ON plan_day
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY plan_day_dish_access ON plan_day_dish
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY shopping_list_access ON shopping_list
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY list_generated_row_access ON list_generated_row
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY list_override_access ON list_override
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY list_manual_item_access ON list_manual_item
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));

CREATE POLICY list_check_access ON list_check
    FOR ALL USING (household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid()));
