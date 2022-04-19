# Developing pageonex with docker-compose

If you need to do development in pageonex without the hassle of installing all the dependencies you can use our [docker-compose-build file](/docker-compose-build.yml) which builds the application from scratch.

1. In order to start the pageonex and mysql containers, run from the root of this repository:
```
docker-compose -f docker-compose-build.yml up -d --build
```

You might get this error `Couldn’t connect to Docker daemon at http+docker://localhost – is it running?`, it is possible to fix [with this solution](https://techoverflow.net/2019/03/16/how-to-fix-error-couldnt-connect-to-docker-daemon-at-httpdocker-localhost-is-it-running/):

> There are two possible reasons for this error message.
> The common reason is that the user you are running the command as does not have the permissions to access docker.
> You can fix this either by running the command as root using sudo (since root has the permission to access docker) or adding your user to the docker group: `sudo usermod -a -G docker $USER`
> and then logging out and logging back in completely (or restarting the system/server).
> The other reason is that you have not started docker. On Ubuntu, you can start it using `sudo systemctl enable docker` (Auto-start on boot) and `sudo systemctl start docker` (Start right now).

> You can also get this message: `Creating pageonex_mysql_build_1 ... error ERROR: for pageonex_mysql_build_1  Cannot start service mysql_build: driver failed programming external connectivity on endpoint pageonex_mysql_build_1 (34af946d85db80f663a8d71e550bef50128a3fd4f41593bdc9ef722a7c2f5b54): Bind for 0.0.0.0:23306 failed: port is already allocated` this is because you have another docker container running using that port.
> Use `docker ps` to see which other containers you have and stop them by using the `CONTAINER ID`. If container id is `03be2d8e8337` use `docker stop 03be2d8e8337`
 

2. To create the initial database:
```
docker-compose -f docker-compose-build.yml exec app_build rake db:migrate --trace
```

3. To load the list of newspapers into the data base run:
```
docker-compose -f docker-compose-build.yml exec app_build rake scraping:update_media --trace
```

Once everything is running correctly, you can access the application from your browser at http://localhost:3000 or http://0.0.0.0:3000

## Tasks

### How to access the rails console

To get a the rails console (See [doc/local-install.md](/doc/local-install.md#process) for instructions on creating an admin user)
```
docker-compose -f docker-compose-build.yml exec app_build rails console
```

Once you have entered the rails console you can make one user admin with this command:

```
User.find_by_email('user@domain.com').update_attribute :admin, true
```

Admin users are able to use the taxonomies feature.

To quit the console type `quit`.

### How to access the database

If you want to log in the mysql database
```
docker-compose -f docker-compose-build.yml exec app_build mysql -u root --password=root dc-dev
```

### How to rebuild your container

If you make changes in the app and you want to rebuild your container
```
docker-compose -f docker-compose-build.yml up -d --build
```

### How to see rails logs

If you want to inspect the logs
```
docker-compose -f docker-compose-build.yml logs
```

### How to shut down the app

If you want to shut down everything
```
docker-compose -f docker-compose-build.yml stop
```

### How to remove everythung and start from scratch

If you want to remove everything and have a new and clean environment
```
docker-compose -f docker-compose-build.yml rm -s -v
docker volume rm build_db_data build_app_data
```
