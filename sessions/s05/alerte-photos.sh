#!/usr/bin/env bash
#
# alerte-photos.sh - Prévient Léa quand les photos s'entassent en vrac.
# But     : dire si le dossier photos/en-vrac contient plus de 40 photos
# Auteur  : Votre Nom
# Version : 1.0 (2026-11-17)
# Usage   : ./alerte-photos.sh
# Entrée  : le dossier $ATELIER/photos/en-vrac
# Sortie  : deux lignes de texte à l'écran

atelier=${ATELIER:-/srv/atelier}
n=$(ls "$atelier/photos/en-vrac" | wc -l)

if [[ $n -gt 40 ]]; then
  echo "Il y a $n photos en vrac : à ranger."
else
  echo "Il y a $n photos en vrac : c'est correct."
fi
echo "Contrôle terminé"
