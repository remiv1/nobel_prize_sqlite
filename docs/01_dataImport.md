# Import du CSV

Le CSV a été importé depuis [KaggleHub](https://www.kaggle.com/datasets/luthfimuthathohirin/nobel-prize-laureates-1901-2026) puis importé dans la base de données :

```bash
sqlite3 nobel.db
.mode csv
.import nobel.csv nobel_raw
.mode qbox # Revenir à une présentation tableau
```

L'étape suivante consistera à observer les données.
