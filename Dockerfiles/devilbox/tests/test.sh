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


# Loop over newlines instead of spaces
IFS=$'\n'

TESTS="$( find "${CWD}" -regex "${CWD}/work/.+\.sh" | sort -u )"
for t in ${TESTS}; do
	printf "\n\n\033[0;33m%s\033[0m\n" "################################################################################"
	printf "\033[0;33m%s %s\033[0m\n"  "#" "[${VERSION}-${FLAVOUR}] (${ARCH})"
	printf "\033[0;33m%s %s\033[0m\n"  "#" "${t} ${IMAGE} ${ARCH} ${VERSION} ${FLAVOUR} ${TAG}"
	printf "\033[0;33m%s\033[0m\n\n"   "################################################################################"
	time ${t} "${IMAGE}" "${ARCH}" "${VERSION}" "${FLAVOUR}" "${TAG}"
done
