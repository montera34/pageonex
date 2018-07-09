# Pageonex Ruby base images

Since we use old ruby versions, we need to build the images by ourselves compiling ruby from source. Once we're there, images will contain all the system dependencies that normally do not change so that main image builds only refer to the application

Images will be uploaded to https://hub.docker.com/r/pageonex/ruby-base/tags/

In order to build and push the ruby 1.9.3 image with its dependencies

```
cd v1.9.3
make docker-build
make docker-push
```

Image will be named `pageonex/ruby-base`:`v1.9.3.x` where `x` will be the revision in the `v1.9.3/REVISION` file

