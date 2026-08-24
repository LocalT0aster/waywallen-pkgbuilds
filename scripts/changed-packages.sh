#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel)
base=${1:-}
all_packages=(waywallen waywallen-display open-wallpaper-engine)

if [[ $base == --working-tree ]]; then
  changed_files=$(git -C "$root" diff --name-only)
elif [[ -z $base || $base == 0000000000000000000000000000000000000000 ]]; then
  printf '%s\n' "${all_packages[*]}"
  exit 0
else
  git -C "$root" cat-file -e "$base^{commit}" 2>/dev/null || \
    git -C "$root" fetch --depth=1 origin "$base"
  changed_files=$(git -C "$root" diff --name-only "$base" HEAD)
fi

declare -A selected=()
while IFS= read -r file; do
  case $file in
    packages/waywallen/*|upstream/waywallen|upstream/waywallen/*)
      selected[waywallen]=1
      selected[open-wallpaper-engine]=1
      ;;
    packages/waywallen-display/*|upstream/waywallen-display|upstream/waywallen-display/*)
      selected[waywallen-display]=1
      ;;
    packages/open-wallpaper-engine/*|upstream/open-wallpaper-engine|upstream/open-wallpaper-engine/*)
      selected[waywallen]=1
      selected[open-wallpaper-engine]=1
      ;;
    .gitmodules|scripts/*|ci/*|.github/actions/build-test/*|.github/workflows/*)
      selected[waywallen]=1
      selected[waywallen-display]=1
      selected[open-wallpaper-engine]=1
      ;;
  esac
done <<< "$changed_files"

packages=()
for package in "${all_packages[@]}"; do
  [[ ${selected[$package]:-} ]] && packages+=("$package")
done
printf '%s\n' "${packages[*]}"
