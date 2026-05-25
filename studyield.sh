#!/usr/bin/env bash

echo "=== [1/3] Starte offizielles Proxmox-Skript für einen Debian 12 LXC ==="
echo "Bitte wähle im folgenden Menü einfach 'Default' (oder passe es an)."
echo "------------------------------------------------------------------"
sleep 2

# Startet das offizielle, fehlerfreie Debian-Skript der Community
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"

echo "=== [2/3] Ermittle die ID des erstellten Containers ==="
NEXTID=$(pvesh get /cluster/nextid --output-format json | jq '. | tonumber | . - 1')
echo "Gefundene Container-ID: $NEXTID"

echo "=== [3/3] Starte die Studyield-Installation im Container ==="
# Führt dein Installationsskript im neuen Container aus
pct exec $NEXTID -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/Arouking/studyield_helperscript/main/studyield_install.sh?v=5)"
