#!/usr/bin/env bash
#
# pieges-boucles.sh - Huit pièges des boucles en Bash.
# Usage : ./pieges-boucles.sh
# À faire : lisez le script et PRÉDISEZ la sortie de chaque cas (dans pieges-boucles.md)
#           AVANT de le lancer. Chaque cas commence par « == N == ».

atelier=${ATELIER:-/srv/atelier}
vrac="$atelier/photos/en-vrac"

echo "== 1 =="
n=0; for f in $(ls "$vrac"); do n=$(( n + 1 )); done; echo "$n tours"

echo "== 2 =="
n=0; for f in "$vrac"/*; do n=$(( n + 1 )); done; echo "$n tours"

echo "== 3 =="
for f in "$vrac"/*.xyz; do echo "[$f]"; done

echo "== 4 =="
for f in "$vrac"/*.xyz; do [[ -f $f ]] || continue; echo "[$f]"; done; echo "fini"

echo "== 5 =="
n=0; ls "$vrac" | while read -r f; do n=$(( n + 1 )); done; echo "n = $n"

echo "== 6 =="
printf 'un\ndeux' | while read l; do echo "[$l]"; done

echo "== 7 =="
printf '  a\\tb  \n' | while read l; do echo "[$l]"; done
printf '  a\\tb  \n' | while read -r l; do echo "[$l]"; done
printf '  a\\tb  \n' | while IFS= read -r l; do echo "[$l]"; done

echo "== 8 =="
for i in 1 2 3 4 5; do [[ $i -eq 2 ]] && continue; [[ $i -eq 4 ]] && break; echo "$i"; done
