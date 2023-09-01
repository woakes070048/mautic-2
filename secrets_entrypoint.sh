#!/bin/bash

# This script is taken from https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
# and is used to set up app secrets in ECS without exposing them as widely as using ECS env vars directly would.

# Fix redirect loop behind ALB. This is based on https://forum.mautic.org/t/mautic-redirect-loop/16990/3 and is
# in addition to our ECS secret-loading steps.
INDEX_FILE="/var/www/html/index.php"
if test -f "$INDEX_FILE"; then
  cp /usr/local/etc/alb-safe-index.php "$INDEX_FILE"
  echo >&2 "SSL modification applied"
fi

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
  exit 1
fi

# Load the S3 secrets file contents into the environment variables
export $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/secrets - | grep -v '^#' | xargs)

echo "Starting Apache..."
# No args for now. Our base php:8.0 already turns on the `mautic` vhost.
apache2-foreground
