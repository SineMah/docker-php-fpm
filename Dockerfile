ARG ALPINE_VERSION=3.16
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="SineMah"
# Setup document root
WORKDIR /var/www

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php81 \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fileinfo \
  php81-fpm \
  php81-gd \
  php81-pecl-imagick \
  php81-intl \
  php81-iconv \
  php81-mbstring \
  php81-mysqli \
  php81-opcache \
  php81-openssl \
  php81-phar \
  php81-pdo \
  php81-pdo_mysql \
  php81-pdo_pgsql \
  php81-session \
  php81-tokenizer \
  php81-xml \
  php81-xmlreader \
  php81-xmlwriter \
  php81-zlib \
  php81-zip \
  php81-exif \
  supervisor \
  zip

# Create symlink so programs depending on `php` still function
RUN ln -s /usr/bin/php81 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chmod -R 777 /var/www
RUN chmod -R 777 /run 
RUN chmod -R 777 /var/lib/nginx
RUN chmod -R 777 /var/log/nginx

# Switch to use a non-root user from here on
# USER nobody

# Add application
# COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
