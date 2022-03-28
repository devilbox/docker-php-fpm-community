#!/usr/bin/env bash

# Be very strict
set -e
set -u
set -o pipefail

# Get absolute directory of this script
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"


IMAGE="${1}"
ARCH="${2}"
TAG="${3}"
FLAVOUR="${4}"
VERSION="${5:-}"

if ! command -v perl >/dev/null 2>&1; then
	>&2 echo "Error, perl binary not found, but required."
	exit 1
fi

PROJECT_README="${CWD}/../../Dockerfiles/${FLAVOUR}/README.md"
if [ ! -f "${PROJECT_README}" ]; then
	>&2 echo "Error, README.md not found: ${PROJECT_README}"
	exit
fi


###
### Show Usage
###
print_usage() {
	>&2 echo "Usage: gen-readme.sh <IMAGE> <ARCH> <TAG> <FLAVOUR> [<VERSION>]"
}


###
### Extract PHP modules in alphabetical order and comma separated in one line
###
get_modules() {
	current_tag="${1}"
	# Retrieve all modules
	PHP_MODULES="$( docker run --rm --platform "${ARCH}" "$(tty -s && echo '-it' || echo)" --entrypoint=php "${IMAGE}:${current_tag}" -m )"
	ALL_MODULES=

	if docker run --rm --platform "${ARCH}" "$(tty -s && echo '-it' || echo)" --entrypoint=find "${IMAGE}:${current_tag}" /usr/local/lib/php/extensions -name 'ioncube.so' | grep -q ioncube.so; then
		ALL_MODULES="${ALL_MODULES},ioncube";
	fi

	if docker run --rm --platform "${ARCH}" "$(tty -s && echo '-it' || echo)" --entrypoint=find "${IMAGE}:${current_tag}" /usr/local/lib/php/extensions -name 'blackfire.so' | grep -q blackfire.so; then
		ALL_MODULES="${ALL_MODULES},blackfire";
	fi

	if docker run --rm --platform "${ARCH}" "$(tty -s && echo '-it' || echo)" --entrypoint=find "${IMAGE}:${current_tag}" /usr/local/lib/php/extensions -name 'psr.so' | grep -q psr.so; then
		ALL_MODULES="${ALL_MODULES},psr";
	fi

	if docker run --rm --platform "${ARCH}" "$(tty -s && echo '-it' || echo)" --entrypoint=find "${IMAGE}:${current_tag}" /usr/local/lib/php/extensions -name 'phalcon.so' | grep -q phalcon.so; then
		ALL_MODULES="${ALL_MODULES},phalcon";
	fi

	# Process module string into correct format for README.md
	PHP_MODULES="$( echo "${PHP_MODULES}" | grep -v '^Core' )"  # Remove 'Core'
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed 's/^\[.*//g' )" # Remove PHP Modules headlines
	PHP_MODULES="${ALL_MODULES}${PHP_MODULES}"                  # Append all available modules
	PHP_MODULES="$( echo "${PHP_MODULES}" | sort -fu )"         # Unique
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed '/^\s*$/d' )"   # Remove empty lines
	PHP_MODULES="$( echo "${PHP_MODULES}" | tr '\r\n' ',' )"    # Newlines to commas
	PHP_MODULES="$( echo "${PHP_MODULES}" | tr '\n' ',' )"      # Newlines to commas
	PHP_MODULES="$( echo "${PHP_MODULES}" | tr '\r' ',' )"      # Newlines to commas
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed	's/^M/,/g' )"   # Newlines to commas
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed 's/,,/,/g' )"   # Remove PHP Modules headlines
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed 's/,/\n/g' )"   # Back to newlines
	PHP_MODULES="$( echo "${PHP_MODULES}" | sort -fu )"         # Unique
	PHP_MODULES="$( echo "${PHP_MODULES}" | sed '/^\s*$/d' )"   # Remove empty lines

	echo "${PHP_MODULES}"
}


