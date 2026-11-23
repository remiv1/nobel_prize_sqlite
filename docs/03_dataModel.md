# Modèle de données

## Objectif

Le dataset source fournit les données Nobel sous une forme tabulaire. Une ligne associe des informations concernant un lauréat, une attribution et éventuellement une ou plusieurs affiliations.

Cette représentation facilite l'échange sous forme de CSV, mais entraîne plusieurs répétitions et ne représente pas explicitement les relations entre les différentes entités.

Le modèle SQLite sépare donc les données en quatre tables :

- `laureate`
- `award`
- `affiliation`
- `award_affiliation`

La table `nobel_raw` reste utilisée comme table de staging et conserve les données importées avant transformation.

## Principes de modélisation

La normalisation repose sur trois constats effectués pendant le profilage :

1. Un même lauréat peut recevoir plusieurs prix.
2. Une attribution appartient à un lauréat.
3. Une attribution peut être associée à plusieurs affiliations et une même affiliation peut apparaître pour plusieurs attributions.

Le modèle sépare donc l'identité du lauréat, l'attribution du prix et l'affiliation institutionnelle.

## Table `laureate`

La table `laureate` représente les personnes et organisations ayant reçu un prix Nobel.

```sql
CREATE TABLE laureate (
    id INTEGER PRIMARY KEY,
    known_name TEXT NOT NULL,
    gender TEXT NOT NULL
        CHECK (gender IN ('male', 'female', 'organization')),
    birth_date TEXT,
    birth_country TEXT,
    birth_continent TEXT
);
```

La clé primaire id correspond à l'identifiant du lauréat fourni par la source.

Le profilage ayant montré qu'un même `laureateId` peut apparaître sur plusieurs lignes du CSV, les informations relatives au lauréat sont stockées une seule fois dans cette table.

La colonne `birth_date` reste volontairement de type TEXT. Certaines dates de la source sont partielles ou non normalisées et ne peuvent pas être considérées systématiquement comme des dates complètes.

Les informations de naissance peuvent être `NULL`, notamment lorsqu'elles ne s'appliquent pas à une organisation.

## Table `award`

La table `award` représente l'attribution d'un prix à un lauréat.

```sql
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
```

Chaque attribution possède son propre identifiant.

La colonne laureate_id établit la relation avec le bénéficiaire du prix.

La relation entre `laureate` et `award` est :

laureate 1 → N award

Un lauréat peut donc avoir plusieurs attributions, tandis qu'une attribution référence un seul lauréat.

La colonne `portion` reste de type TEXT afin de préserver les valeurs de la source telles que 1, 1/2, 1/3 ou 1/4.

## Table `affiliation`

La table `affiliation` représente une affiliation institutionnelle normalisée.

```sql
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
```

Dans le CSV source, plusieurs affiliations peuvent être présentes dans une même cellule et séparées par le caractère `|`.

Ces valeurs sont décomposées pendant la transformation afin d'obtenir une ligne distincte par affiliation.

Le modèle conserve également des informations de qualité des données :

- city_inferred = 1 : la ville n'était pas directement exploitable depuis la ligne transformée et a été complétée à partir d'une référence identifiée dans les données ;
- country_inferred = 1 : même principe pour le pays ;
- needs_review = 1 : les données disponibles ne permettent pas une correction suffisamment fiable et l'affiliation nécessite une vérification.

Cette distinction permet de ne pas confondre une donnée provenant directement de la source, une donnée inférée et une donnée ambiguë.

Une valeur réellement inconnue reste NULL.

## Table `award_affiliation`

Une attribution peut être associée à plusieurs affiliations.

Inversement, une même affiliation peut apparaître pour plusieurs attributions.

Cette relation plusieurs-à-plusieurs est représentée par la table d'association award_affiliation.

```sql
CREATE TABLE award_affiliation (
award_id INTEGER NOT NULL,
affiliation_id INTEGER NOT NULL,
 
PRIMARY KEY (award_id, affiliation_id),
 
FOREIGN KEY (award_id)
REFERENCES award(id),
 
FOREIGN KEY (affiliation_id)
REFERENCES affiliation(id)
);
```

La clé primaire composite empêche d'enregistrer plusieurs fois la même relation entre une attribution et une affiliation.

Les clés étrangères garantissent que les deux entités référencées existent dans leurs tables respectives.

La relation est donc `award N ↔ N affiliation` via `award_affiliation`.

## Relations du modèle

Le modèle peut être lu de la manière suivante :

- un `laureate` peut recevoir plusieurs `award` ;
- un `award` appartient à un seul `laureate` ;
- un `award` peut être associé à plusieurs `affiliation` ;
- une `affiliation` peut être associée à plusieurs `award` ;
- `award_affiliation` matérialise cette relation plusieurs-à-plusieurs.

La navigation complète est ainsi : `laureate` → `award` → `award_affiliation` → `affiliation`. Cette séparation évite de répéter les informations personnelles des lauréats ou les informations des affiliations pour chaque attribution.

## Table de staging

La table `nobel_raw` n'appartient pas au modèle relationnel final.

Elle constitue la zone de staging dans laquelle le CSV source est importé dans `nobel_raw` sans transformation préalable.

Elle permet de :

- préserver la représentation originale des données ;
- profiler la source avant de définir le modèle ;
- conserver une référence pour contrôler les transformations ;
- reconstruire les tables normalisées de manière reproductible.

Le pipeline suit donc le principe : CSV → `nobel_raw` → transformation → tables normalisées

## Qualité et traçabilité des données

Le modèle ne cherche pas à faire disparaître silencieusement les anomalies de la source.

Trois situations sont distinguées :

- donnée absente : valeur `NULL` ;
- donnée complétée par inférence : indicateur `*_inferred = 1` ;
- donnée ambiguë : indicateur `needs_review = 1`.

Les décisions d'inférence sont ainsi séparées des données directement issues de la source.

Cette approche permet de conserver la traçabilité du nettoyage et de réexaminer ultérieurement les cas nécessitant une validation.

## Résultat de la normalisation

À l'issue du pipeline, le modèle contient :

- 1 028 lauréats distincts ;
- 1 036 attributions issues de la source ;
- 388 affiliations normalisées ;
- 856 relations entre attributions et affiliations.

Les relations ont été contrôlées avec les mécanismes d'intégrité de SQLite et le nombre de relations générées lors de la transformation a été réconcilié avec le nombre de relations chargées dans award_affiliation.
