# Les pièges des boucles : mes prédictions

À remplir **avant** de lancer chaque cas (colonne « Je prédis »), puis après (colonne
« J'observe »). Une prédiction fausse n'est pas une faute : notez ce que vous aviez oublié.

Les cas sont dans `pieges-boucles.sh` (cas 1 à 8, Bash) et `pieges-boucles.ps1` (cas 9 à 12,
PowerShell). Chaque cas commence par une ligne « == N == ». Le cas 12 est le dernier : lisez-le bien.

## Partie A — Bash (`./pieges-boucles.sh`)

| N° | Le cas | Je prédis | J'observe | Ce que j'avais oublié |
|----|--------|-----------|-----------|-----------------------|
| 1 | `for f in $(ls "$vrac")` : combien de tours ? | | | |
| 2 | `for f in "$vrac"/*` : combien de tours ? | | | |
| 3 | `for f in "$vrac"/*.xyz` : que s'affiche-t-il ? | | | |
| 4 | idem avec `[[ -f $f ]] \|\| continue`, puis `fini` | | | |
| 5 | `ls "$vrac" \| while read -r f` avec un compteur : que vaut `n` après ? | | | |
| 6 | `printf 'un\ndeux' \| while read l` : quelles lignes ? | | | |
| 7 | `  a\tb  ` lu avec `read l`, puis `read -r l`, puis `IFS= read -r l` | | | |
| 8 | `for i in 1 2 3 4 5` avec `continue` si 2 et `break` si 4 | | | |

## Partie B — PowerShell (`pwsh -File pieges-boucles.ps1`)

| N° | Le cas | Je prédis | J'observe | Ce que j'avais oublié |
|----|--------|-----------|-----------|-----------------------|
| 9 | `Get-ChildItem -Path "$Vrac/*.xyz"` : combien de tours ? | | | |
| 10 | `Get-ChildItem … \| ForEach-Object { $N++ }` : que vaut `$N` ? | | | |
| 11 | `1..5 \| ForEach-Object { if ($_ -eq 2) { return }; $_ }` | | | |
| 12 | `1..5 \| ForEach-Object { if ($_ -eq 2) { continue }; $_ }`, puis une ligne `après` | | | |
