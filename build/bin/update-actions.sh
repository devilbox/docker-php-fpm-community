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
### Remove current workflows
###
rm -f "${CWD}/../.github/workflows/"*_action*
rm -f "${CWD}/../.github/workflows/"*_params*


###
### Copy template actions
###
for d in "${CWD}/../Dockerfiles/"*; do
	CREDITS="$( cat "${d}/.credits" )"
	CREDIT_PROJECT="$( echo "${CREDITS}" | grep '^project=' | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"

	###
	### Copy GitHub Actions
	###
	cp "${CWD}/skeleton/github/action.yml"          "${CWD}/../.github/workflows/${CREDIT_PROJECT}_action.yml"
	cp "${CWD}/skeleton/github/action_schedule.yml" "${CWD}/../.github/workflows/${CREDIT_PROJECT}_action_schedule.yml"
	cp "${CWD}/skeleton/github/params.yml"          "${CWD}/../.github/workflows/${CREDIT_PROJECT}_params.yml"

	###
	### Set placeholder in GitHub Actions
	###
	sed -i '' "s/__PROJECT__/${CREDIT_PROJECT}/g" "${CWD}/../.github/workflows/${CREDIT_PROJECT}_action.yml"
	sed -i '' "s/__PROJECT__/${CREDIT_PROJECT}/g" "${CWD}/../.github/workflows/${CREDIT_PROJECT}_action_schedule.yml"
	sed -i '' "s/__PROJECT__/${CREDIT_PROJECT}/g" "${CWD}/../.github/workflows/${CREDIT_PROJECT}_params.yml"
done
