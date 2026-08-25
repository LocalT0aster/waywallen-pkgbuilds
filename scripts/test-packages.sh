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

# Qt GUI initialization aborts in CI's headless container. Check the relocation that broke after Qt's ABI update instead.
if readelf --dyn-syms --wide "$(command -v waywallen-ui)" | grep -Fq '_ZN23QUntypedPropertyBindingC1EP23QPropertyBindingPrivate@Qt_6_PRIVATE_API'; then
  printf 'waywallen-ui references the removed Qt private ABI symbol.\n' >&2
  exit 1
fi

if [[ " ${BUILD_PACKAGES:-waywallen waywallen-display open-wallpaper-engine} " == *' waywallen-display '* ]]; then
  layer_shell_output=$(waywallen-layer-shell --help 2>&1 || true)
  assert_help_contains waywallen-layer-shell "$layer_shell_output" 'usage: waywallen-layer-shell '
fi
