#!/usr/bin/env bash
#
# dossiers-mystere.sh - Réalise le diagramme de l'exercice 1 (contrôle de trois dossiers).
# Usage   : ./dossiers-mystere.sh
# À lire APRÈS avoir prédit la sortie : on le lance d'abord, on le lit ensuite.

atelier=${ATELIER:-/srv/atelier}
compteur=0

for dossier in devis photos/en-vrac tmp; do
  n=$(ls "$atelier/$dossier" | wc -l)
  if [[ $n -gt 40 ]]; then
    echo "$dossier : $n à ranger"
    compteur=$(( compteur + 1 ))
  else
    echo "$dossier : $n OK"
  fi
done

echo "À ranger : $compteur"
