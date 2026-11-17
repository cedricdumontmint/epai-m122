# dossiers-mystere.ps1 - Réalise le diagramme de l'exercice 1 (contrôle de trois dossiers).
# Usage : pwsh -File dossiers-mystere.ps1
# À lire APRÈS avoir prédit la sortie : on le lance d'abord, on le lit ensuite.

$Racine = if ($env:ATELIER) { $env:ATELIER } else { '/srv/atelier' }
$Compteur = 0

foreach ($Dossier in 'devis', 'photos/en-vrac', 'tmp') {
    $N = @(Get-ChildItem (Join-Path $Racine $Dossier)).Count
    if ($N -gt 40) {
        "$Dossier : $N à ranger"
        $Compteur = $Compteur + 1
    } else {
        "$Dossier : $N OK"
    }
}

"À ranger : $Compteur"
