#!/usr/bin/env bash
set -euo pipefail

[[ " ${BUILD_PACKAGES:-waywallen waywallen-display open-wallpaper-engine} " == *' waywallen '* ]] || exit 0

waywallen_output=$(waywallen --help 2>&1 || true)
[[ $waywallen_output == *'Usage: waywallen '* ]]

ui_output=$(waywallen-ui --help 2>&1 || true)
[[ $ui_output == *'--ws-port <port>'* ]]

layer_shell_output=$(waywallen-layer-shell --help 2>&1 || true)
[[ $layer_shell_output == *'usage: waywallen-layer-shell '* ]]
