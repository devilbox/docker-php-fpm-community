# Contributing

If you want to contribute to this project, you can do so in various ways:

* Generally help with issues and improvements
* Enhance currently available community flavours
* Create your own community flavour



## How to create your own flavour?

* Clone this project
* Generate a template via:
```shell
make create-project
```

The above command will guide you through a couple of questions and will auto-generate:

* your project directory with Dockerfiles
* an entry in the main README.md
* GitHub action pipelines
* GitHub code ownership

Once this is done, you can start refining your Dockerfiles, update your project README.md, create according tests if needed and PR it for initial review.


## How do I build my own flavour locally?

If you want to test your build locally do so as follows:
```
# Defaults to linux/amd64
make build FLAVOUR=<flavour-name> VERSION=<php-version>

# Explicitly build linux/arm64
make build FLAVOUR=<flavour-name> VERSION=<php-version> ARCH=linux/arm64
```


## Becoming a maintainer

As a maintainer, you must create a working flavour for all PHP versions (PHP 5.3 to PHP 8.2) and for both architectures (`amd64` and `arm64`).

### Benefits

If you plan on adding your own flavoured images to this repository, you will gain the following benefits:

* namespaced flavour
* your customized images
* automatic nightly builds for always up-to-date images pullable from [Dockerhub](https://hub.docker.com/r/devilbox/php-fpm-community)
* useable with the [Devilbox](https://github.com/cytopia/devilbox)

### Responsibilities

By doing so, you will also have to take the continuous responsibility to:

* be the GitHub code owner of your flavour
* ensure the builds of your Docker images pass
* work on reported issues on your flavour
* ensure tests exist for anything specific you add to your flavour
* continuously groom your project and review assigned pull requests

It will basically become your project.



## FAQ

* **Q:** How to generate the module section in your project README?
    ```shell
    # For the following to work, you must have built all images locally.

    FLAVOUR=devilbox
    ARCH=linux/amd64
    for i in 5.3 5.4 5.5 5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2; do \
      ./tests/bin/gen-readme.sh devilbox/php-fpm-community ${ARCH} ${i}-${FLAVOUR} ${FLAVOUR} ${i}; \
    done
    ```
