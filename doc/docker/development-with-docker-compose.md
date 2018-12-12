# Developing pageonex with docker-compose

If you need to do development in pageonex without the hassle of installing all the dependencies you can use our [docker-compose-build file](/docker-compose-build.yml) which builds the application from scratch.

* In order to start the pageonex and mysql containers, run from the root of this repository:
```
docker-compose -f docker-compose-build.yml up -d --build
```

* To create the initial database:
```
docker-compose -f docker-compose-build.yml exec app_build rake db:migrate --trace
```

* To get a the rails console (See [INSTALL.md](/doc/INSTALL.md) for instructions on creating an admin user)
```
docker-compose -f docker-compose-build.yml exec app_build rails console
```

* To load the list of newspapers into the data baserun:
```
docker-compose -f docker-compose-build.yml exec app_build rake scraping:update_media --trace
```

* If you make changes in the app and you want to rebuild your container
```
docker-compose -f docker-compose-build.yml up -d --build
```

* If you want to log in the mysql database
```
docker-compose -f docker-compose-build.yml exec app_build mysql -u root --password=root dc-dev
```

* If you want to inspect the logs
```
docker-compose -f docker-compose-build.yml logs
```

* If you want to shut down everything
```
docker-compose -f docker-compose-build.yml stop
```

* If you want to remove everything and have a new and clean environment
```
docker-compose -f docker-compose-build.yml rm -s -v
docker volume rm build_db_data build_app_data
```
