#!/usr/bin/env bash
set -euo pipefail

# Usage: prune-packages.sh [directory]
# Keeps the newest PACKAGE_VERSIONS distinct package versions per package name
# for rollback. Rebuilds of the newest version (same pkgver, older pkgrel) do
# not count as versions and are always discarded.
dir=${1:-dist/x86_64}
retention=${PACKAGE_VERSIONS:-3}
shopt -s nullglob

sort_desc() {
  local sorted=() v i pos
  for v in "$@"; do
    pos=${#sorted[@]}
    for ((i = 0; i < ${#sorted[@]}; i++)); do
      if (( $(vercmp "$v" "${sorted[$i]}") > 0 )); then
        pos=$i
        break
      fi
    done
    if ((pos == ${#sorted[@]})); then
      sorted+=("$v")
    else
      sorted=("${sorted[@]:0:pos}" "$v" "${sorted[@]:pos}")
    fi
  done
  printf '%s\n' "${sorted[@]}"
}

declare -A file_of=()
declare -A names=()
for pkg_file in "$dir"/*.pkg.tar.zst; do
  read -r name version _ <<< "$(pacman -Qp "$pkg_file")"
  file_of["${name}|${version}"]=$pkg_file
  names[$name]=1
done

removed=0
for name in "${!names[@]}"; do
  declare -A per_name=()
  for key in "${!file_of[@]}"; do
    if [[ ${key%%|*} == "$name" ]]; then
      per_name[${key#*|}]=${file_of[$key]}
    fi
  done
  mapfile -t versions < <(sort_desc "${!per_name[@]}")
  previous_pkgver=''
  kept_groups=0
  for version in "${versions[@]}"; do
    pkgver=${version%-*}
    if ((kept_groups >= retention)); then
      printf 'Pruning %s\n' "${per_name[$version]}" >&2
      rm -f "${per_name[$version]}" "${per_name[$version]}.sig"
      ((++removed))
    elif [[ $pkgver != "$previous_pkgver" ]]; then
      ((++kept_groups))
      previous_pkgver=$pkgver
    else
      printf 'Pruning %s\n' "${per_name[$version]}" >&2
      rm -f "${per_name[$version]}" "${per_name[$version]}.sig"
      ((++removed))
    fi
  done
  unset per_name
done

printf 'Pruned %d package(s) from %s\n' "$removed" "$dir"
