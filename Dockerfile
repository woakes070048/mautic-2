FROM thebiggive/php:8.0

# Install the AWS CLI - needed to load in secrets safely from S3. See https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
# And `cron`, needed for old school tasks-in-a-web-server management of scheduled stuff inside Mautic, and libs for
# various extensions. See also https://stackoverflow.com/a/38526260/2803757
RUN apt-get clean && apt-get update -qq && apt-get install -y awscli cron libc-client-dev libkrb5-dev libpng-dev libzip-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apk/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
 && docker-php-ext-install gd imap mysqli sockets zip

COPY ./docker-support/makeconfig.php    /makeconfig.php
COPY ./docker-support/makedb.php        /makedb.php

# Load secrets from S3 like with our custom ECS apps.
COPY ./secrets_entrypoint.sh /usr/local/etc/secrets_entrypoint.sh

# Modify the standard Mautic index.php and the entrypoint which installs it,
# to fix infinite redirect loops behind an ALB with SSL.
COPY ./alb-safe-index.php /usr/local/etc/alb-safe-index.php
COPY ./entrypoint.sh /entrypoint.sh

# Apply recommend PHP configuration for best stability and performance.
COPY ./php-conf/assert.ini /usr/local/etc/php/conf.d/assert.ini

# Ensure Composer can cache in its default location
RUN mkdir /var/www/.composer
RUN chown www-data:www-data /var/www/.composer

# We could probably just mkdir this, but maybe slightly clearer what's going on from scanning
# the repo folder structure when it's there from the start?
COPY ./public /var/www/html/public
RUN chown -R www-data:www-data /var/www/html/public

USER www-data

COPY ./composer.json /var/www/html/composer.json
COPY ./composer.lock /var/www/html/composer.lock

# Install PHP dependencies, as www-data. This also generates all Mautic scaffolding
# files if not already there.
RUN composer install --no-interaction --optimize-autoloader --no-dev

USER root

EXPOSE 80

ENTRYPOINT /usr/local/etc/secrets_entrypoint.sh apache2-foreground
