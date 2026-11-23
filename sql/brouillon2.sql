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

SELECT *
FROM split_affiliations
WHERE laureate_id = 1061;