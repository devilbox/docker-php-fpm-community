#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Current directory
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)/../"



#---------------------------------------------------------------------------------------------------
# Update main CODEOWNERS
#---------------------------------------------------------------------------------------------------

###
### Remove current CODEOWNERS
###
rm -f "${CWD}/../.github/CODEOWNERS"

###
### Copy template
###
cp "${CWD}/skeleton/github/CODEOWNERS" "${CWD}/../.github/CODEOWNERS"

###
### Add code owners
###
for d in "${CWD}/../Dockerfiles/"*; do
	CREDITS="$( cat "${d}/.credits" )"
	CREDIT_PROJECT="$( echo "${CREDITS}" | grep '^project=' | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"
	CREDIT_GITHUB="$(  echo "${CREDITS}" | grep '^github='  | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"

	# Build Owners
	printf "%-30s @%s\n" "/Dockerfiles/${CREDIT_PROJECT}/" "${CREDIT_GITHUB}" >> "${CWD}/../.github/CODEOWNERS"
done
