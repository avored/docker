#!/bin/sh
set -euo pipefail

if [[ "${DB_HOST}" != "db" ]]; then
  if mysqlshow --host=${DB_HOST} --user=${DB_USERNAME} --password=${DB_PASSWORD} ${DB_DATABASE}; then
    echo "database exist!"
  fi

  php artisan key:generate
  php artisan migrate
  php artisan db:seed --class=AvoRedDataSeeder
  php artisan vendor:publish --tag=public
  php artisan storage:link
  php artisan passport:install
  php artisan passport:keys
  chown -R apache:apache /var/www
fi

if [[ "${MAIL}" != "your@mail.addr" ]]; then
  sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
