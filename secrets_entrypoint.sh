#!/bin/bash

# This script is taken from https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/
# and is used to set up app secrets in ECS without exposing them as widely as using ECS env vars directly would.

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
  exit 1
fi

# Load the S3 secrets file contents into the environment variables
export $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/secrets - | grep -v '^#' | xargs)

# Fix redirect loop behind ALB. https://forum.mautic.org/t/mautic-redirect-loop/16990/3
INDEX_FILE="/var/www/html/index.php"
NEW_LINE="\$_SERVER[\"HTTPS\"] = \"on\";\n"
if test -f "$INDEX_FILE"; then
  if grep -q "$NEW_LINE" "$INDEX_FILE"; then
    echo "SSL modification already in place"
  else
    # Existing line regex based on https://github.com/mautic/mautic/blob/4.x/index.php
    sed -i -e 's/(<\?php)/$1\n\$_SERVER["HTTPS"] = "on";/g' "$INDEX_FILE"
    echo "SSL modification applied"
  fi
else
  echo "No index.php – no SSL modification"
fi

# Call the normal Mautic entrypoint script then the e.g. start Apache CMD (argument to entrypoint).
/entrypoint.sh "$@"
