# Pageonex on Docker

You can run locally using [docker compose](https://docs.docker.com/compose/). In order to start the pageonex and mysql containers, run from the root of this repository:
```
docker-compose up -d --build
```

To create the initial database:
```
docker-compose run app rake db:migrate --trace
```

To get the rails console (See [INSTALL.md](INSTALL.md) for instructions on creating an admin user)
```
docker-compose run app rails console
```

If you make changes in the app and you want to rebuild your container
```
docker-compose up -d --build
```

If you want to log in the mysql database
```
docker-compose exec mysql mysql -u root --password=root
```

If you want to inspect the logs
```
docker-compose logs
```

If you want to shut down everything
```
docker-compose stop
```

If you want to remove everything (including volumes)
```
docker-compose rm -s -v
```
