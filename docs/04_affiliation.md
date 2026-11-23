# Gestion des affiliations

Combien d'affiliations sont présentent dans le fichier source ?

```sql
-- Mettre la requête récursive puis...
SELECT COUNT(*)
FROM split_affiliations
WHERE name <> '';

-- ...puis...
SELECT COUNT(*)
FROM award_affiliation;
```

Lors de l'analyse des affiliations, on constate que certaines lignes ont déjà une concaténation des affiliations dans une même cellule avec le séparateur `|`. Il est donc nécessaire de les décomposer pour obtenir une table normalisée des affiliations.

```sql
SELECT
    laureateId,
    awardYear,

    length(affiliationName)
        - length(replace(affiliationName, '|', ''))
        + 1 AS nb_names,

    CASE
        WHEN affiliationCity = '' THEN 0
        ELSE length(affiliationCity)
            - length(replace(affiliationCity, '|', ''))
            + 1
    END AS nb_cities,

    CASE
        WHEN affiliationCountry = '' THEN 0
        ELSE length(affiliationCountry)
            - length(replace(affiliationCountry, '|', ''))
            + 1
    END AS nb_countries

FROM nobel_raw
WHERE affiliationName <> ''
    AND (
        (
            CASE
                WHEN affiliationCity = '' THEN 0
                ELSE length(affiliationCity)
                    - length(replace(affiliationCity, '|', ''))
                    + 1
            END
        )
        <>  
        (
            length(affiliationName)
                - length(replace(affiliationName, '|', ''))
                + 1
        )

        OR

        (
            CASE
                WHEN affiliationCountry = '' THEN 0
                ELSE length(affiliationCountry)
                    - length(replace(affiliationCountry, '|', ''))
                    + 1
            END
        )
        <>
        (
            length(affiliationName)
            - length(replace(affiliationName, '|', ''))
            + 1
        )
    );
```

```text
╭────────────┬───────────┬──────────┬───────────┬──────────────╮
│ laureateId │ awardYear │ nb_names │ nb_cities │ nb_countries │
╞════════════╪═══════════╪══════════╪═══════════╪══════════════╡
│ '1061'     │ '2026'    │        2 │         1 │            2 │
│ '1039'     │ '2024'    │        2 │         1 │            2 │
│ '1015'     │ '2022'    │        2 │         1 │            2 │
│ '998'      │ '2021'    │        2 │         1 │            2 │
│ '942'      │ '2017'    │        2 │         1 │            1 │
│ '943'      │ '2017'    │        2 │         1 │            1 │
│ '941'      │ '2017'    │        2 │         1 │            1 │
│ '939'      │ '2017'    │        2 │         1 │            2 │
│ '885'      │ '2013'    │        2 │         1 │            2 │
│ '886'      │ '2013'    │        2 │         1 │            2 │
│ '878'      │ '2012'    │        2 │         1 │            2 │
│ '851'      │ '2010'    │        1 │         0 │            1 │
│ '842'      │ '2009'    │        2 │         1 │            2 │
│ '837'      │ '2009'    │        3 │         2 │            3 │
│ '831'      │ '2008'    │        2 │         1 │            2 │
│ '811'      │ '2007'    │        2 │         1 │            2 │
│ '770'      │ '2003'    │        2 │         1 │            2 │
│ '461'      │ '1999'    │        2 │         1 │            2 │
│ '270'      │ '1988'    │        2 │         1 │            2 │
╰────────────┴───────────┴──────────┴───────────┴──────────────╯
```

On a 19 attributions présentant un désalignement, et elles se répartissent en quelques cas assez nets d'après le résultat.

- La majorité est du type 2 noms / 1 ville / 2 pays.
- Trois cas de 2017 sont 2 noms / 1 ville / 1 pays.
- Le cas 837 est 3 noms / 2 villes / 3 pays.
- Le cas 851 est différent : 1 nom / 0 ville / 1 pays.

## Cas généraux

