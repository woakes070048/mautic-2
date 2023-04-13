FROM mautic/mautic:v4-apache

# Install the AWS CLI - needed to load in secrets safely from S3. See https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
RUN apt-get clean && apt-get update -qq && apt-get install -y awscli libzip-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apk/*

RUN docker-php-ext-install mysqli zip

# Load secrets from S3 like with our custom ECS apps.
COPY ./secrets_entrypoint.sh /usr/local/etc/secrets_entrypoint.sh

# Modify the standard Mautic index.php and the entrypoint which installs it,
# to fix infinite redirect loops behind an ALB with SSL.
COPY ./alb-safe-index.php /usr/local/etc/alb-safe-index.php
COPY ./entrypoint.sh /entrypoint.sh

# Apply recommend PHP configuration for best stability and performance.
COPY ./php-conf/assert.ini /usr/local/etc/php/conf.d/assert.ini

# Increase threads allowed to reduce risk of Apache bail outs. (Probably redundant?)
COPY ./apache-conf/mpm-prefork.conf /etc/apache2/mods-available/mpm-prefork.conf
RUN ln -s /etc/apache2/mods-available/mpm-prefork.conf /etc/apache2/mods-enabled/mpm-prefork.conf

EXPOSE 80

ENTRYPOINT /usr/local/etc/secrets_entrypoint.sh apache2-foreground
