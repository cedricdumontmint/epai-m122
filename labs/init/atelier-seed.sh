#!/usr/bin/env bash
# atelier-seed.sh — génère l'atelier fictif de Menuiserie Dubois SA.
#
# Usage   : atelier-seed.sh [--force]
# Variable: ATELIER  racine à générer (défaut : /srv/atelier)
#
# Le contenu est reproductible : mêmes noms, mêmes tailles, mêmes lignes de journal
# (générateur pseudo-aléatoire à graine fixe, indépendant de la machine). Seules les
# dates suivent l'horloge : elles sont calculées par rapport à « maintenant », pour que
# `find -mtime` donne le même résultat un lundi comme un vendredi.
#
# Sans option, ne fait rien si l'atelier existe déjà. Avec --force, vide l'atelier
# (uniquement s'il porte le marqueur .seed-ok laissé par ce script) puis le régénère.
#
# Codes de sortie : 0 succès · 1 erreur · 2 mauvais usage
set -euo pipefail
umask 022

ROOT="${ATELIER:-/srv/atelier}"
MARQUEUR="$ROOT/.seed-ok"
FORCE=0

case "${1:-}" in
  "")        ;;
  --force)   FORCE=1 ;;
  *)         echo "Usage : ${0##*/} [--force]" >&2; exit 2 ;;
esac

