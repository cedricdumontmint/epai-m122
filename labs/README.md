# m122 — Le serveur de l'atelier (lab)

Un petit serveur Linux jetable, `atelier-srv`, pour s'exercer sans risque : **Bash**,
**PowerShell 7**, **cron** et les outils GNU habituels. Il contient l'atelier fictif de
**Menuiserie Dubois SA** (devis, plans, photos, journaux…) sur lequel porteront vos scripts.
Il fonctionne sur PC et sur Mac (Intel ou Apple Silicon). Aucun mot de passe.

## Démarrer

```bash
docker compose up -d --build   # 1re fois : construit l'image (quelques minutes, connexion Internet)
docker compose up -d           # les fois suivantes
```

Entrer dans le serveur, en Bash ou en PowerShell :

```bash
docker compose exec --user apprenti atelier bash
docker compose exec --user apprenti atelier pwsh
```

Arrêter ou redémarrer (le redémarrage simule un **redémarrage du serveur**) :

```bash
docker compose stop            # arrêter (tout est conservé)
docker compose start           # relancer
docker compose restart         # redémarrer le serveur
docker compose down            # supprimer le conteneur (voir « Ce qui est conservé »)
```

## Où se trouvent les choses

| Dans le serveur | Sur votre ordinateur | À quoi ça sert |
|-----------------|----------------------|----------------|
| `~/travaux/` | `labs/travaux/` | **vos scripts** : écrivez-les avec votre éditeur habituel, lancez-les dans le serveur |
| `~/data/` (lecture seule) | `data/` | jeux de données du cours |
| `/srv/atelier/` | (volume Docker) | l'atelier fictif : `devis/`, `factures/`, `plans/`, `photos/`, `scans/`, `tmp/`, `journaux/`, `sauvegardes/` |

La variable `ATELIER` contient `/srv/atelier` : **n'écrivez jamais ce chemin en dur** dans un
script, utilisez la variable.

## Remettre l'atelier à neuf

Si vous avez supprimé ou abîmé des fichiers pendant un exercice :

```bash
atelier-reset
```

Les fichiers sont toujours les mêmes (mêmes noms, mêmes tailles) ; seules leurs **dates**
sont recalculées par rapport à aujourd'hui.

## Ce qui est conservé, ce qui ne l'est pas

| Opération | `/srv/atelier` | `~/travaux` | crontab, scripts installés dans `~/bin` ou `/usr/local/bin` |
|-----------|----------------|-------------|--------------------------------------------------------------|
| `stop` / `start` / `restart` | conservé | conservé | conservés |
| `down` | conservé | conservé | **perdus** (le conteneur est recréé) |
| `down -v` | **perdu** (régénéré au lancement) | conservé | **perdus** |

Gardez donc vos scripts dans `~/travaux` ; l'installation (copie dans `~/bin`) se refait vite.

## Comptes et droits

- `apprenti` : vous. Pas d'administrateur : c'est voulu, il faut apprendre à travailler avec
  des droits limités. Pour les exercices d'installation (session 10), `sudo` n'autorise que
  `install`, `chown` et `chmod`.
- `invite` : un autre utilisateur, pour tester ce qu'une autre personne peut lire ou lancer :
  `sudo -u invite <commande>`.
- Fuseau horaire `Europe/Zurich`, langue `fr_CH.UTF-8`.

## Outils installés

`bash`, `pwsh` (PowerShell 7), `cron`/`crontab`, `flock`, `find`, `grep`, `sed`, `gawk`, `sort`,
`tar`, `gzip`, `zip`, `rsync`, `tree`, `ping`, `nc`, `nano`, `vim`, `shellcheck`, `bats`.
Pas de `systemd` dans un conteneur : le « démarrage au boot » se travaille avec `@reboot`
(cron) et `docker compose restart atelier`.

## Contenu du dossier

- `docker-compose.yml` — le service `atelier`
- `Dockerfile` — l'image : Debian, outils, PowerShell 7 (archive officielle vérifiée par SHA-256)
- `entrypoint.sh` — génère l'atelier au premier lancement puis démarre `cron`
- `init/atelier-seed.sh` — génère l'atelier fictif (reproductible) ; `init/atelier-reset` le remet à neuf
- `travaux/` — vos scripts
- `reference/` — corrigés de référence, **remis seulement après usage** (jamais chargés automatiquement)

## Pour les enseignants

- Image construite pour **amd64 et arm64** : l'image officielle `mcr.microsoft.com/powershell`
  n'existe pas en arm64, c'est pourquoi PowerShell est installé depuis son archive officielle.
  La version et les empreintes SHA-256 sont épinglées dans le `Dockerfile`.
- **Nom de projet** : `docker-compose.yml` déclare `name: m122`. Sans lui, Compose nomme le projet d'après le dossier (`labs`), le même nom que le m164 : les deux cours partageraient réseau et projet.
- **`@reboot`** : Debian ne lance les tâches `@reboot` qu'une fois par démarrage grâce au fichier `/run/crond.reboot`, qui survit à `docker compose restart` ; `entrypoint.sh` le supprime pour simuler un vrai boot.
- **Cron sans courrier** : aucun MTA n'est installé, la sortie d'une tâche cron non redirigée est perdue (c'est un piège enseigné en S11).
- **Windows** : le Planificateur de tâches et PowerShell 5.1 se pratiquent sur un poste ou une
  VM Windows ; le jeu de données équivalent (`C:\Atelier\`) sera fourni avec la session 11.
