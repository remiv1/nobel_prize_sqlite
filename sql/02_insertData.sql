INSERT INTO laureate (
    id,
    known_name,
    gender,
    birth_date,
    birth_country,
    birth_continent
)
SELECT DISTINCT
    CAST(laureateId AS INTEGER),
    knownName,
    gender,
    CASE birthDate
        WHEN '' THEN NULL
        ELSE birthDate
    END,
    CASE birthCountry
        WHEN '' THEN NULL
        ELSE birthCountry
    END,
    CASE birthContinent
        WHEN '' THEN NULL
        ELSE birthContinent
    END
FROM nobel_raw;