Un nombre inférieur de villes ou de pays signale un désalignement potentiel. Une inférence automatique n’est appliquée que lorsqu’une référence non ambiguë peut être identifiée dans les données déjà normalisées ; dans les autres cas, l’enregistrement est marqué pour révision.

### Cas 2/1/2

Ici, on devrait pouvoir inférer la ville à chaque nom puisque le nombre de villes est inférieur ou égal au nombre de noms avec `city_inferred = 1`.

### Cas 2/1/1

Ici, on peut inférer la ville et le pays pour chaque nom puisque le nombre de villes et de pays est inférieur ou égal au nombre de noms avec `city_inferred = 1` et `country_inferred = 1`.

### Cas 3/2/3

Ici, inférer la ville est plus risqué, on ignore laquelle des deux villes doit être répétée ou à quelle position se trouve la valeur manquante. Cela nécessite une vérification manuelle.

### Cas 1/0/1

Ici, il n'y a qu'un seul nom et un seul pays, et aucune ville. L'inférence est simple : le nom correspond au pays indiqué, et la ville reste inconnue. On utilisera donc `city = NULL`.

## Insertion et vérification

Après avoir inséré les informations dans la table des affiliations, faisons quelques vérifications.

```sql
SELECT COUNT(*)
FROM affiliation;
```

```text
╭──────────╮
│ COUNT(*) │
╞══════════╡
│      388 │
╰──────────╯
```

```sql
SELECT *
FROM affiliation
ORDER BY name
LIMIT 5;
```

```text
╭─────┬──────────────────────────────────────────┬──────────────────┬───────────────────┬───────────────┬──────────────────┬──────────────╮
│ id  │                   name                   │       city       │      country      │ city_inferred │ country_inferred │ needs_review │
╞═════╪══════════════════════════════════════════╪══════════════════╪═══════════════════╪═══════════════╪══════════════════╪══════════════╡
│ 157 │ 'A.F. Ioffe Physico-Technical Institute' │ 'St. Petersburg' │ 'Russia'          │             0 │                0 │            0 │
│ 164 │ 'Aarhus University'                      │ 'Aarhus'         │ 'Denmark'         │             0 │                0 │            0 │
│ 220 │ 'Academy of Sciences'                    │ 'Moscow'         │ 'Russia'          │             0 │                0 │            0 │
│ 241 │ 'All Souls College'                      │ 'Oxford'         │ 'United Kingdom'  │             0 │                0 │            0 │
│ 339 │ 'Amsterdam University'                   │ 'Amsterdam'      │ 'the Netherlands' │             0 │                0 │            0 │
╰─────┴──────────────────────────────────────────┴──────────────────┴───────────────────┴───────────────┴──────────────────┴──────────────╯
```

```sql
SELECT *
FROM affiliation
WHERE city IS NULL
   OR country IS NULL;
```

```text
╭─────┬────────────────────────────────────────────────┬──────┬─────────┬───────────────┬──────────────────┬──────────────╮
│ id  │                      name                      │ city │ country │ city_inferred │ country_inferred │ needs_review │
╞═════╪════════════════════════════════════════════════╪══════╪═════════╪═══════════════╪══════════════════╪══════════════╡
│ 105 │ 'University of Delaware'                       │ NULL │ 'USA'   │             0 │                0 │            0 │
│ 353 │ 'Stanford University'                          │ NULL │ 'USA'   │             0 │                0 │            0 │
│ 357 │ 'Howard Hughes Medical Institute'              │ NULL │ 'USA'   │             0 │                0 │            0 │
│ 365 │ 'California Institute of Technology (Caltech)' │ NULL │ NULL    │             0 │                0 │            0 │
│ 366 │ 'Massachusetts Institute of Technology (MIT)'  │ NULL │ NULL    │             0 │                0 │            0 │
│ 369 │ 'Duke University Medical Center'               │ NULL │ 'USA'   │             0 │                0 │            0 │
╰─────┴────────────────────────────────────────────────┴──────┴─────────┴───────────────┴──────────────────┴──────────────╯
```

## Vérification des tables et des relations

```sql
PRAGMA foreign_key_check;
PRAGMA integrity_check;
```

