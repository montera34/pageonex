# Running pageonex locally with docker compose

You can test locally pageonex using [docker compose](https://docs.docker.com/compose/). Just running

```
docker-compose up
```

you will get

* A mysql database running [the official mysql image](https://hub.docker.com/_/mysql/)
* All the migration and admin tasks run
* A pageonex server running [the lastest pageonex image](https://hub.docker.com/r/pageonex/pageonex)
* All data stored in separate volumes that will remain even if you delete your application's containers

Once everything is running correctly, you can access the application from your browser in http://localhost:3000

## Tasks

### How to run in detached mode

In order to run docker-compose in background and have the shell available, please use detached mode
```
docker-compose up -d
```

### How to see logs

Logs are not shown in the screen in detached mode, you can inspect them using
```
docker-compose logs
```

### How to access the rails console

In case you want to further inspect the application, you can run
```
docker-compose exec app rails console
```

### How to access the database

In case you want to further inspect the database, you can run
```
docker-compose exec mysql mysql -u root -h localhost --password=root dc-prod
```

### How to delete everything and start from scratch

You may want to start fresh. You have to make sure that all related images, containers are both stopped and deleted and volumes are deleted
```
docker-compose stop
docker-compose rm
docker volume rm pageonex_app_kiosko_images pageonex_app_threads_images pageonex_db_data pageonex_app_tmp_dir
```
