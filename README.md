# Nobel Prize SQLite Database

Transformation d'un dataset CSV des prix Nobel (1901–2026) en base relationnelle SQLite normalisée.

## Objectif

Le dataset source est fourni sous forme tabulaire et contient notamment des informations sur :

- les lauréats ;
- les attributions ;
- les affiliations ;
- les catégories ;
- les montants des prix.

Certaines lignes contiennent plusieurs affiliations encodées dans une même cellule avec le séparateur `|`.

L'objectif du projet est de transformer cette source plate en un modèle relationnel interrogeable et contrôlé.

## Pipeline

1. [Import du CSV](./docs/01_dataImport.md) dans une table de staging `nobel_raw`
2. [Profilage](./docs/02_profilage.md) des données
   1. Identification des entités
   2. Création du modèle relationnel
   3. Conversion et nettoyage des types
3. Décomposition récursive des affiliations
4. Création des relations plusieurs-à-plusieurs
5. Contrôles d'intégrité
6. Identification des données ambiguës ou inférées

## Profilage de la source

- 1 036 lignes source
- 1 028 lauréats distincts
- période : 1901–2026
- 6 catégories Nobel
- 388 affiliations normalisées
- 856 relations attribution–affiliation

A l'issue du traitement, une donnée manquante, une donnée inférée et une donnée ambiguë doivent être trois états différents.

### Modèle relationnel

La transformation aboutit à quatre tables principales :

- `laureate` : identité et informations personnelles des lauréats ;
- `award` : attribution d'un prix à un lauréat ;
- `affiliation` : établissements associés aux attributions ;
- `award_affiliation` : table d'association plusieurs-à-plusieurs.

La table source `nobel_raw` est conservée comme zone de staging afin
de préserver les données originales et la traçabilité du pipeline.

### Data quality

Le pipeline distingue explicitement :

- les valeurs absentes (`NULL`) ;
- les valeurs inférées (`*_inferred = 1`) ;
- les valeurs nécessitant une vérification (`needs_review = 1`).

Aucune donnée ambiguë n'est silencieusement remplacée.
