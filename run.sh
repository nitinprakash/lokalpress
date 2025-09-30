if [ ! -d "./wp-admin" ]; then
	wp core download
fi

if ! $(wp core is-installed); then
	wp core install --url="http://wp-studio.code" --title="WP Studio" --admin_user="admin" --admin_password="password" --admin_email="admin@wp-studio.code" --skip-email
fi


