#!/usr/bin/env bash
set -euo pipefail

[[ " ${BUILD_PACKAGES:-waywallen waywallen-display open-wallpaper-engine} " == *' waywallen '* ]] || exit 0

assert_help_contains() {
  local program=$1 output=$2 expected=$3
  if [[ $output != *"$expected"* ]]; then
    printf '%s --help did not contain %q:\n%s\n' "$program" "$expected" "$output" >&2
    return 1
  fi
}

waywallen_output=$(waywallen --help 2>&1 || true)
assert_help_contains waywallen "$waywallen_output" 'Usage: waywallen '

# A successful start catches the Qt private-ABI mismatch without depending on Qt's help formatting.
waywallen-ui --help >/dev/null 2>&1

layer_shell_output=$(waywallen-layer-shell --help 2>&1 || true)
assert_help_contains waywallen-layer-shell "$layer_shell_output" 'usage: waywallen-layer-shell '
