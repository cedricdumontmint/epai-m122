# Les cinq règles du shell — mes prédictions

À remplir **avant** de lancer chaque commande (colonne « Je prédis »), puis après
(colonne « J'observe »). Une prédiction fausse n'est pas une faute : c'est ce qui vous
apprend le plus. Pour chaque prédiction fausse, notez la règle que vous aviez oubliée.

Les règles : 1 lire, développer, exécuter · 2 code de retour · 3 variable = texte ·
4 tube · 5 processus et droits.

## Partie A — Bash (dossier `~/travaux/s02`)

| N° | Commande | Je prédis | J'observe | Règle oubliée |
|----|----------|-----------|-----------|---------------|
| 1 | `echo *.txt "*.txt"` | | | |
| 2 | `grep -c ' DENIED ' mini-journal.txt ; echo $?` | | | |
| 3 | `grep 'ZZZ' mini-journal.txt \| wc -l ; echo $?` | | | |
| 4 | `a=5 ; b=3 ; echo $a+$b` | | | |
| 5 | `cut -d' ' -f3 mini-journal.txt \| uniq -c \| head -n 3` | | | |
| 6 | `bash -c 'cd /tmp ; pwd' ; pwd` | | | |

## Partie B — PowerShell (`pwsh`, même dossier)

| N° | Commande | Je prédis | J'observe | Règle oubliée |
|----|----------|-----------|-----------|---------------|
| 7 | `Select-String -Path mini-journal.txt -Pattern 'ZZZ' ; $?` | | | |
| 8 | `$a = 5 ; $b = 3 ; $a + $b` | | | |
| 9 | `Get-ChildItem "$env:ATELIER/scans" \| Sort-Object Length -Descending \| Select-Object -First 1 Name, Length` | | | |
