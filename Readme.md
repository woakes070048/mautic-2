# The Big Give's Mautic

This repository is a thin layer for tooling used by the Big Give to
test and deploy Mautic.

The Docker tag `mautic/mautic:v4-apache`, managed by the Mautic community,
is the basis for the app code. Everything we do should extend and
minimally alter the app we pull from the upstream, official Docker images.

To test a build locally:

    docker build -t thebiggive-mautic .

Deployment are automatic:
* from `develop` to [Staging](https://mautic-staging.thebiggivetest.org.uk)
* from `main` to [Production](https://mautic-production.thebiggive.org.uk)

## Volumes and files added in the image

The 2 additional files for ECS runs to work are added by our `Dockerfile`
to `/usr/local/etc`.

Mautic's persisted data lives at `/var/www/html` – we don't modify the
official image's assumptions around this. On ECS a persistent volume
(e.g. an EFS mount) must be mapped to this internal path.