### Inférence sur l'existant

Pour voir si une affiliation incomplète possède déjà une version complète.

```sql
SELECT
    bad.id,
    bad.name,
    bad.city AS missing_city,
    bad.country AS missing_country,
    good.id AS reference_id,
    good.city AS reference_city,
    good.country AS reference_country
FROM affiliation AS bad
JOIN affiliation AS good
    ON good.name = bad.name
    AND good.id <> bad.id
WHERE (bad.city IS NULL OR bad.country IS NULL)
  AND good.city IS NOT NULL
  AND good.country IS NOT NULL
ORDER BY bad.name;
```

```text
╭─────┬────────────────────────────────────────────────┬──────────────┬─────────────────┬──────────────┬───────────────────┬───────────────────╮
│ id  │                      name                      │ missing_city │ missing_country │ reference_id │  reference_city   │ reference_country │
╞═════╪════════════════════════════════════════════════╪══════════════╪═════════════════╪══════════════╪═══════════════════╪═══════════════════╡
│ 365 │ 'California Institute of Technology (Caltech)' │ NULL         │ NULL            │           60 │ 'Pasadena, CA'    │ 'USA'             │
│ 357 │ 'Howard Hughes Medical Institute'              │ NULL         │ 'USA'           │            7 │ 'Stanford, CA'    │ 'USA'             │
│ 357 │ 'Howard Hughes Medical Institute'              │ NULL         │ 'USA'           │           77 │ 'Durham, NC'      │ 'USA'             │
│ 357 │ 'Howard Hughes Medical Institute'              │ NULL         │ 'USA'           │          362 │ 'Chevy Chase, MD' │ 'USA'             │
│ 366 │ 'Massachusetts Institute of Technology (MIT)'  │ NULL         │ NULL            │           22 │ 'Cambridge, MA'   │ 'USA'             │
│ 353 │ 'Stanford University'                          │ NULL         │ 'USA'           │            4 │ 'Stanford, CA'    │ 'USA'             │
╰─────┴────────────────────────────────────────────────┴──────────────┴─────────────────┴──────────────┴───────────────────┴───────────────────╯
```

Pour les identifiants 353, 365 et 366, tu peux mettre à jour à partir de leur référence connue. Terminer la mise à jour des affiliations à partir des références connues et marquer les autres affiliations nécessitant une révision comme indiqué dans le [script de nettoyage](../sql/03_cleaning.sql).

Enfin, vérifiez avec la requête suivante.

```sql
SELECT
    id,
    name,
    city,
    country,
    city_inferred,
    country_inferred,
    needs_review
FROM affiliation
WHERE city_inferred = 1
   OR country_inferred = 1
   OR needs_review = 1;
```

```text
╭─────┬────────────────────────────────────────────────┬─────────────────┬─────────┬───────────────┬──────────────────┬──────────────╮
│ id  │                      name                      │      city       │ country │ city_inferred │ country_inferred │ needs_review │
╞═════╪════════════════════════════════════════════════╪═════════════════╪═════════╪═══════════════╪══════════════════╪══════════════╡
│ 105 │ 'University of Delaware'                       │ NULL            │ 'USA'   │             0 │                0 │            1 │
│ 353 │ 'Stanford University'                          │ 'Stanford, CA'  │ 'USA'   │             1 │                0 │            0 │
│ 357 │ 'Howard Hughes Medical Institute'              │ NULL            │ 'USA'   │             0 │                0 │            1 │
│ 365 │ 'California Institute of Technology (Caltech)' │ 'Pasadena, CA'  │ 'USA'   │             1 │                1 │            0 │
│ 366 │ 'Massachusetts Institute of Technology (MIT)'  │ 'Cambridge, MA' │ 'USA'   │             1 │                1 │            0 │
│ 369 │ 'Duke University Medical Center'               │ NULL            │ 'USA'   │             0 │                0 │            1 │
╰─────┴────────────────────────────────────────────────┴─────────────────┴─────────┴───────────────┴──────────────────┴──────────────╯
```
