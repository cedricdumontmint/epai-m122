# Serveur de l'atelier (atelier-srv) du m122 : Bash, cron, PowerShell 7, outils GNU.
# Construit pour amd64 ET arm64 : l'image officielle mcr.microsoft.com/powershell
# n'existe pas en arm64, on installe donc l'archive officielle de PowerShell nous-mêmes.
FROM debian:bookworm-slim

# BuildKit renseigne TARGETARCH (amd64 | arm64) ; l'ancien constructeur ne le fait pas
# (voir l'étape d'installation de PowerShell, qui prévoit ce cas).
ARG TARGETARCH
# Version épinglée et empreintes SHA-256 lues dans le fichier hashes.sha256 de la
# version (GitHub PowerShell/PowerShell, v7.6.10). À relire le jour d'un changement.
ARG PWSH_VERSION=7.6.10
ARG PWSH_SHA256_AMD64=e261cabc91c78a9afe8d1e5f24731ab0d38204735ab2ec94b0af55102652e10d
ARG PWSH_SHA256_ARM64=439432cdecf4418413b9a8f547e3ab4d9b40e8e4258913ec3d15fc92c67a9235

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Zurich \
    LANG=fr_CH.UTF-8 \
    LANGUAGE=fr_CH:fr \
    ATELIER=/srv/atelier \
    POWERSHELL_TELEMETRY_OPTOUT=1 \
    POWERSHELL_UPDATECHECK=Off

# Outils du cours : shell et utilitaires GNU, cron, flock (util-linux), rsync, tree,
# réseau (ping, nc), analyse statique (shellcheck), tests (bats), et les bibliothèques
# dont PowerShell a besoin (ICU pour les accents, OpenSSL).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash bats bsdextrautils bzip2 ca-certificates coreutils cron curl diffutils \
      file findutils gawk grep gzip iputils-ping less libicu72 libssl3 locales \
      nano netcat-openbsd procps psmisc rsync sed shellcheck sudo tar tree tzdata \
      unzip util-linux vim-tiny zip \
 && sed -i 's/^# *\(fr_CH.UTF-8\)/\1/' /etc/locale.gen && locale-gen \
 && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone \
 && rm -rf /var/lib/apt/lists/*

# PowerShell 7 : archive officielle, intégrité vérifiée par SHA-256.
RUN set -eu; \
    # Sans BuildKit (ancien constructeur), TARGETARCH est vide : on lit l'architecture du système.
    ARCH_DEB="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${ARCH_DEB}" in \
      amd64) ARCH=x64;   SUM="${PWSH_SHA256_AMD64}" ;; \
      arm64) ARCH=arm64; SUM="${PWSH_SHA256_ARM64}" ;; \
      *) echo "Architecture non prise en charge : ${ARCH_DEB}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/pwsh.tar.gz \
      "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-${ARCH}.tar.gz"; \
    echo "${SUM}  /tmp/pwsh.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/microsoft/powershell/7; \
    tar -xzf /tmp/pwsh.tar.gz -C /opt/microsoft/powershell/7; \
    chmod +x /opt/microsoft/powershell/7/pwsh; \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh; \
    rm /tmp/pwsh.tar.gz

# Comptes : « apprenti » (l'élève, sans droits d'administration) et « invite »
# (pour tester ce qu'un autre utilisateur peut lire ou exécuter).
RUN useradd -m -u 1000 -s /bin/bash apprenti \
 && useradd -m -u 1001 -s /bin/bash invite \
 && printf '%s\n' \
      'apprenti ALL=(root) NOPASSWD: /usr/bin/install, /usr/bin/chown, /usr/bin/chmod' \
      'apprenti ALL=(invite) NOPASSWD: ALL' > /etc/sudoers.d/apprenti \
 && chmod 0440 /etc/sudoers.d/apprenti \
 && visudo -cf /etc/sudoers.d/apprenti \
 && install -d -o apprenti -g apprenti /srv/atelier /home/apprenti/travaux \
 && printf '%s\n' "PS1='\\u@atelier-srv:\\w\\\$ '" >> /home/apprenti/.bashrc

COPY init/atelier-seed.sh /usr/local/bin/atelier-seed
COPY init/atelier-reset   /usr/local/bin/atelier-reset
COPY entrypoint.sh        /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/atelier-seed /usr/local/bin/atelier-reset /usr/local/bin/entrypoint.sh

WORKDIR /home/apprenti
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
