#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
test_root="$(mktemp -d /tmp/dotfiles-ghostty-test.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

mkdir -p \
  "$test_root/config/ghostty" \
  "$test_root/cache" \
  "$test_root/home" \
  "$test_root/baseline/config/ghostty" \
  "$test_root/baseline/cache" \
  "$test_root/baseline/home"
ln -s "$repo_root/ghostty/config" "$test_root/config/ghostty/config"
touch "$test_root/baseline/config/ghostty/config"

XDG_CONFIG_HOME="$test_root/config" \
XDG_CACHE_HOME="$test_root/cache" \
HOME="$test_root/home" \
  "$ghostty_bin" +validate-config

changes="$(
  XDG_CONFIG_HOME="$test_root/config" \
  XDG_CACHE_HOME="$test_root/cache" \
  HOME="$test_root/home" \
    "$ghostty_bin" +show-config
)"

baseline="$(
  XDG_CONFIG_HOME="$test_root/baseline/config" \
  XDG_CACHE_HOME="$test_root/baseline/cache" \
  HOME="$test_root/baseline/home" \
    "$ghostty_bin" +show-config
)"

if [ "$changes" != "$baseline" ]; then
  echo "Ghostty config differs from a zero-config baseline:" >&2
  echo "$changes" >&2
  exit 1
fi
