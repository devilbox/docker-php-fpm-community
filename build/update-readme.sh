#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Current directory
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if ! command -v perl >/dev/null 2>&1; then
	echo "Error, perl binary not found, but required."
	exit 1
fi


#---------------------------------------------------------------------------------------------------
# Update main README.md
#---------------------------------------------------------------------------------------------------
TABLE=""
TABLE="$( printf "${TABLE}\n%s" "| Project                                 | Author                                            | build                                         | Architecture                                   |" )"
TABLE="$( printf "${TABLE}\n%s" "|-----------------------------------------|---------------------------------------------------|-----------------------------------------------|------------------------------------------------|" )"

LINKS=""

for d in "${CWD}/../Dockerfiles/"*; do
	CREDITS="$( cat "${d}/.credits" )"
	CREDIT_PROJECT="$( echo "${CREDITS}" | grep '^project=' | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"
	CREDIT_GITHUB="$(  echo "${CREDITS}" | grep '^github='  | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"
	CREDIT_NAME="$(    echo "${CREDITS}" | grep '^name='    | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"
	#CREDIT_MAIL="$(    echo "${CREDITS}" | grep '^mail='    | awk -F'=' '{$1=""; print $0}' | sed 's/^ //g' )"

	# Build Table
	LINE=""
	LINE="${LINE}$( printf "| %-40s"  ":file_folder: [${CREDIT_PROJECT}/]" )"
	LINE="${LINE}$( printf "| %-50s"  ":octocat: [${CREDIT_GITHUB}] (${CREDIT_NAME})" )"
	LINE="${LINE}$( printf "| %-46s"  "![${CREDIT_PROJECT}_build]<br/>![${CREDIT_PROJECT}_nightly]" )"
	LINE="${LINE}$( printf "| %-46s"  ":computer: amd64<br/>:computer: arm64" )"
	LINE="${LINE} |"
	TABLE="$( printf "${TABLE}\n%s" "${LINE}" )"

	# Build Table Links
	LINKS="$( printf "${LINKS}\n%s" "[${CREDIT_PROJECT}/]: Dockerfiles/${CREDIT_PROJECT}" )"
	LINKS="$( printf "${LINKS}\n%s" "[${CREDIT_GITHUB}]: https://github.com/${CREDIT_GITHUB}" )"
	LINKS="$( printf "${LINKS}\n%s" "[${CREDIT_PROJECT}_build]: https://github.com/devilbox/docker-php-fpm-community/workflows/${CREDIT_PROJECT}_build/badge.svg" )"
	LINKS="$( printf "${LINKS}\n%s" "[${CREDIT_PROJECT}_nightly]: https://github.com/devilbox/docker-php-fpm-community/workflows/${CREDIT_PROJECT}_nightly/badge.svg" )"
done

cd "${CWD}"
perl -i -p0e "s^<!-- PROJECTS_START -->.*?<!-- PROJECTS_END -->^<!-- PROJECTS_START -->${TABLE}\n\n${LINKS}\n<!-- PROJECTS_END -->^s" "../README.md"
