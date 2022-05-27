FROM mautic/mautic:v4-apache

# Install the AWS CLI - needed to load in secrets safely from S3. See https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
RUN apt-get clean && apt-get update -qq && apt-get install -y awscli libzip-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apk/*

COPY ./secrets_entrypoint.sh /var/www/html/secrets_entrypoint.sh
COPY ./rds-combined-ca-bundle.pem /var/www/html/rds-combined-ca-bundle.pem

RUN docker-php-ext-install mysqli zip

EXPOSE 80
