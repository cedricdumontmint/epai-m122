#!/usr/bin/env bash
#
# compte-dossier.sh - Nombre de fichiers et taille d'un chantier.
# But     : répondre à Jérôme Ruffieux : « combien de fichiers, quelle taille ? »
# Auteur  : Votre Nom
# Version : 1.0 (2026-11-17)
# Usage   : ./compte-dossier.sh "Cuisine Châtel-St-Denis"
# Entrée  : le nom d'un chantier (premier argument) ; $ATELIER/plans/<chantier>
# Sortie  : trois lignes de texte à l'écran

atelier=${ATELIER:-/srv/atelier}
chantier=${1:?Usage : ./compte-dossier.sh <chantier>}
dossier="$atelier/plans/$chantier"

echo "Chantier : $chantier"
echo "Fichiers : $(ls "$dossier" | wc -l)"
echo "Taille : $(cat "$dossier"/* | wc -c) octets"
