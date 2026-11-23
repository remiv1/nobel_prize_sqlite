-- Insertion des données dans la table laureate
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

-- Insertion des données dans la table award
INSERT INTO award (
    laureate_id,
    award_year,
    category,
    portion,
    prize_amount,
    prize_amount_adjusted,
    motivation,
    age_at_award
)
SELECT
    CAST(laureateId AS INTEGER),
    CAST(awardYear AS INTEGER),
    category,
    portion,
    CAST(prizeAmount AS INTEGER),
    CAST(prizeAmountAdjusted AS INTEGER),
    NULLIF(motivation, ''),
    NULLIF(CAST(ageAtAward AS INTEGER), 0)
FROM nobel_raw;

-- Insertion des données dans la table affiliation
WITH RECURSIVE

raw_affiliations AS (
    SELECT
        CAST(laureateId AS INTEGER) AS laureate_id,
        CAST(awardYear AS INTEGER) AS award_year,
        category,
        affiliationName AS names,
        affiliationCity AS cities,
        affiliationCountry AS countries
    FROM nobel_raw
    WHERE affiliationName <> ''
),

split_affiliations (
    laureate_id,
    award_year,
    category,
    name,
    city,
    country,
    reste_names,
    reste_cities,
    reste_countries
) AS (
    SELECT
        laureate_id,
        award_year,
        category,

        CASE
            WHEN instr(names, '|') > 0
            THEN trim(substr(names, 1, instr(names, '|') - 1))
            ELSE trim(names)
        END,

        CASE
            WHEN instr(cities, '|') > 0
            THEN trim(substr(cities, 1, instr(cities, '|') - 1))
            ELSE NULLIF(trim(cities), '')
        END,

        CASE
            WHEN instr(countries, '|') > 0
            THEN trim(substr(countries, 1, instr(countries, '|') - 1))
            ELSE NULLIF(trim(countries), '')
        END,

        CASE
            WHEN instr(names, '|') > 0
            THEN trim(substr(names, instr(names, '|') + 1))
            ELSE ''
        END,

        CASE
            WHEN instr(cities, '|') > 0
            THEN trim(substr(cities, instr(cities, '|') + 1))
            ELSE ''
        END,

        CASE
            WHEN instr(countries, '|') > 0
            THEN trim(substr(countries, instr(countries, '|') + 1))
            ELSE ''
        END

    FROM raw_affiliations
	
	UNION ALL
	
	SELECT
		laureate_id,
		award_year,
		category,
		
		CASE
			WHEN instr(reste_names, '|') > 0
			THEN trim(substr(reste_names, 1, instr(reste_names, '|') - 1))
			ELSE trim(reste_names)
		END,
		
		CASE
			WHEN instr(reste_cities, '|') > 0
			THEN trim(substr(reste_cities, 1, instr(reste_cities, '|') - 1))
			ELSE NULLIF(trim(reste_cities), '')
		END,

		CASE
			WHEN instr(reste_countries, '|') > 0
			THEN trim(substr(reste_countries, 1, instr(reste_countries, '|') - 1))
			ELSE NULLIF(trim(reste_countries), '')
		END,

		CASE
			WHEN instr(reste_names, '|') > 0
			THEN trim(substr(reste_names, instr(reste_names, '|') + 1))
			ELSE ''
		END,

		CASE
			WHEN instr(reste_cities, '|') > 0
			THEN trim(substr(reste_cities, instr(reste_cities, '|') + 1))
			ELSE ''
		END,

		CASE
			WHEN instr(reste_countries, '|') > 0
			THEN trim(substr(reste_countries, instr(reste_countries, '|') + 1))
			ELSE ''
		END

	FROM split_affiliations
	WHERE reste_names <> ''
)

INSERT INTO affiliation (
    name,
    city,
    country
)
SELECT DISTINCT
    name,
    city,
    country
FROM split_affiliations
WHERE name <> '';

WITH RECURSIVE

raw_affiliations AS (
    SELECT
        CAST(laureateId AS INTEGER) AS laureate_id,
        CAST(awardYear AS INTEGER) AS award_year,
        category,
        affiliationName AS names,
        affiliationCity AS cities,
        affiliationCountry AS countries
    FROM nobel_raw
    WHERE affiliationName <> ''
),

split_affiliations (
    laureate_id,
    award_year,
    category,
    name,
    city,
    country,
    reste_names,
    reste_cities,
    reste_countries
) AS (
    SELECT
        laureate_id,
        award_year,
        category,

        CASE
            WHEN instr(names, '|') > 0
            THEN trim(substr(names, 1, instr(names, '|') - 1))
            ELSE trim(names)
        END,

        CASE
            WHEN instr(cities, '|') > 0
            THEN trim(substr(cities, 1, instr(cities, '|') - 1))
            ELSE NULLIF(trim(cities), '')
        END,

        CASE
            WHEN instr(countries, '|') > 0
            THEN trim(substr(countries, 1, instr(countries, '|') - 1))
            ELSE NULLIF(trim(countries), '')
        END,

        CASE
            WHEN instr(names, '|') > 0
            THEN trim(substr(names, instr(names, '|') + 1))
            ELSE ''
        END,

        CASE
            WHEN instr(cities, '|') > 0
            THEN trim(substr(cities, instr(cities, '|') + 1))
            ELSE ''
        END,

        CASE
            WHEN instr(countries, '|') > 0
            THEN trim(substr(countries, instr(countries, '|') + 1))
            ELSE ''
        END

    FROM raw_affiliations
	
	UNION ALL
	
	SELECT
		laureate_id,
		award_year,
		category,
		
		CASE
			WHEN instr(reste_names, '|') > 0
			THEN trim(substr(reste_names, 1, instr(reste_names, '|') - 1))
			ELSE trim(reste_names)
		END,
		
		CASE
			WHEN instr(reste_cities, '|') > 0
			THEN trim(substr(reste_cities, 1, instr(reste_cities, '|') - 1))
			ELSE NULLIF(trim(reste_cities), '')
		END,

		CASE
			WHEN instr(reste_countries, '|') > 0
			THEN trim(substr(reste_countries, 1, instr(reste_countries, '|') - 1))
			ELSE NULLIF(trim(reste_countries), '')
		END,

		CASE
			WHEN instr(reste_names, '|') > 0
			THEN trim(substr(reste_names, instr(reste_names, '|') + 1))
			ELSE ''
		END,

		CASE
			WHEN instr(reste_cities, '|') > 0
			THEN trim(substr(reste_cities, instr(reste_cities, '|') + 1))
			ELSE ''
		END,

		CASE
			WHEN instr(reste_countries, '|') > 0
			THEN trim(substr(reste_countries, instr(reste_countries, '|') + 1))
			ELSE ''
		END

	FROM split_affiliations
	WHERE reste_names <> ''
)

INSERT INTO award_affiliation (
    award_id,
    affiliation_id
)
SELECT DISTINCT
    a.id,
    af.id
FROM split_affiliations AS s

JOIN award AS a
    ON a.laureate_id = s.laureate_id
    AND a.award_year = s.award_year
    AND a.category = s.category

JOIN affiliation AS af
    ON af.name = s.name
    AND af.city IS s.city
    AND af.country IS s.country

WHERE s.name <> '';
