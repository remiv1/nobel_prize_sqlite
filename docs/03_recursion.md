# Récursion

La récursion en SQL consiste à utiliser une requête récursive pour traiter des données hiérarchiques ou répétitives. SQLite supporte les Common Table Expressions (CTE) récursives, qui permettent de définir une requête qui s'appelle elle-même.

Une CTE récursive se compose généralement de deux parties :

1. La requête de base (ou ancre) : elle définit le point de départ de la récursion.
2. La requête récursive : elle s'appelle elle-même en utilisant le résultat de l'itération précédente.

Voici un exemple simple pour illustrer la récursion en SQL avec SQLite :

```sql
WITH RECURSIVE numbers(n) AS (

    SELECT 1

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 5
)
SELECT * FROM numbers;
```

Dans cet exemple, la CTE `numbers` génère les nombres de 1 à 5 de manière récursive.

Le CSV source encode certaines affiliations multiples dans une chaîne unique séparée par `|`. SQLite ne disposant pas ici d'une struture relationnelle déjà éclatée, un CTE récursif est utilisé pour consommer successivement chaque élément de la chaîne et produire une ligne par affiliation.

Ici, nous allons l'utiliser de la manière suivante :

```sql
WITH RECURSIVE split(element, reste) AS (

    SELECT
        trim(
            substr(
                'Harvard University | Harvard Business School | MIT',
                1,
                instr(
                    'Harvard University | Harvard Business School | MIT',
                    '|'
                ) - 1
            )
        ),
        trim(
            substr(
                'Harvard University | Harvard Business School | MIT',
                instr(
                    'Harvard University | Harvard Business School | MIT',
                    '|'
                ) + 1
            )
        )

    UNION ALL

    SELECT
        CASE
            WHEN instr(reste, '|') > 0
            THEN trim(substr(reste, 1, instr(reste, '|') - 1))
            ELSE trim(reste)
        END,

        CASE
            WHEN instr(reste, '|') > 0
            THEN trim(substr(reste, instr(reste, '|') + 1))
            ELSE ''
        END

    FROM split
    WHERE reste <> ''
)

SELECT element
FROM split;
```

Dans une situation de travail réelle, on préfèrerait probablement un pipeline python à un pipeline SQL pur, ce qui serait plus lisible et plus maintenable.
