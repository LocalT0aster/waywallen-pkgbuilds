#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel)
declare -A repos=(
  [waywallen]='waywallen/waywallen'
  [waywallen-display]='waywallen/waywallen-display'
  [open-wallpaper-engine]='waywallen/open-wallpaper-engine'
)

for name in waywallen waywallen-display open-wallpaper-engine; do
  printf '::group::Update pinned submodule: %s (%s)\n' "$name" "${repos[$name]}"
  previous=$(git -C "$root/upstream/$name" describe --tags --exact-match HEAD 2>/dev/null || git -C "$root/upstream/$name" rev-parse --short HEAD)
  tag=$(gh api "repos/${repos[$name]}/releases/latest" --jq .tag_name)
  [[ $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { printf 'Unsupported release tag: %s\n' "$tag" >&2; exit 1; }
  printf '%s (%s): %s -> %s\n' "$name" "${repos[$name]}" "$previous" "$tag"
  git -C "$root/upstream/$name" fetch --tags origin
  git -C "$root/upstream/$name" checkout --detach "$tag"
  if [[ -n ${GITHUB_STEP_SUMMARY:-} ]]; then
    printf -- '- **%s** (`%s`): `%s` → `%s`\n' "$name" "${repos[$name]}" "$previous" "$tag" >> "$GITHUB_STEP_SUMMARY"
  fi
  printf '::endgroup::\n'
done
