#!/bin/bash
set -e

echo "🚀 Starting WordPress install helper"

read -p "Do you want to import the database from db.sql? (y/n): " importdb
if [[ "$importdb" == "y" || "$importdb" == "Y" ]]; then
  if [ -f /app/db.sql ]; then
    echo "📥 Importing database..."
    mysql -h database -u wpstudio -pwpstudio wpstudio < /app/db.sql
    echo "✅ Database imported."
  else
    echo "⚠️ No db.sql file found in /app"
  fi
fi

read -p "Do you want to run composer install? (y/n): " installcomp
if [[ "$installcomp" == "y" || "$installcomp" == "Y" ]]; then
  echo "📦 Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist
  echo "✅ Composer install complete."
fi

read -p "Do you want to activate theme and plugins? (y/n): " activate
if [[ "$activate" == "y" || "$activate" == "Y" ]]; then
  echo "🎨 Activating theme and plugins..."
  wp theme activate twentytwentyfive
  wp plugin activate woocommerce wps-hide-login wc-thanks-redirect-pro
  echo "✅ Plugins and theme activated."
fi

echo "🎉 Done!"

