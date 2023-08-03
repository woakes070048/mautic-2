# The Big Give's Mautic

We use Mautic's official Composer recommendation repository and its Composer
packages as the basis for building this, with scaffolding `.gitignore`d
to keep the repository compact.

The `Dockerfile` runs `composer install`, which has a post-install script to
generate scaffolding whenever it's not present.

We don't use the official Docker image as it [is not really maintained](https://github.com/mautic/docker-mautic/issues/240)
as of August 2023, and when we tried Apache tags they were too old to be usable – as
well as e.g. not using Composer. We tried another unofficial experimental repo but also
found it to not quite work and be very different from other web things we deploy to ECS.

## `cron` tasks

In an effort to avoid re-working too much of the outdated Docker repo's entrypoint logic, we add `cron`
to our Linux base – everything in one container – which is not very Docker-y or horizontal scaling-safe.
We should probably take a closer look at what scheduled commands do and any locking ability before running
this live, particularly with more than one task in an ECS Service.

## Local runs

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
(e.g. an EFS mount) can be mapped to this internal path, or the S3 plugin
can be used to make the media approach more 12-factor-friendly. (The latter
would probably be better if it works, but is not yet tested!)
