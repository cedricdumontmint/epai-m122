#!/usr/bin/env bash
# entrypoint.sh — démarre le serveur de l'atelier : génère l'atelier au premier
# lancement, puis lance cron au premier plan (c'est le processus principal :
# `docker compose restart atelier` simule donc un redémarrage du serveur, et les
# entrées `@reboot` du crontab se déclenchent).
set -euo pipefail

install -d -o apprenti -g apprenti "${ATELIER:-/srv/atelier}"
runuser -u apprenti -- env "ATELIER=${ATELIER:-/srv/atelier}" /usr/local/bin/atelier-seed

# Sur un vrai serveur, /run est vidé à chaque démarrage. Dans un conteneur il survit à
# `docker compose restart` : sans cette ligne, cron croirait que les tâches @reboot ont
# déjà tourné pendant ce « boot » et les ignorerait.
rm -f /run/crond.reboot

exec cron -f
