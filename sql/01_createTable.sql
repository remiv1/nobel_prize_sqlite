-- birthDate reste volontairement text à cause de dates non normalisées
CREATE TABLE laureate (
    id INTEGER PRIMARY KEY,
    known_name TEXT NOT NULL,
    gender TEXT NOT NULL
        CHECK (gender IN ('male', 'female', 'organization')),
    birth_date TEXT,
    birth_country TEXT,
    birth_continent TEXT
);

-- Création de la table award
CREATE TABLE award (
    id INTEGER PRIMARY KEY,
    laureate_id INTEGER NOT NULL,
    award_year INTEGER NOT NULL,
    category TEXT NOT NULL,
    portion TEXT NOT NULL,
    prize_amount INTEGER,
    prize_amount_adjusted INTEGER,
    motivation TEXT,
    age_at_award INTEGER,

    FOREIGN KEY (laureate_id)
        REFERENCES laureate(id)
);

-- Création de la table affiliation
CREATE TABLE affiliation (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT,
    country TEXT,
    city_inferred INTEGER NOT NULL DEFAULT 0
        CHECK (city_inferred IN (0, 1)),
    country_inferred INTEGER NOT NULL DEFAULT 0
        CHECK (country_inferred IN (0, 1)),
    needs_review INTEGER NOT NULL DEFAULT 0
        CHECK (needs_review IN (0, 1))
);

-- Création de la table d'association
CREATE TABLE award_affiliation (
    award_id INTEGER NOT NULL,
    affiliation_id INTEGER NOT NULL,

    PRIMARY KEY (award_id, affiliation_id),

    FOREIGN KEY (award_id)
        REFERENCES award(id),

    FOREIGN KEY (affiliation_id)
        REFERENCES affiliation(id)
);
