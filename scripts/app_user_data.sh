#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

dnf update -y
dnf install -y nodejs

mkdir -p /opt/app
cd /opt/app

cat << 'EOT' > server.js
const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.json({
    message: "✅ App Tier is Running Successfully!",
    tier: "Application Tier",
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`App Tier listening on port ${port}`);
});
EOT

cat << 'EOT' > package.json
{
  "name": "three-tier-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.19.2"
  }
}
EOT

npm install

cat << 'EOT' > /etc/systemd/system/nodeapp.service
[Unit]
Description=Three Tier Node.js App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable nodeapp
systemctl start nodeapp

echo "=== App Tier bootstrap completed successfully at $(date) ===" >> /var/log/user-data.log