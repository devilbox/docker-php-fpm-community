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
* GitHub action pipelines.

Once this is done, you can start refining your Dockerfiles, update your project README.md, create according tests if needed and PR it for initial review.


## Becoming a maintainer

As a maintainer, you will need create a flavour for PHP 5.3 - PHP 8.2 for the `amd64` and `arm64` architecture.

### Benefits

If you plan on adding your own flavoured images to this repository, you will gain the following benefits:

* namespaced flavour
* your customized images
* automatic nightly builds for always up-to-date images

### Responsibilities

By doing so, you will also have to take the continuous responsible to:

* be the GitHub code owner of your flavour
* ensure your Docker image builds pass
* work on reported issues on your flavour
* ensure tests exist for anything specific you add to your flavour
* continuously groom your project and review assigned pull requests

It will basically become your project.



## FAQ

* **Q:** How to generate the module section in your project README?
    ```shell
    # For the following to work, you must have built all images locally.

    FLAVOUR=devilbox
    for i in 5.3 5.4 5.5 5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2; do \
      ./tests/bin/gen-readme.sh devilbox/php-fpm-community linux/amd64 ${i}-${FLAVOUR} ${FLAVOUR} ${i}; \
    done
    ```
