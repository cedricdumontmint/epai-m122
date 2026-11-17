# Guillemets et variables vides — mes prédictions

À remplir **avant** de lancer chaque commande (colonne « Je prédis »), puis après
(colonne « J'observe »). Une prédiction fausse n'est pas une faute : c'est ce qui vous
apprend le plus. Pour chaque prédiction fausse, notez la règle que vous aviez oubliée.

Les règles : 1 lire, développer, exécuter · 2 code de retour · 3 variable = texte ·
4 tube · 5 processus et droits.

## Préparation — Bash

À taper une fois, dans le serveur :

```bash
cd "$ATELIER/plans"
d='Cuisine Châtel-St-Denis'
vide=''
nom=Léa
```

## Partie A — Bash (dossier `plans`)

| N° | Commande | Je prédis | J'observe | Règle oubliée |
|----|----------|-----------|-----------|---------------|
| 1 | `ls "$d" \| wc -l` | | | |
| 2 | `ls $d \| wc -l` | | | |
| 3 | `printf '[%s]\n' $d ; printf '[%s]\n' "$d"` | | | |
| 4 | `echo '$d' "$d"` | | | |
| 5 | `x="a   b" ; echo $x ; echo "$x"` | | | |
| 6 | `ls $vide \| wc -l` | | | |
| 7 | `ls "$vide" \| wc -l` | | | |
| 8 | `echo "${nom}s [$nom_s]"` | | | |

## Préparation — PowerShell

À taper une fois, dans `pwsh` (même dossier `plans`) :

```powershell
Set-Location "$env:ATELIER/plans"
$Noms = @('a', 'b', 'c')
$Vide = ''
```

## Partie B — PowerShell

| N° | Commande | Je prédis | J'observe | Règle oubliée |
|----|----------|-----------|-----------|---------------|
| 9 | `"Noms : $Noms.Count"` | | | |
| 10 | `@(Get-ChildItem $Vide).Count` | | | |
