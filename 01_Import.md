# Import du CSV

Le CSV a été importé depuis [KaggleHub](https://www.kaggle.com/datasets/luthfimuthathohirin/nobel-prize-laureates-1901-2026) puis importé dans la base de données :

```bash
sqlite3 nobel.db
.mode csv
.import nobel.csv nobel_raw
.mode qbox # Revenir à une présentation tableau
```

L'étape suivante consistera à observer les données.

```SQL
PRAGMA table_info(nobel_row);

SELECT *
FROM nobel_raw
LIMIT 5;

SELECT COUNT(*)
FROM nobel_raw;

SELECT
	MIN(CAST(awardYear AS INTEGER)) AS first_year,
	MAX(CAST(awardYear AS INTEGER)) AS last_year,
	COUNT(DISTINCT category) AS nb_categories
FROM nobel_raw;

SELECT category, COUNT(*) AS nb
FROM nobel_raw
GROUP BY category
ORDER BY nb DESC;

SELECT gender, COUNT(*) AS nb
FROM nobel_raw
GROUP BY gender
ORDER BY nb DESC;
```

Ensuite, je passe au profilage des colonnes avant typage, notammenet les champs suceptibles de poser problème :

```SQL
SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT laureateId) AS laureates_distincts,
    COUNT(DISTINCT awardYear) AS annees,
    COUNT(DISTINCT category) AS categories,
    COUNT(DISTINCT birthCountry) AS pays_naissance,
    COUNT(DISTINCT affiliationName) AS affiliations
FROM nobel_raw;

SELECT
    SUM(knownName = '') AS knownName_vide,
    SUM(birthDate = '') AS birthDate_vide,
    SUM(birthCountry = '') AS birthCountry_vide,
    SUM(affiliationName = '') AS affiliation_vide
FROM nobel_raw;
```

Ensuite on vérifie les répétitions des lauréats :

```SQL
SELECT
    laureateId,
    knownName,
    COUNT(*) AS nb_prix
FROM nobel_raw
GROUP BY laureateId, knownName
HAVING COUNT(*) > 1
ORDER BY nb_prix DESC;
```

On a 1036 lignes représentant 1028 lauréats distincts, certains ayant reçu plusieurs prix comme Marie Curie ou encore Linus Pauling ou Frederick Sanger.

Vérifions qu'un même `laureateId` possède toujours les mêmes informations personnes dans toutes ses lignes.

```SQL
SELECT
    laureateId,
    COUNT(DISTINCT knownName) AS names,
    COUNT(DISTINCT gender) AS genders,
    COUNT(DISTINCT birthDate) AS birth_dates,
    COUNT(DISTINCT birthCountry) AS birth_countries
FROM nobel_raw
GROUP BY laureateId
HAVING
       COUNT(DISTINCT knownName) > 1
    OR COUNT(DISTINCT gender) > 1
    OR COUNT(DISTINCT birthDate) > 1
    OR COUNT(DISTINCT birthCountry) > 1;
```

Lors de l'exploration, on a 31 `birthDate` vides, 31 `birthCountry` vides et 270 `affiliationName` vides pour 31 `organization`. Vérifions qu'il s'agisse des mêmes 31.

```SQL
SELECT
    gender,
    COUNT(*) AS nb,
    SUM(birthDate = '') AS birth_date_vide,
    SUM(birthCountry = '') AS birth_country_vide
FROM nobel_raw
GROUP BY gender;
```

J'aurais aussi besoin des types utilisés par sqlite3

```SQL
SELECT
    typeof(laureateId),
    typeof(awardYear),
    typeof(prizeAmount),
    typeof(ageAtAward),
    typeof(confidence_score),
    COUNT(*)
FROM nobel_raw
GROUP BY
    typeof(laureateId),
    typeof(awardYear),
    typeof(prizeAmount),
    typeof(ageAtAward),
    typeof(confidence_score);
```
