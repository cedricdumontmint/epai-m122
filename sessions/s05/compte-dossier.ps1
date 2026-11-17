# compte-dossier.ps1 - Nombre de fichiers et taille d'un chantier.
# But     : répondre à Jérôme Ruffieux : « combien de fichiers, quelle taille ? »
# Auteur  : Votre Nom
# Version : 1.0 (2026-11-17)
# Usage   : pwsh -File compte-dossier.ps1 "Cuisine Châtel-St-Denis"
# Entrée  : le nom d'un chantier (paramètre -Chantier) ; $env:ATELIER/plans/<chantier>
# Sortie  : trois lignes de texte à l'écran

param(
    [Parameter(Mandatory = $true)]
    [string]$Chantier
)

$Racine = if ($env:ATELIER) { $env:ATELIER } else { '/srv/atelier' }
$Dossier = Join-Path $Racine "plans/$Chantier"
$Fichiers = @(Get-ChildItem -Path $Dossier -File)
$Taille = ($Fichiers | Measure-Object Length -Sum).Sum

Write-Output "Chantier : $Chantier"
Write-Output "Fichiers : $($Fichiers.Count)"
Write-Output "Taille : $Taille octets"
