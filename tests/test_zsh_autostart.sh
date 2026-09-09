#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d /tmp/dotfiles-zsh-test.XXXXXX)"
trap 'rm -rf "$test_home"' EXIT

mkdir -p "$test_home/.local/bin" "$test_home/.oh-my-zsh"
printf '%s\n' \
  '#!/bin/sh' \
  'printf invoked >"$HERDR_TEST_LOG"' \
  >"$test_home/.local/bin/herdr"
chmod +x "$test_home/.local/bin/herdr"
touch "$test_home/.oh-my-zsh/oh-my-zsh.sh"

run_case() {
  local name="$1" term_program="$2" tmux_value="$3" expected="$4"
  local log="$test_home/$name.log"

  /usr/bin/script -q /dev/null /usr/bin/env \
    HOME="$test_home" \
    ZDOTDIR="$repo_root/zsh" \
    PATH="/usr/local/bin:/usr/bin:/bin" \
    TERM_PROGRAM="$term_program" \
    TMUX="$tmux_value" \
    HERDR_ENV= \
    CLAUDECODE= \
    HERDR_AUTOSTART=1 \
    HERDR_TEST_LOG="$log" \
    /bin/zsh -i -c exit \
    >/dev/null

  if [ "$expected" = invoked ] && [ ! -f "$log" ]; then
    echo "$name: expected Herdr to start" >&2
    exit 1
  fi
  if [ "$expected" = skipped ] && [ -f "$log" ]; then
    echo "$name: expected Herdr to stay stopped" >&2
    exit 1
  fi
}

run_case ghostty-starts-herdr ghostty "" invoked
run_case other-terminal-does-not-start-herdr Apple_Terminal "" skipped
run_case tmux-does-not-start-herdr ghostty /tmp/tmux-1000/default,1,0 skipped
