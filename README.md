# Nobel Prize SQLite Database

Transformation d'un dataset CSV des prix Nobel (1901–2026)
en base relationnelle SQLite normalisée.

## Objectif

Le dataset source est fourni sous forme tabulaire et contient
notamment des informations sur :

- les lauréats ;
- les attributions ;
- les affiliations ;
- les catégories ;
- les montants des prix.

Certaines lignes contiennent plusieurs affiliations encodées dans une même cellule avec le séparateur `|`.

L'objectif du projet est de transformer cette source plate en un modèle relationnel interrogeable et contrôlé.

## Pipeline

1. Ingestion du CSV dans une table de staging `nobel_raw`
2. Profilage des données
3. Identification des entités
4. Création du modèle relationnel
5. Conversion et nettoyage des types
6. Décomposition récursive des affiliations
7. Création des relations plusieurs-à-plusieurs
8. Contrôles d'intégrité
9. Identification des données ambiguës ou inférées

## Profilage de la source

- 1 036 lignes source
- 1 028 lauréats distincts
- période : 1901–2026
- 6 catégories Nobel
- 388 affiliations normalisées
- 856 relations attribution–affiliation

A l'issue du traitement, une donnée manquante, une donnée inférée et une donnée ambiguë doivent être trois états différents.