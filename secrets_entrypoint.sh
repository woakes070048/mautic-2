#!/bin/bash

# This script is taken from https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
# and is used to set up app secrets in ECS without exposing them as widely as using ECS env vars directly would.

# Check that the environment variable has been set correctly
#if [ -z "$SECRETS_BUCKET_NAME" ]; then
#  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
#  exit 1
#fi
#
## Load the S3 secrets file contents into the environment variables
#export $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/secrets - | grep -v '^#' | xargs)

# Fix redirect loop behind ALB. https://forum.mautic.org/t/mautic-redirect-loop/16990/3
# For now we do this on 2nd run to keep the config simple, so only the 2nd deploy to a given env will work
# on ECS behind an ALB:
# First run: normal entrypoint auto installs and copies index.php to /var/www/html (a persistent attached volume mount);
# Second run: this entrypoint picks up the existence of the installation and replaces index.php with the custom one.
INDEX_FILE="/var/www/html/index.php"
if test -f "$INDEX_FILE"; then
  cp /usr/local/etc/alb-safe-index.php /var/www/html/index.php
  echo "SSL modification applied"
fi

# Call the normal Mautic entrypoint script then the e.g. start Apache CMD (argument to entrypoint).
/entrypoint.sh "$@"