case "$ROOT" in
  /|"")      echo "Racine refusée : '$ROOT'" >&2; exit 2 ;;
  /*)        ;;
  *)         echo "La racine doit être un chemin absolu : '$ROOT'" >&2; exit 2 ;;
esac

if [ -e "$MARQUEUR" ]; then
  if [ "$FORCE" -eq 0 ]; then
    echo "L'atelier existe déjà dans $ROOT (utilisez --force pour le régénérer)."
    exit 0
  fi
  find "$ROOT" -mindepth 1 -delete
elif [ -d "$ROOT" ] && [ -n "$(ls -A "$ROOT")" ]; then
  echo "$ROOT n'est pas vide et n'a pas été créé par ce script : abandon." >&2
  exit 1
fi
mkdir -p "$ROOT"

# --- générateur pseudo-aléatoire (Park-Miller) : rnd N → $R dans [0, N[ ----------
SEED=42
rnd() { SEED=$(( SEED * 16807 % 2147483647 )); R=$(( SEED % $1 )); }

NOW=$(date +%s)

# mk <chemin relatif> <âge en jours> [minutes en plus] : fichier factice daté
mk() {
  local chemin="$ROOT/$1"
  mkdir -p "${chemin%/*}"
  printf 'Fichier factice - Menuiserie Dubois SA\n%s\n' "$1" > "$chemin"
  touch -d "@$(( NOW - $2 * 86400 - ${3:-0} * 60 ))" -- "$chemin"
}

# --- devis/ --------------------------------------------------------------------
CLIENTS=("Dupont" "Müller-Bossy" "Castella" "Pasquier" "Rime" "Ruffieux" "Gachet"
         "Overney" "Menoud" "Sudan" "Cottier" "Jaquet" "Seydoux" "Remy" "Python"
         "Brodard" "Tornare" "Villard" "Morand" "Bertschy")
for client in "${CLIENTS[@]}"; do
  rnd 3; versions=$(( R + 1 ))
  for ((v = 1; v <= versions; v++)); do
    rnd 380; mk "devis/Devis $client (v$v).pdf" $(( R + 5 ))
  done
done
mk "devis/Devis Châtel-St-Denis (cuisine).pdf" 12

# --- factures/ -----------------------------------------------------------------
numero=300
for annee in 2025 2026; do
  if [ "$annee" = 2025 ]; then nb=90; base=300; else nb=70; base=0; fi
  for ((i = 0; i < nb; i++)); do
    numero=$(( numero + 1 ))
    rnd ${#CLIENTS[@]}; nom="${CLIENTS[$R]}"
    rnd 300; mk "factures/$annee/Facture 0$numero – $nom.pdf" $(( base + R + 1 ))
  done
done

# --- plans/ --------------------------------------------------------------------
CHANTIERS=("Escalier hélicoïdal Seydoux" "Cuisine Châtel-St-Denis"
           "Agencement Café du Gruyère" "Bibliothèque Müller-Bossy"
           "Garde-robe Cottier" "Terrasse Dupont" "Armoire d'entrée Pasquier"
           "Salle de bain Jaquet" "Pergola Remy" "Comptoir boulangerie Tornare"
           "Mezzanine Villard" "Porte coulissante Morand")
FICHIERS_PLAN=("plan-v1.dwg" "plan-v2.dwg" "coupe A.pdf" "liste de débit.xlsx"
               "vue 3D (rendu).png" "métré.xlsx")
for chantier in "${CHANTIERS[@]}"; do
  rnd 250; age=$(( R + 20 ))
  for fichier in "${FICHIERS_PLAN[@]}"; do
    rnd 4; [ "$R" -eq 0 ] && continue
    mk "plans/$chantier/$fichier" "$age"
  done
done

# --- photos/chantiers/ : photos déjà rangées, une par mois (cible de la S06) -------
POOL=("img-0388" "img-0391" "cuisine-chatel" "escalier-seydoux" "pergola-remy"
      "salle-de-bain" "detail-charniere" "pose-plan-de-travail" "avant-travaux"
      "apres-travaux")
for ((m = 2; m <= 7; m++)); do
  mois=$(date -d "$m months ago" +%Y-%m)
  rnd 4; nb=$(( R + 8 ))
  for ((i = 0; i < nb; i++)); do
    rnd 27; jour=$(( R + 1 ))
    rnd ${#POOL[@]}
    nom="$(printf '%s-%02d' "$mois" "$jour")_${POOL[$R]}-$i.jpg"
    age=$(( (NOW - $(date -d "$mois-$(printf '%02d' "$jour")" +%s)) / 86400 ))
    mk "photos/chantiers/$mois/$nom" "$age"
  done
done

# --- photos/en-vrac/ : 45 photos à ranger (S06) --------------------------------
# Noms volontairement piégés : espaces, accents, parenthèses, crochets, apostrophe,
# tiret initial, points multiples, sans extension, et une collision après nettoyage.
mk_vrac() { rnd 90; mk "photos/en-vrac/$1" $(( R + 3 )); }
for ((i = 1; i <= 21; i++)); do mk_vrac "$(printf 'IMG_04%02d.JPG' "$i")"; done
for nom in "Chantier Châtel.jpg" "Chantier Châtel (2).jpg" "Chantier Châtel (3).jpg" \
           "-brouillon.jpg" "salle de bain [v1].jpg" "salle de bain [v2].jpg" \
           "été 2025.jpg" "Été 2025 (bis).jpg" "escalier (final).jpeg" \
           "Pergola  Remy.jpg" "cuisine d'Anaïs.jpg" "mesures 1.5m.JPG" \
           "photo.finale.v2.jpg" "IMG_9999" "tiret-final-.jpg" \
           "détail charnière.png" "Vue d'ensemble.JPG" "façade nord.jpg" \
           "Photo 7.JPG" "Photo 8.JPG" "croquis client.png" "PXL_20260103.jpg"; do
  mk_vrac "$nom"
done
# Collision : « Photo 12.JPG » et « photo-12.jpg » donnent le même nom nettoyé le même jour.
mk "photos/en-vrac/Photo 12.JPG" 17
mk "photos/en-vrac/photo-12.jpg" 17

# --- scans/ : fichiers volumineux (taille apparente ≠ place réellement occupée) ------
i=0
for taille in 5M 12M 25M 40M 80M 120M; do
  i=$(( i + 1 ))
  scan="scans/Scan archive fournisseur $i.pdf"
  mk "$scan" $(( i * 40 ))
  truncate -s "$taille" "$ROOT/$scan"                       # modifie la date…
  touch -d "@$(( NOW - i * 40 * 86400 ))" -- "$ROOT/$scan"  # …on la rétablit
done

# --- tmp/ : temporaires de tous âges (cible de la S08) ---------------------------
for ((i = 1; i <= 40; i++)); do
  rnd 200;  jours=$(( R + 1 ))
  rnd 1000; minutes=$R
  mk "$(printf 'tmp/brouillon-devis-%02d.tmp' "$i")" "$jours" "$minutes"
done
for ((i = 1; i <= 15; i++)); do
  rnd ${#CLIENTS[@]}; nom="${CLIENTS[$R]}"
  rnd 120; mk "tmp/~\$Devis $nom $i.docx" $(( R + 1 ))
done
for ((i = 1; i <= 25; i++)); do
  rnd 200; mk "$(printf 'tmp/plan-%02d.bak' "$i")" $(( R + 1 ))
done
# Cas limites de « plus de 30 jours » (find -mtime +30 ne retient que ≥ 31 jours) :
mk "tmp/rapport-semaine.tmp"   30 -1   # 30 jours moins une minute
mk "tmp/rapport-trimestre.tmp" 30  1   # 30 jours plus une minute : -mtime +30 l'ignore
mk "tmp/rapport-mois.tmp"      31      # 31 jours : -mtime +30 le retient

# --- sauvegardes/ : vide au départ ---------------------------------------------
mkdir -p "$ROOT/sauvegardes"

# --- journaux/ : 4 000 lignes sur 7 jours, jusqu'à hier soir ----------------------
mapfile -t CHEMINS < <(cd "$ROOT" && find devis factures plans photos -type f | LC_ALL=C sort)
UTILISATEURS=(sophie.dubois sophie.dubois sophie.dubois sophie.dubois
              marc.dubois marc.dubois marc.dubois
              lea.bapst lea.bapst lea.bapst
              jerome.ruffieux jerome.ruffieux jerome.ruffieux
              nicolas.gachet nicolas.gachet fatima.zurcher fatima.zurcher
              thierry.overney samuel.pythoud SOPHIE.DUBOIS)
mkdir -p "$ROOT/journaux"
JOURNAL="$ROOT/journaux/journal-atelier.log"
: > "$JOURNAL"
total=0
for ((jour = 7; jour >= 1; jour--)); do
  if [ "$jour" -eq 1 ]; then lignes=574; else lignes=571; fi
  t=$(date -d "$jour days ago 07:30" +%s)
  for ((n = 0; n < lignes; n++)); do
    rnd 90; t=$(( t + R + 5 ))
    rnd ${#UTILISATEURS[@]}; qui="${UTILISATEURS[$R]}"
    rnd ${#CHEMINS[@]};      chemin="${CHEMINS[$R]}"
    rnd 100
    if   [ "$R" -lt 68 ]; then action=OPEN
    elif [ "$R" -lt 88 ]; then action=SAVE
    elif [ "$R" -lt 91 ]; then action=DELETE
    else                       action=DENIED
    fi
    if [ "$action" = OPEN ] && { [ "$qui" = nicolas.gachet ] || [ "$qui" = samuel.pythoud ]; }; then
      rnd 100; [ "$R" -lt 12 ] && action=DENIED
    fi
    printf '%(%Y-%m-%d %H:%M:%S)T %s %s %s\n' "$t" "$qui" "$action" "$chemin" >> "$JOURNAL"
    total=$(( total + 1 ))
  done
done
sed 's/$/\r/' "$JOURNAL" > "$ROOT/journaux/journal-atelier-windows.log"

touch "$MARQUEUR"
nb_fichiers=$(find "$ROOT" -type f ! -name .seed-ok | wc -l)
echo "Atelier généré dans $ROOT : $nb_fichiers fichiers, $total lignes de journal."
