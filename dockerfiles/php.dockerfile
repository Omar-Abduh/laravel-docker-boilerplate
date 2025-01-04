FROM php:8.2-fpm-alpine3.18

ARG UID
ARG GID
ARG USER

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system ${USER}
RUN adduser -G ${USER} --system -D -s /bin/sh -u ${UID} ${USER}

# Update PHP-FPM user
RUN sed -i "s/user = www-data/user = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Install system dependencies
RUN apk add --no-cache \
    libpng \
    libpng-dev \
    jpeg-dev \
    zip \
    libzip-dev \
    freetype-dev \
    libjpeg-turbo-dev

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-jpeg --with-freetype
RUN docker-php-ext-install gd
RUN docker-php-ext-install exif
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo pdo_mysql

# Install Redis extension (latest stable version)
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.7.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# Optional: Install additional extensions commonly used with Laravel
RUN docker-php-ext-install opcache
RUN apk add --no-cache oniguruma-dev && docker-php-ext-install mbstring

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]