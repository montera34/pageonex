# Runining pageonex in your environment

If you want to create your own deployment of pageonex, the easiest way to do it is to use one of our [docker images](https://hub.docker.com/r/pageonex/pageonex/tags) and connect it to the database. These are the main configuration areas:

## Rails environment configuration

You need to set the `RAILS_ENV` to `production`

## Database access configuration

Pageonex has been mainly tested with mysql, so this is our recommendation. Due to [this issue](https://github.com/montera34/pageonex/issues/212), mysql <= 5.6 is required

There are a few env variables that should be set to customize your database access:

* `DATABASE_ADAPTER`: This should be set to `mysql2`
* `DATABASE_USERNAME`: The database user to accesss
* `DATABASE_PASSWORD`: The password corresponding to above user
* `DATABASE_HOST`: Database address
* `DATABASE_PORT`: Database port
* `DATABASE_NAME`: Database name in above host:port

See [database.yml](/config/database.yml) for more settings and default values.

## Filesystem mounts

There are a few mount points to be set in order to avoid writes in the container filesystem which would lead to data loss and performance degradation:

* kiosko images: `/workspace/app/assets/images/kiosko`
* threads images: `/workspace/app/assets/images/threads`
* temp files: `/workspace/tmp`

## Rake tasks

These should be run on deployment:

* Database schema creation/modification: `db:migrate`
* Media list: `scraping:update_media`
* Assets precompilation: `bundle exec rake assets:precompile`
