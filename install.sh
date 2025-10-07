#!/bin/bash
echo "=========================================="
echo "🚀 Welcome to LokalPress Lite Installer"
echo "=========================================="
echo ""
echo "This script sets up a local WordPress environment using Lando."
echo "You will provide a site title and database credentials, and we will configure everything automatically."
echo "Compatible with Linux and Windows (via Git Bash or WSL)."
echo ""
echo "Not tested with MacOS yet!"
echo ""

# ------------------------------------------
# Detect operating system
# ------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Linux*)   OS_NAME="Linux" ;;
  Darwin*)  OS_NAME="macOS" ;;
  CYGWIN*|MINGW*|MSYS*) OS_NAME="Windows (Git Bash)" ;;
  *)        OS_NAME="Unknown" ;;
esac
echo "🧠 Detected operating system: $OS_NAME"
echo ""

# ------------------------------------------
# Helper for installation steps
# ------------------------------------------
show_install_steps() {
  local tool=$1
  echo "❌ $tool is not installed or not running."
  case "$tool" in
    docker)
      echo "👉 Download Docker: https://www.docker.com/get-started"
      ;;
    lando)
      echo "👉 Download Lando: https://docs.lando.dev/getting-started/installation.html"
      ;;
  esac
  read -p "➡️  Please install $tool and press Enter to continue..."
  echo ""
}

# ------------------------------------------
# Verify Docker
# ------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  show_install_steps docker
else
  echo "✅ Docker detected: $(docker --version | head -n 1)"
fi

# ------------------------------------------
# Find Lando command cross-platform
# ------------------------------------------
LANDO_CMD=""
if command -v lando >/dev/null 2>&1; then
  LANDO_CMD="lando"
elif command -v lando.cmd >/dev/null 2>&1; then
  LANDO_CMD="lando.cmd"
elif command -v lando.exe >/dev/null 2>&1; then
  LANDO_CMD="lando.exe"
else
  show_install_steps lando
fi

# ------------------------------------------
# Verify Lando version output
# ------------------------------------------
LANDO_VERSION_OUTPUT=$($LANDO_CMD version 2>&1)
if echo "$LANDO_VERSION_OUTPUT" | grep -qi "lando"; then
  echo "✅ Lando detected: $(echo "$LANDO_VERSION_OUTPUT" | head -n 1)"
else
  echo "⚠️  Lando found but version output was unexpected."
  echo "$LANDO_VERSION_OUTPUT"
  read -p "➡️  Please verify Lando setup and press Enter..."
fi
echo ""

# ------------------------------------------
# Gather site configuration
# ------------------------------------------
while true; do
  read -p "🏷️  Enter the Site Title: " SITE_TITLE
  read -p "📦 Enter the Database Name: " DB_NAME
  read -p "👤 Enter the Database User: " DB_USER
  read -sp "🔒 Enter the Database Password: " DB_PASS
  echo ""
  
  DB_HOST="database"
  
  APP_NAME=$(echo "${SITE_TITLE}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]' | cut -c1-8)
  APP_FULL="lokalpress-${APP_NAME}"
  SITE_URL="${APP_NAME}.lndo.site"
  
  echo ""
  echo "=========================================="
  echo "📋 Review your configuration:"
  echo "Site Title:    ${SITE_TITLE}"
  echo "Database Name: ${DB_NAME}"
  echo "Database User: ${DB_USER}"
  echo "Database Pass: ${DB_PASS}"
  echo "App Name:      ${APP_FULL}"
  echo "Site URL:      http://${SITE_URL}"
  echo "=========================================="
  read -p "Are all details correct? (y/n): " CONFIRM
  [[ "$CONFIRM" == "y" ]] && break
  echo "🔄 Let's re-enter the information to ensure everything is correct."
done

# ------------------------------------------
# Generate .lando.yml
# ------------------------------------------
echo ""
echo "🛠️  Generating .lando.yml..."
cat > .lando.yml <<EOL
name: ${APP_FULL}
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
      user: ${DB_USER}
      password: ${DB_PASS}
      database: ${DB_NAME}
proxy:
  appserver:
    - ${SITE_URL}
tooling:
  composer:
    service: appserver
  wp:
    service: appserver
EOL
echo "✅ .lando.yml created successfully."
echo "ℹ️  This file configures your WordPress site, PHP version, database, and tooling."
echo ""

# ------------------------------------------
# Start Lando environment
# ------------------------------------------
echo "🚀 Starting Lando environment..."
$LANDO_CMD start
if [ $? -ne 0 ]; then
  echo "❌ Lando failed to start. Please check Docker/Lando setup."
  exit 1
fi

# ------------------------------------------
# Install WordPress Core
# ------------------------------------------
echo ""
echo "⬇️ Installing WordPress core..."
if [ ! -f "wp-config.php" ]; then
  $LANDO_CMD wp core download
  $LANDO_CMD wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}"
  $LANDO_CMD wp core install \
    --url="${SITE_URL}" \
    --title="${SITE_TITLE}" \
    --admin_user=admin \
    --admin_password=nimad \
    --admin_email=admin@${SITE_URL}
fi

# ------------------------------------------
# Optional composer install
# ------------------------------------------
if [ -f "composer.json" ]; then
  read -p "➡️  Run 'composer install'? (y/n): " RUN_COMPOSER
  if [[ "$RUN_COMPOSER" == "y" ]]; then
    echo "📦 Installing Composer dependencies..."
    $LANDO_CMD composer install
  fi
fi

# ------------------------------------------
# Optional db import
# ------------------------------------------
if [ -f "db.sql" ]; then
  read -p "➡️  Import 'db.sql' into database? (y/n): " RUN_DB
  if [[ "$RUN_DB" == "y" ]]; then
    echo "🗄️ Importing database..."
    $LANDO_CMD db-import db.sql
  fi
fi

# ------------------------------------------
# Done
# ------------------------------------------
echo ""
echo "=========================================="
echo "✅ LokalPress Lite setup complete!"
echo "You can access your site at: http://${SITE_URL}"
echo "Login to WordPress admin at: http://${SITE_URL}/wp-admin"
echo "Username: admin | Password: nimad"
echo "App name: ${APP_FULL}"
echo "=========================================="
