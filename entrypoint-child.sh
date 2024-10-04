#!/bin/bash
set -e

host="$WORDPRESS_DB_HOST"
user="$WORDPRESS_DB_USER"
password="$WORDPRESS_DB_PASSWORD"
rootpassword="$MYSQL_ROOT_PASSWORD"

# Wait for MySQL to be ready
until mysql -h"$host" -uroot -p"$rootpassword" -e "SELECT 1" >/dev/null 2>&1; do
  echo "Waiting for database connection..."
  sleep 2
done

echo "Database is up - initializing if necessary"

# Create WordPress database if it doesn't exist
mysql -h"$host" -uroot -p"$rootpassword" <<EOSQL
CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;
EOSQL

# Create WordPress user if it doesn't exist and grant privileges
mysql -h"$host" -uroot -p"$rootpassword" <<EOSQL
CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$password';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$user'@'%';
FLUSH PRIVILEGES;
EOSQL

echo "Database initialization completed"

# Run the parent entrypoint
. /usr/local/bin/docker-entrypoint.sh

# Execute the main command
exec "$@"
