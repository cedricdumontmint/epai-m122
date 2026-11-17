# pieges-boucles.ps1 - Quatre pièges des boucles en PowerShell.
# Usage : pwsh -File pieges-boucles.ps1
# À faire : lisez le script et PRÉDISEZ la sortie de chaque cas (dans pieges-boucles.md)
#           AVANT de le lancer. Chaque cas commence par « == N == ».

$Racine = if ($env:ATELIER) { $env:ATELIER } else { '/srv/atelier' }
$Vrac = Join-Path $Racine 'photos/en-vrac'

'== 9 =='
"tours : $(@(Get-ChildItem -Path "$Vrac/*.xyz").Count)"

'== 10 =='
$N = 0; Get-ChildItem -LiteralPath $Vrac | ForEach-Object { $N++ }; "n = $N"

'== 11 =='
1..5 | ForEach-Object { if ($_ -eq 2) { return }; $_ }

'== 12 =='
1..5 | ForEach-Object { if ($_ -eq 2) { continue }; $_ }
'après : cette ligne est-elle affichée ?'
