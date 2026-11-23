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