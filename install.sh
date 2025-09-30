#!/bin/bash
echo "=========================================="
echo "   🚀 LokalPress Lite - Quick Setup"
echo "=========================================="

# URL validation loop
while true; do
    read -p "Enter your site URL (e.g., lokalpress.test): " SITE_URL
    if [[ "$SITE_URL" =~ ^[a-zA-Z0-9.-]+\.(test|local|dev|localhost)$ ]]; then
        break
    else
        echo "❌ Invalid URL. Use a domain ending with .test, .local, .dev or localhost"
    fi
done

read -p "Enter Site Title/Name: " SITE_TITLE
read -p "Enter MySQL database name: " DB_NAME
read -p "Enter MySQL user: " DB_USER
read -sp "Enter MySQL password: " DB_PASS
echo ""

DB_HOST="database"
APP_NAME=$(echo "${SITE_TITLE}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '.' '-')

cat > .lando.yml <<EOL
name: lokalpress-${APP_NAME}
recipe: wordpress
config:
  webroot: .
  php: '8.2'
  via: nginx
  database: mariadb
services:
  database:
    type: mariadb:10.6
proxy:
  appserver_nginx:
    - ${SITE_URL}
tooling:
  composer:
    service: appserver
  wp:
    service: appserver
EOL

lando start

if [ ! -f "wp-config.php" ]; then
    lando wp core download
    lando wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASS}" --dbhost="${DB_HOST}"
    lando wp core install --url="${SITE_URL}" --title="${SITE_TITLE}" --admin_user=admin --admin_password=admin --admin_email=admin@${SITE_URL}
fi

if [ -f "composer.json" ]; then
    lando composer install
fi

echo "=========================================="
echo "✅ Setup complete!"
echo "Visit: http://${SITE_URL}"
echo "Login: admin / admin"
echo "App name: lokalpress-${APP_NAME}"
echo "⚠️ Add '${SITE_URL}' to your hosts file for local access."
echo "=========================================="

