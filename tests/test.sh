#!/usr/bin/env bash

set -e
set -u
set -o pipefail

CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

IMAGE="${1}"
ARCH="${2}"
VERSION="${3}"
FLAVOUR="work"
TAG="${4}"


if ! command -v git >/dev/null 2>&1; then
	echo "Error, git binary is required, but not available"
	exit 1
fi


###
### Clone docker-php-fpm suite (it contains the tests)
###
if [ -d "${CWD}/docker-php-fpm" ]; then
	cd "${CWD}/docker-php-fpm"
	git fetch --all --prune --tags
	git stash
	git checkout master
	git pull origin master
else
	git clone https://github.com/devilbox/docker-php-fpm "${CWD}/docker-php-fpm"
fi


###
### Start the tests
###
"${CWD}/docker-php-fpm/tests/test.sh" "${IMAGE}" "${ARCH}" "${VERSION}" "${FLAVOUR}" "${TAG}"
