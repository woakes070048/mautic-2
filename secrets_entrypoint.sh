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

# Call our copy of the Mautic entrypoint script then the e.g. start Apache CMD
# (argument to entrypoint).
# The one change in our entrypoint vs. that upstream as of 13/4/23 is the addition
# of a modified index.php which we copy at startup, so that we can change it after
# the normal auto install process completes. The purpose of that modified index.php
# is to fix infinite redirect loops when using an ALB with SSL.
/entrypoint.sh "$@"