###
### Replace modules in Readme for specified PHP version
###
update_readme() {
	local version="${1}"
	local modules
	modules="$( get_modules "${TAG}" )"

	###
	### (1/3) Add found modules to README.md
	###
	while IFS= read -r module; do
		if [ -z "${module}" ]; then
			continue
		fi
		html=""
		html=${html}$( printf "%s" " <tr>" )
		html=${html}$( printf "%s" "  <td class=\"${module}\"><sup>${module}</sup></td>" )
		html=${html}$( printf "%s" "  <td class=\"5.3-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"5.4-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"5.5-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"5.6-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"7.0-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"7.1-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"7.2-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"7.3-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"7.4-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"8.0-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"8.1-${module}\"></td>" )
		html=${html}$( printf "%s" "  <td class=\"8.2-${module}\"></td>" )
		html=${html}$( printf "%s" " </tr>" )$'\n'

		# If module line does not exist, add line to table
		if ! grep "<td class=\"${module}\">" "${PROJECT_README}" >/dev/null; then
			perl -0 -i -pe "s|(<\!-- PHP_MODULES_TR_END -->)|${html}\1|s" "${PROJECT_README}"
		fi

		# If module is available, enable it in README.md
		if grep "<td class=\"${version}-${module}\">" "${PROJECT_README}" >/dev/null; then
			echo "[PHP ${version}] adding ${module}"
			perl -0 -i -pe "s|(<td class=\"${version}-${module}\">)(.*?)(</td>)|\1🗸\3|s" "${PROJECT_README}"
		else
			>&2 echo "Error, README.md not well formatted"
			exit 1
		fi
	done <<< "${modules}"

	###
	### (2/3) Ensure non-found modules are disabled in REAMDE.md
	###
	while IFS= read -r line; do
		if [ -z "${line}" ]; then
			continue
		fi
		# Extract the module name from the table line
		module="$( echo "${line}" | perl -0 -pe "s|.+<td class=\"${version}-(.+?)\">.+|\1|g" )" # | awk -F'"' '{print $1}' )"
		#echo "${module}"
		# Remove module if not inf found modules
		if ! echo "${modules}" | grep "^${module}\$" >/dev/null; then
			echo "[PHP ${version}] removing ${module}"
			perl -0 -i -pe "s|(<td class=\"${version}-${module}\">)(.*?)(</td>)|\1:x:\3|s" "${PROJECT_README}"
		fi
	done <<< "$( grep -E "<td class=\"${version}-" "${PROJECT_README}" )"

	###
	### (3/3) Sort module lines
	###
	TABLE="$( grep -A 100000000 'PHP_MODULES_TR_START' "${PROJECT_README}" | grep -B 100000000 'PHP_MODULES_TR_END' | grep -Ev 'PHP_MODULES_TR_START|PHP_MODULES_TR_END' | sort --field-separator='"' --key=2n )"
	perl -0 -i -pe "s|(<\!-- PHP_MODULES_TR_START -->)(.+)(<\!-- PHP_MODULES_TR_END -->)|\1\n${TABLE}\n\3|s" "${PROJECT_README}"
}


###
### Entrypoint
###
if [ "${VERSION}" = "" ]; then
	# Update PHP modules for all versions at once
	update_readme "5.2"
	update_readme "5.3"
	update_readme "5.4"
	update_readme "5.5"
	update_readme "5.6"
	update_readme "7.0"
	update_readme "7.1"
	update_readme "7.2"
	update_readme "7.3"
	update_readme "7.4"
	update_readme "8.0"
	update_readme "8.1"
	update_readme "8.2"
else
	if [ "${VERSION}" != "5.2" ] \
	&& [ "${VERSION}" != "5.3" ] \
	&& [ "${VERSION}" != "5.4" ] \
	&& [ "${VERSION}" != "5.5" ] \
	&& [ "${VERSION}" != "5.6" ] \
	&& [ "${VERSION}" != "7.0" ] \
	&& [ "${VERSION}" != "7.1" ] \
	&& [ "${VERSION}" != "7.2" ] \
	&& [ "${VERSION}" != "7.3" ] \
	&& [ "${VERSION}" != "7.4" ] \
	&& [ "${VERSION}" != "8.0" ] \
	&& [ "${VERSION}" != "8.1" ] \
	&& [ "${VERSION}" != "8.2" ]; then
		# Argument does not match any of the PHP versions
		>&2 echo "Error, invalid argument."
		print_usage
		exit 1
	else
		# Update PHP modules for one specific PHP version
		update_readme "${VERSION}"
	fi
fi
