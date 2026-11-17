# seulement-pwsh7.ps1 - Trois lignes qui ne marchent qu'en PowerShell 7.
# Usage : pwsh -File seulement-pwsh7.ps1 [dossier]
$Racine = if ($env:ATELIER) { $env:ATELIER } else { '/srv/atelier' }
$Nom = $args[0] ?? 'devis'
$Chemin = Join-Path $Racine $Nom
$Etat = (Test-Path -LiteralPath $Chemin -PathType Container) ? 'existe' : 'est absent'
Write-Output "Le dossier $Nom $Etat."
Test-Path -LiteralPath $Chemin -PathType Container && Write-Output "Contrôle terminé."
