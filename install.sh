#!/bin/bash
echo "=========================================="
echo "   🚀 LokalPress Lite - Quick Setup"
echo "=========================================="

# Detect OS
OS="$(uname -s)"

# Helper to show install steps
show_install_steps() {
  case "$1" in
    docker)
      echo "❌ Docker not found."
      case "$OS" in
        Linux*)  echo "👉 Ubuntu: sudo apt update && sudo apt install -y docker.io && sudo systemctl start docker" ;;
        Darwin*) echo "👉 macOS: Install Docker Desktop: https://docs.docker.com/desktop/install/mac/" ;;
        MINGW*|CYGWIN*|MSYS*) echo "👉 Windows: Install Docker Desktop: https://docs.docker.com/desktop/install/windows/" ;;
      esac
      ;;
    lando)
      echo "❌ Lando not found."
      case "$OS" in
        Linux*)  echo "👉 Ubuntu: curl -fsSL https://files.lando.dev/install.sh | bash" ;;
        Darwin*) echo "👉 macOS: brew install --cask lando" ;;
        MINGW*|CYGWIN*|MSYS*) echo "👉 Windows: Download Lando installer: https://docs.lando.dev/getting-started/installation.html" ;;
      esac
      ;;
  esac
  read -p "➡️  Install $1 now, then press Enter to continue..."
}

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
  show_install_steps docker
fi
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker not running. Start Docker Desktop / service."
  read -p "➡️  Start Docker, then press Enter to continue..."
fi

# Check Lando
if ! command -v lando >/dev/null 2>&1; then
  show_install_steps lando
fi
if ! lando version >/dev/null 2>&1; then
  echo "❌ Lando not running properly."
  read -p "➡️  Ensure Lando is installed & working, then press Enter..."
fi

# Input loop until confirmation
while true; do
  # URL input + validation
  while true; do
    read -p "Enter site URL (e.g., lokalpress.test): " SITE_URL
    [[ "$SITE_URL" =~ ^[a-zA-Z0-9.-]+\.(test|local|code|localhost|site)$ ]] && break
    echo "❌ Invalid URL. Must end with .test, .local, .code, localhost or .site"
  done

  read -p "Enter Site Title: " SITE_TITLE
  read -p "Enter DB Name: " DB_NAME
  read -p "Enter DB User: " DB_USER
  read -sp "Enter DB Pass: " DB_PASS; echo ""

  DB_HOST="database"
  APP_NAME=$(echo "${SITE_TITLE}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '.' '-')

  echo ""
  echo "=========================================="
  echo "Please confirm your details:"
  echo "Site URL:   ${SITE_URL}"
  echo "Site Title: ${SITE_TITLE}"
  echo "DB Name:    ${DB_NAME}"
  echo "DB User:    ${DB_USER}"
  echo "DB Pass:    ${DB_PASS}"
  echo "App Name:   lokalpress-${APP_NAME}"
  echo "=========================================="
  read -p "Are these correct? (y/n): " CONFIRM

  [[ "$CONFIRM" == "y" ]] && break
  echo "🔄 Let's try again..."
done

# Generate .lando.yml
cat > .lando.yml <<EOL
name: lokalpress-${APP_NAME}
recipe: wordpress
config:
  webroot: .
  php: '8.2'
  via: apache
  database: mariadb
services:
  database:
    type: mariadb:10.11
    creds:
      user: $DB_USER
      password: $DB_PASS
      database: $DB_NAME
proxy:
  appserver:
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
  lando wp core install --url="${SITE_URL}" --title="${SITE_TITLE}" --admin_user=admin --admin_password=nimad --admin_email=admin@${SITE_URL}
fi

# Composer install (ask user)
if [ -f "composer.json" ]; then
  read -p "➡️  Run composer install? (y/n): " RUN_COMPOSER
  [[ "$RUN_COMPOSER" == "y" ]] && lando composer install
fi

# DB import (ask user)
if [ -f "db.sql" ]; then
  read -p "➡️  Import db.sql into DB '${DB_NAME}'? (y/n): " RUN_DB
  [[ "$RUN_DB" == "y" ]] && lando db-import db.sql
fi

echo "=========================================="
echo "✅ Setup complete!"
echo "Visit: http://${SITE_URL}"
echo "Login: admin / nimad"
echo "App: lokalpress-${APP_NAME}"
echo "⚠️ Add '${SITE_URL}' to your hosts file to start using the local site"
echo "=========================================="

