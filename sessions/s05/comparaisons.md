# Comparer : mes prédictions

À remplir **avant** de lancer chaque ligne (colonne « Je prédis »), puis après (colonne
« J'observe »). Une prédiction fausse n'est pas une faute : notez ce que vous aviez oublié.

Modèle PowerShell : `if (CONDITION) { 'vrai' } else { 'faux' }`
Modèle Bash : `if [[ CONDITION ]]; then echo vrai; else echo faux; fi`

## Partie A — PowerShell (`pwsh`)

| N° | Condition | Je prédis | J'observe | Ce que j'avais oublié |
|----|-----------|-----------|-----------|-----------------------|
| 1 | `'10' -gt 9` | | | |
| 2 | `10 -gt '9'` | | | |
| 3 | `'abc' -eq 'ABC'` | | | |
| 4 | `'abc' -ceq 'ABC'` | | | |
| 5 | `'Pergola Remy' -like '*remy'` | | | |
| 6 | `$N = 45` puis `$N > 40` | | | |

## Partie B — Bash

| N° | Ligne | Je prédis | J'observe | Ce que j'avais oublié |
|----|-------|-----------|-----------|-----------------------|
| 7 | `[[ 10 -gt 9 ]]` | | | |
| 8 | `[[ 10 > 9 ]]` | | | |
| 9 | `n=""` puis `[[ $n -eq 5 ]]` | | | |
| 10 | `n=""` puis `[[ $n -eq 0 ]]` | | | |
| 11 | `n="a b"` puis `[[ $n -eq 5 ]]` | | | |
| 12 | `n='x[$(echo PIRATÉ >&2)]'` puis `[[ $n -eq 5 ]]` | | | |
