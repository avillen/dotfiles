#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d /tmp/dotfiles-install-test.XXXXXX)"
test_home="$test_root/home"
test_repo="$test_root/dotfiles"
trap 'rm -rf "$test_root"' EXIT

mkdir -p "$test_home" "$test_repo"
cp -R \
  "$repo_root/install.sh" \
  "$repo_root/git" \
  "$repo_root/ghostty" \
  "$repo_root/herdr" \
  "$repo_root/nvim" \
  "$repo_root/tmux" \
  "$repo_root/worktrunk" \
  "$repo_root/zsh" \
  "$test_repo"

HOME="$test_home" "$test_repo/install.sh" >/dev/null
HOME="$test_home" "$test_repo/install.sh" >/dev/null

ghostty_link="$test_home/.config/ghostty/config"
if [ ! -L "$ghostty_link" ]; then
  echo "missing Ghostty config symlink: $ghostty_link" >&2
  exit 1
fi

expected="$test_repo/ghostty/config"
actual="$(readlink "$ghostty_link")"
if [ "$actual" != "$expected" ]; then
  echo "Ghostty config points to '$actual', expected '$expected'" >&2
  exit 1
fi

if [ -e "$test_repo/nvim/nvim" ]; then
  echo "re-running install created a nested nvim symlink" >&2
  exit 1
fi
