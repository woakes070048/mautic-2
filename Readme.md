# The Big Give's Mautic

This repository is a thin layer for tooling used by the Big Give to
test and deploy Mautic.

The Docker tag `mautic/mautic:v4-apache`, managed by the Mautic community,
is the basis for the app code. Everything we do should extend and
minimally alter the app we pull from the upstream, official Docker images.

Deployment are automatic:
* from `develop` to [Staging](https://mautic-staging.thebiggivetest.org.uk)
* from `main` to [Production](https://mautic-production.thebiggive.org.uk)
