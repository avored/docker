DockerfileFROM alpine

ENV DOMAIN server.tld
ENV MAIL admin@admin.com
ENV TZ America/Los_Angeles
ENV DB_HOST db
ENV DB_PORT 3306
ENV DB_DATABASE laravel
ENV DB_USERNAME root
ENV DB_PASSWORD password
ENV REDIS_HOST redis
ENV REDIS_PORT 6379
ENV REDIS_PASSWORD null
ENV CACHE_DRIVER redis
ENV SESSION_DRIVER redis
ADD docker-entrypoint.sh /usr/local/bin/
ADD gencerts.sh /usr/local/bin/
WORKDIR /var/www/localhost/htdocs

RUN chmod 755 /usr/local/bin/*.sh \
    && apk update  \
    && apk add --no-cache sudo git zip curl certbot acme-client openssl ca-certificates findutils \
                          mysql-client apache2 apache2-ssl python php7-apache2 php7-gd \
                          php7-curl php7-openssl php7-json php7-phar php7-dom php7-mysqlnd php7-pdo_mysql php7-iconv \
                          php7-mcrypt php7-ctype php7-xml php7-mbstring php7-tokenizer php7-session php7-fileinfo php7-zlib \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir /run/apache2 \
    && sed -ri \
           -e 's!^(\s*DocumentRoot) "/var/www/localhost/htdocs"$!\1 "/var/www/localhost/htdocs/public"!g' \
           -e 's!^(\s*<Directory ) "/var/www/localhost/htdocs">$!\1 "/var/www/localhost/htdocs/public">!g' \
           -e 's!^#(LoadModule rewrite_module .*)$!\1!g' \
           -e 's!^(\s*AllowOverride) None.*$!\1 All!g' \
           "/etc/apache2/httpd.conf" \
       \
    && sed -ri \
           -e 's!^(max_execution_time = )(.*)$!\1 72000!g' \
           -e 's!^(post_max_size = )(.*)$!\1 100M!g' \
           -e 's!^(upload_max_filesize = )(.*)$!\1 100M!g' \
           -e 's!^(memory_limit = )(.*)$!\1 100M!g' \
           "/etc/php7/php.ini" \
       \
    && rm -f index.html \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && git clone https://github.com/avored/laravel-ecommerce.git /var/www/localhost/htdocs \
    && cp .env.example .env \
    && composer require predis/predis \
    && composer install \
    && composer update \
    && sed -ri \
           -e '/^DB_HOST=/d' \
           -e '/^DB_PORT=/d' \
           -e '/^DB_DATABASE=/d' \
           -e '/^DB_USERNAME=/d' \
           -e '/^DB_PASSWORD=/d' \
           -e '/^REDIS_HOST=/d' \
           -e '/^REDIS_PORT=/d' \
           -e '/^REDIS_PASSWORD=/d' \
           -e '/^CACHE_DRIVER=/d' \
           -e '/^SESSION_DRIVER=/d' \
           /var/www/localhost/htdocs/.env \
       \
    && chown -R apache:apache /var/www

VOLUME /var/www/localhost/htdocs
EXPOSE 80 443 
CMD ["docker-entrypoint.sh"]
