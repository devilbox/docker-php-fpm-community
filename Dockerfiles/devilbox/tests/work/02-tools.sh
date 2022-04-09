#!/usr/bin/env bash

set -e
set -u
set -o pipefail

IMAGE="${1}"
ARCH="${2}"
#FLAVOUR="${3}"
TAG="${4}"


###
### Test Ansible
###
cmd="docker run --rm --platform ${ARCH} --entrypoint=bash ${IMAGE}:${TAG} -c 'ansible --version'"

echo "${cmd}"
eval "${cmd}"
