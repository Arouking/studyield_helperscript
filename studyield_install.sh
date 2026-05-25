#!/usr/bin/env bash

# Setup-Sourcen aus dem Community-Framework laden
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  git \
  build-essential \
  curl \
  nginx
msg_ok "Installed Dependencies"

# Node.js 20 und globalen PM2-Prozessmanager bereitstellen
NODE_VERSION="20" setup_nodejs
$STD npm install -g pm2
msg_ok "Installed Node.js and PM2"

msg_info "Cloning Studyield Repository"
cd /opt
git clone https://github.com/studyield/studyield.git
cd studyield

msg_info "Setting up Studyield Backend"
cd /opt/studyield/backend
$STD npm install
if [ -f .env.example ]; then
    cp .env.example .env
fi
$STD npm run migrate
msg_ok "Set up Studyield Backend"

msg_info "Setting up Studyield Frontend"
cd /opt/studyield/frontend
$STD npm install
if [ -f .env.example ]; then
    cp .env.example .env
fi
# Da Studyield laut Anleitung 'npm run dev' nutzt, 
# verzichten wir auf ein statisches Nginx-Hosting und lassen Nginx als Proxy laufen.
msg_ok "Set up Studyield Frontend"

msg_info "Configuring Nginx Reverse Proxy"
cat <<'EOF' >/etc/nginx/sites-available/studyield
server {
    listen 80;
    server_name _;

    # Weiterleitung an das Frontend (Vite läuft standardmäßig auf 5173)
    location / {
        proxy_pass http://127.0.0.1:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Falls das Backend auf einem eigenen Port läuft (z.B. 3000), hier abfangen:
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/studyield /etc/nginx/sites-enabled/studyield
systemctl restart nginx
systemctl enable -q --now nginx
msg_ok "Configured Nginx"

msg_info "Creating PM2 Services for Autostart"
# PM2-Ecosystem-Datei schreiben, damit beide Daemons parallel hochfahren
cat << 'EOF' > /opt/studyield/ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'studyield-backend',
      cwd: '/opt/studyield/backend',
      script: 'npm',
      args: 'run start:dev',
      env: { NODE_ENV: 'development' }
    },
    {
      name: 'studyield-frontend',
      cwd: '/opt/studyield/frontend',
      script: 'npm',
      args: 'run dev',
      env: { NODE_ENV: 'development' }
    }
  ]
};
EOF

# Dienste starten und persistent in systemd verankern
pm2 startup systemd -u root --hp /root
pm2 start /opt/studyield/ecosystem.config.js
pm2 save
msg_ok "Created Services via PM2"

motd_ssh
customize
cleanup_lxc
