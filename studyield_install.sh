#!/usr/bin/env bash
# Dieses Skript wird auf dem Proxmox-Host aufgerufen!

# 1. Variablen setzen
NEXTID=$(pvesh get /cluster/nextid)
INTEGER='^[0-9]+$'
echo -ge "Verwende freie CT-ID: $NEXTID"

# 2. Framework der Community-Scripts laden
BOOTSTRAP_URL="https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/lines/lxc.sh"
export FUNCTIONS_FILE_PATH="https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/lines/functions.sh"

# 3. LXC erstellen (Standard-Werte: Debian 12, 2GB RAM, 8GB Speicher)
bash -c "$(curl -fsSL $BOOTSTRAP_URL)" "" "studyield" "debian-12"

# 4. Dein angepasstes Installationsskript im neuen Container starten
# (Ersetze die URL mit deinem eigenen GitHub-Repository oder Server)
pct exec $NEXTID -- bash -c "$(curl -fsSL https://dein-github/studyield_install.sh)"
