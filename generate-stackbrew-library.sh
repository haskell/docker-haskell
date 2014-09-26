#!/usr/bin/env bash

set -eu
set -o pipefail

declare -rA aliases=(
	[7.8.3]='9 latest'
)

main() {
  declare -ra local argv=("${@}")
  declare -r  local argc="${#argv[@]}"
  exit 0
}

main "${@}"



cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/postgres'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	commit="$(git log -1 --format='format:%H' "$version")"
	fullVersion="$(grep -m1 'ENV PG_VERSION ' "$version/Dockerfile" | cut -d' ' -f3 | cut -d- -f1 | sed 's/~/-/g')"
	versionAliases=( $fullVersion $version ${aliases[$version]} )

	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
done
