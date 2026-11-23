# Profilage des données

```SQL
PRAGMA table_info(nobel_raw);

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

Ensuite, je passe au profilage des colonnes avant typage, notamment les champs susceptibles de poser problème :

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

## Gestion des Lauréats

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

```text
╭────────────┬───────────────────────────────────────────────────────────────┬─────────╮
│ laureateId │                           knownName                           │ nb_prix │
╞════════════╪═══════════════════════════════════════════════════════════════╪═════════╡
│ '482'      │ 'International Committee of the Red Cross'                    │       3 │
│ '217'      │ 'Linus Pauling'                                               │       2 │
│ '222'      │ 'Frederick Sanger'                                            │       2 │
│ '515'      │ 'Office of the United Nations High Commissioner for Refugees' │       2 │
│ '6'        │ 'Marie Curie'                                                 │       2 │
│ '66'       │ 'John Bardeen'                                                │       2 │
│ '743'      │ 'K. Barry Sharpless'                                          │       2 │
╰────────────┴───────────────────────────────────────────────────────────────┴─────────╯
```

On a 1036 lignes représentant 1028 lauréats distincts, certains ayant reçu plusieurs prix comme Marie Curie ou encore Linus Pauling ou Frederick Sanger.

Créons la première table `laureate` comme dans le [script SQL](../sql/01_createTable.sql).

Cependant, avant de créer la table `award`, il nous faut vérifier qu'un même `laureateId` possède toujours les mêmes informations personnelles dans toutes ses lignes.

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

Aucune ligne n'est retournée, c'est donc que chaque `laureateId` possède des informations personnelles cohérentes dans toutes ses lignes.

Lors de l'exploration, on a 31 `birthDate` vides, 31 `birthCountry` vides et 270 `affiliationName` vides pour 31 `organization`. Vérifions qu'il s'agisse des mêmes 31.

```sql
SELECT
    gender,
    COUNT(*) AS nb,
    SUM(birthDate = '') AS birth_date_vide,
    SUM(birthCountry = '') AS birth_country_vide
FROM nobel_raw
GROUP BY gender;
```

```text
╭────────────────┬─────┬─────────────────┬────────────────────╮
│     gender     │ nb  │ birth_date_vide │ birth_country_vide │
╞════════════════╪═════╪═════════════════╪════════════════════╡
│ 'female'       │  70 │               0 │                  0 │
│ 'male'         │ 935 │               0 │                  0 │
│ 'organization' │  31 │              31 │                 31 │
╰────────────────┴─────┴─────────────────┴────────────────────╯
```

L’étape suivante consiste à déterminer les types effectivement stockés après l’import brut.

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

## Gestion des affiliations

Lors de l'analyse des affiliations, on constate que certaines lignes ont déjà une concaténation des affiliations dans une même cellule avec le séparateur `|`. Il est donc nécessaire de les décomposer pour obtenir une table normalisée des affiliations.

```sql
SELECT
    affiliationName,
    affiliationCity,
    affiliationCountry,
    COUNT(*) AS nb
FROM nobel_raw
WHERE affiliationName <> ''
GROUP BY
    affiliationName,
    affiliationCity,
    affiliationCountry
ORDER BY nb DESC;
```

Cependant, lors de l'exploration, on trouve parfois 2 éléments dans names, 1 seul dans cities et deux dans countries.

On va donc devoir vérifier si on peut inférer les informations manquantes à partir de l'existant en analysant les correspondances entre les noms, les villes et les pays d'affiliation. C'est ici un sujet de data quality.
