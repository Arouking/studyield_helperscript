#!/usr/bin/env bash

# Header wie bei tteck
# Source: https://github.com/studyield/studyield

# 1. Framework-Variablen setzen
export APP="Studyield"
export VERSION="1.0"
gslug="studyield"
base_os="debian"
os_version="12"

# 2. Funktionen und Default-Einstellungen laden
   variables
   color
   catch_errors

# 3. Den Container erstellen (Öffnet das interaktive tteck-Menü auf dem Host)
function default_settings() {
  CT_TYPE="1"
  DISK_SIZE="8"
  CORE_COUNT="1"
  RAM_SIZE="2048"
  BRG="vmbr0"
  DISABLEIP6="yes"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
}

# Holt das originale Erstellungs-Skript aus der Community
CORE_DIR="/var/lib/pve/local-certs" # temporärer Pfad für Variablen
msg_info "Erstelle Studyield LXC..."
wget -qLO /tmp/lxc.sh https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/lines/lxc.sh
chmod +x /tmp/lxc.sh
bash /tmp/lxc.sh

# 4. ID des erstellten Containers holen
NEXTID=$(pvesh get /cluster/nextid --output-format json | jq '. | tonumber | . - 1')

# 5. Das eigentliche Installationsskript im neuen Container zünden
msg_info "Starte Studyield Installation im Container..."
pct exec $NEXTID -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/Arouking/studyield_helperscript/main/studyield_install.sh)"

msg_ok "Studyield LXC erfolgreich erstellt!"
