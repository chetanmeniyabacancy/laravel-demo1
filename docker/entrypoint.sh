#!/usr/bin/env sh
set -eu

cd /var/www/html

# Local-friendly defaults so container can run without any env flags.
export APP_NAME="${APP_NAME:-Laravel}"
export APP_ENV="${APP_ENV:-local}"
export APP_DEBUG="${APP_DEBUG:-true}"
export APP_URL="${APP_URL:-http://localhost:8101}"
export DB_CONNECTION="${DB_CONNECTION:-sqlite}"
export DB_DATABASE="${DB_DATABASE:-/var/www/html/database/database.sqlite}"
export SESSION_DRIVER="${SESSION_DRIVER:-file}"
export CACHE_STORE="${CACHE_STORE:-file}"
export QUEUE_CONNECTION="${QUEUE_CONNECTION:-sync}"

mkdir -p \
  /var/www/html/storage/framework/cache/data \
  /var/www/html/storage/framework/sessions \
  /var/www/html/storage/framework/views \
  /var/www/html/storage/logs \
  /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache

if [ "${DB_CONNECTION}" = "sqlite" ] && [ ! -f "${DB_DATABASE}" ]; then
  mkdir -p "$(dirname "${DB_DATABASE}")"
  touch "${DB_DATABASE}"
fi

# If APP_KEY is missing:
# - production: fail fast so secrets are set explicitly
# - non-production: auto-generate an ephemeral key for convenience
if [ -z "${APP_KEY:-}" ]; then
  if [ "${APP_ENV:-production}" = "production" ]; then
    echo "ERROR: APP_KEY is not set. Please provide APP_KEY in environment variables."
    exit 1
  fi

  APP_KEY="$(php -r 'echo "base64:".base64_encode(random_bytes(32));')"
  export APP_KEY
  echo "APP_KEY was missing; generated temporary key for non-production container."
fi

exec "$@"
