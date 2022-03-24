#!/usr/bin/env bash

set -e
set -u
set -o pipefail

IMAGE="${1}"
ARCH="${2}"
VERSION="${3}"
TAG="${4}"



docker run --rm --platform "${ARCH}" --entrypoint=php "${IMAGE}:${TAG}" -v | grep "${VERSION}"
