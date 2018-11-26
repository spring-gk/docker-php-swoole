FROM php:7-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS linux-headers tzdata \
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev gettext-dev openldap-dev \
    libxml2-dev libzip-dev libmcrypt-dev libmemcached-dev hiredis hiredis-dev inotify-tools \
    && docker-php-ext-install -j$(nproc) bcmath gd gettext pdo_mysql mysqli ldap pcntl soap sockets sysvsem xmlrpc \
    && pecl install swoole-2.2.0 \
    && pecl install mcrypt-1.0.1 \
    && pecl install memcached-3.0.4 \
    && pecl install redis-4.0.2 \
    && pecl install mongodb-1.4.3 \
    && pecl install yaf-3.0.7 \
    && pecl install yac-2.0.2 \
    && pecl install zip-1.15.2 \
    && pecl install inotify-2.0.0 \
    && docker-php-ext-enable swoole mcrypt memcached redis mongodb yaf yac zip inotify \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
    && echo "Asia/Shanghai" > /etc/timezone \
    apk del .phpize-deps freetype-dev libpng-dev libjpeg-turbo-dev gettext-dev openldap-dev libxml2-dev libzip-dev libmcrypt-dev libmemcached-dev

# Install php composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');" \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

VOLUME /data

# Make dir
RUN mkdir -p /data/logs/php
