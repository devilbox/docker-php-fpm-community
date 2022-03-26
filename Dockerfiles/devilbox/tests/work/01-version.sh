#!/usr/bin/env bash

set -e
set -u
set -o pipefail

IMAGE="${1}"
ARCH="${2}"
#FLAVOUR="${3}"
TAG="${4}"


cmd="docker run --rm --platform ${ARCH} --entrypoint=php ${IMAGE}:${TAG} -v | grep '${VERSION}'"

echo "${cmd}"
eval "${cmd}"
