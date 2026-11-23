# Annexes

## Fonctions utilisées

### `substr()`

La fonction `substr()` permet d'extraire une sous-chaîne d'une chaîne de caractères. Il existe 2 syntaxes principales :

1. `substr(X, Y)` : extrait la sous-chaîne de `X` à partir de la position `Y` jusqu'à la fin de la chaîne.
2. `substr(X, Y, Z)` : extrait la sous-chaîne de `X` à partir de la position `Y` sur une longueur de `Z` caractères.

Les positions dans `substr()` commencent à 1, et non à 0.

```sql
SELECT substr(
    'Harvard University | Harvard Business School | MIT',
    1,
    instr(
        'Harvard University | Harvard Business School | MIT',
        ' | '
    ) -1
);
```

### `instr()`

La fonction `instr(X, Y)` retourne la position de la première occurrence de la sous-chaîne `Y` dans la chaîne `X`. Si `Y` n'est pas trouvée, elle retourne 0.

```sql
SELECT instr(
    'Harvard University | Harvard Business School | MIT',
    ' | '
);
```

### `trim()`

La fonction `trim(X)` permet de supprimer les espaces blancs au début et à la fin de la chaîne `X`.

```sql
SELECT trim(
    substr(
        'Harvard University | Harvard Business School | MIT',
        1,
        instr(
            'Harvard University | Harvard Business School | MIT',
            '|'
        ) - 1
    )
) AS affiliation;
```
