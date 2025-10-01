#!/bin/bash
echo "=========================================="
echo "🚀 Welcome to LokalPress Lite Installer"
echo "=========================================="
echo ""
echo "This script will help you quickly set up a local WordPress environment using Lando."
echo "You will provide site details and database credentials, and we will configure everything automatically."
echo ""

# Detect OS for install guidance
OS="$(uname -s)"

# Helper function to suggest installation steps for Docker or Lando
show_install_steps() {
  case "$1" in
    docker)
      echo "❌ Docker is not installed or not running."
      echo "Docker is required for running containers locally."
      case "$OS" in
        Linux*)  echo "👉 On Ubuntu: sudo apt update && sudo apt install -y docker.io && sudo systemctl start docker" ;;
        Darwin*) echo "👉 On macOS: Install Docker Desktop: https://docs.docker.com/desktop/install/mac/" ;;
        MINGW*|CYGWIN*|MSYS*) echo "👉 On Windows: Install Docker Desktop: https://docs.docker.com/desktop/install/windows/" ;;
      esac
      ;;
    lando)
      echo "❌ Lando is not installed or not running."
      echo "Lando is used to manage local WordPress environments effortlessly."
      case "$OS" in
        Linux*)  echo "👉 On Ubuntu: curl -fsSL https://files.lando.dev/install.sh | bash" ;;
        Darwin*) echo "👉 On macOS: brew install --cask lando" ;;
        MINGW*|CYGWIN*|MSYS*) echo "👉 On Windows: Download the Lando installer: https://docs.lando.dev/getting-started/installation.html" ;;
      esac
      ;;
  esac
  read -p "➡️  Please install $1 and press Enter to continue..."
}

# Verify Docker installation
if ! command -v docker >/dev/null 2>&1; then
  show_install_steps docker
fi
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker is installed but not running."
  read -p "➡️  Please start Docker and press Enter to continue..."
fi

# Verify Lando installation
if ! command -v lando >/dev/null 2>&1; then
  show_install_steps lando
fi
if ! lando version >/dev/null 2>&1; then
  echo "❌ Lando is installed but not running correctly."
  read -p "➡️  Please ensure Lando is working and press Enter to continue..."
fi

echo ""
echo "Let's gather some information to configure your local site."
echo "You will be asked for the site URL, site title, and database credentials."
echo ""

# Input loop with confirmation
while true; do
  # URL input with validation
  while true; do
    read -p "Enter the site URL (e.g., lokalpress.test): " SITE_URL
    if [[ "$SITE_URL" =~ ^[a-zA-Z0-9.-]+\.(test|local|code|localhost|site)$ ]]; then
      break
    fi
    echo "❌ Invalid URL. Please use a domain ending with .test, .local, .code, .localhost, or .site"
  done

  read -p "Enter the Site Title: " SITE_TITLE
  read -p "Enter the Database Name: " DB_NAME
  read -p "Enter the Database User: " DB_USER
  read -sp "Enter the Database Password: " DB_PASS
  echo ""

  DB_HOST="database"
  APP_NAME=$(echo "${SITE_TITLE}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '.' '-')

  # Display summary for confirmation
  echo ""
  echo "=========================================="
  echo "Please review your configuration:"
  echo "Site URL:      ${SITE_URL}"
  echo "Site Title:    ${SITE_TITLE}"
  echo "Database Name: ${DB_NAME}"
  echo "Database User: ${DB_USER}"
  echo "Database Pass: ${DB_PASS}"
  echo "App Name:      lokalpress-${APP_NAME}"
  echo "=========================================="
  read -p "Are all details correct? (y/n): " CONFIRM

  [[ "$CONFIRM" == "y" ]] && break
  echo "🔄 Let's re-enter the information to ensure everything is correct."
done

echo ""
echo "📄 Generating Lando configuration file (.lando.yml)..."

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

echo "✅ .lando.yml created successfully."
echo "ℹ️  This file configures your WordPress site, PHP version, database, and tooling."

echo ""
echo "🚀 Starting Lando environment..."
lando start

echo ""
echo "⬇️ Installing WordPress core..."
if [ ! -f "wp-config.php" ]; then
  lando wp core download
  lando wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}"
  lando wp core install \
    --url="${SITE_URL}" \
    --title="${SITE_TITLE}" \
    --admin_user=admin \
    --admin_password=nimad \
    --admin_email=admin@${SITE_URL}
fi

# Optional: Composer install
if [ -f "composer.json" ]; then
  read -p "➡️  Do you want to run 'composer install'? (y/n): " RUN_COMPOSER
  if [[ "$RUN_COMPOSER" == "y" ]]; then
    echo "📦 Running composer install..."
    lando composer install
  fi
fi

# Optional: Database import
if [ -f "db.sql" ]; then
  read -p "➡️  Do you want to import 'db.sql' into the database? (y/n): " RUN_DB
  if [[ "$RUN_DB" == "y" ]]; then
    echo "🗄️ Importing database..."
    lando db-import db.sql
  fi
fi

echo ""
echo "=========================================="
echo "✅ LokalPress Lite setup is complete!"
echo "You can access your site at: http://${SITE_URL}"
echo "Login to WordPress admin at: http://${SITE_URL}/wp-admin"
echo "Username: admin | Password: nimad"
echo "App name: lokalpress-${APP_NAME}"
echo "⚠️ Don't forget to add '${SITE_URL}' to your hosts file if required."
echo "=========================================="
