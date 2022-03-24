#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Current directory
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"


VALID_PROJECT="[-_a-zA-Z0-9]+"

PHP_VERSIONS=("5.3" "5.4" "5.5" "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1")


echo "================================================================================"
echo "Generating new project"
echo "================================================================================"

#---------------------------------------------------------------------------------------------------
# Ask for details
#---------------------------------------------------------------------------------------------------

###
### Ask for project name
###
echo "(1/4) What is the name of your project?"
read -r PROJECT
if [ -z "${PROJECT}" ]; then
	echo "Error, project name cannot be empty."
	exit 1
fi
if [ -d "${CWD}/../Dockerfiles/${PROJECT}" ]; then
	echo "Error, project already exists."
	exit 1
fi
if [ "${PROJECT}" != "$( echo "${PROJECT}" | grep -Eo "${VALID_PROJECT}" )" ]; then
	echo "Error, project name is limited to this regex: ${VALID_PROJECT}"
	exit 1
fi

###
### Ask for GitHub name
###
echo "(2/4) What is your GitHub name (name only, link will be generated)?"
read -r GITHUB_NAME
if [ -z "${GITHUB_NAME}" ]; then
	echo "Error, GitHub name cannot be empty."
	exit 1
fi

###
### Ask for full name
###
echo "(3/4) What is your full name / nickname (used to generate credit and maintainer info)?"
read -r MAINTAINER_NAME
if [ -z "${MAINTAINER_NAME}" ]; then
	echo "Error, full name or nickname cannot be empty."
	exit 1
fi

###
### Ask for email
###
echo "(4/4) What is your email (used to generate credit and maintainer info)?"
read -r MAINTAINER_MAIL
if [ -z "${MAINTAINER_MAIL}" ]; then
	echo "Error, email cannot be empty."
	exit 1
fi



#---------------------------------------------------------------------------------------------------
# Generate Dockerfiles
#---------------------------------------------------------------------------------------------------

###
### Create directory
###
mkdir "${CWD}/../Dockerfiles/${PROJECT}"

###
### Copy Dockerfiles
###
for version in "${PHP_VERSIONS[@]}"; do
	cp "${CWD}/skeleton/Dockerfiles/Dockerfile-${version}" "${CWD}/../Dockerfiles/${PROJECT}/"
done

###
### Set placeholders in Dockerfiles
###
for version in "${PHP_VERSIONS[@]}"; do
	sed -i'' "s/__MAINTAINER_NAME__/${MAINTAINER_NAME}/g" "${CWD}/../Dockerfiles/${PROJECT}/Dockerfile-${version}"
	sed -i'' "s/__MAINTAINER_MAIL__/${MAINTAINER_MAIL}/g" "${CWD}/../Dockerfiles/${PROJECT}/Dockerfile-${version}"
done


#---------------------------------------------------------------------------------------------------
# Generate project README.md
#---------------------------------------------------------------------------------------------------

###
### Copy README.md
###
cp "${CWD}/skeleton/README.md" "${CWD}/../Dockerfiles/${PROJECT}/README.md"
sed -i'' "s/__PROJECT__/${PROJECT}/g"                 "${CWD}/../Dockerfiles/${PROJECT}/README.md"
sed -i'' "s/__GITHUB_NAME__/${GITHUB_NAME}/g"         "${CWD}/../Dockerfiles/${PROJECT}/README.md"
sed -i'' "s/__MAINTAINER_NAME__/${MAINTAINER_NAME}/g" "${CWD}/../Dockerfiles/${PROJECT}/README.md"


#---------------------------------------------------------------------------------------------------
# Generate project .credits file
#---------------------------------------------------------------------------------------------------

{
	echo "project=${PROJECT}"
	echo "github=${GITHUB_NAME}"
	echo "name=${MAINTAINER_NAME}"
	echo "mail=${MAINTAINER_MAIL}"
} > "${CWD}/../Dockerfiles/${PROJECT}/.credits"


#---------------------------------------------------------------------------------------------------
# Generate GitHub Actions
#---------------------------------------------------------------------------------------------------

###
### Copy GitHub Actions
###
cp "${CWD}/skeleton/github/action_branch.yml"       "${CWD}/../.github/workflows/${PROJECT}_action_branch.yml"
cp "${CWD}/skeleton/github/action_pull_request.yml" "${CWD}/../.github/workflows/${PROJECT}_action_pull_request.yml"
cp "${CWD}/skeleton/github/action_schedule.yml"     "${CWD}/../.github/workflows/${PROJECT}_action_schedule.yml"
cp "${CWD}/skeleton/github/params.yml"              "${CWD}/../.github/workflows/${PROJECT}_params.yml"

###
### Set placeholder in GitHub Actions
###
sed -i'' "s/__PROJECT__/${PROJECT}/g" "${CWD}/../.github/workflows/${PROJECT}_action_branch.yml"
sed -i'' "s/__PROJECT__/${PROJECT}/g" "${CWD}/../.github/workflows/${PROJECT}_action_pull_request.yml"
sed -i'' "s/__PROJECT__/${PROJECT}/g" "${CWD}/../.github/workflows/${PROJECT}_action_schedule.yml"
sed -i'' "s/__PROJECT__/${PROJECT}/g" "${CWD}/../.github/workflows/${PROJECT}_params.yml"


#---------------------------------------------------------------------------------------------------
# Update CODEOWNERS
#---------------------------------------------------------------------------------------------------

###
### Adjust Code Owners
###
if ! grep "^/Dockerfiles/${PROJECT}/" "${CWD}/../.github/CODEOWNERS" >/dev/null 2>&1; then
	printf "%-30s @%s\n" "/Dockerfiles/${PROJECT}/" "${GITHUB_NAME}" >> "${CWD}/../.github/CODEOWNERS"
fi
