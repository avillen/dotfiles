# Ghostty Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install Ghostty and make it the zero-config terminal that automatically opens Herdr.

**Architecture:** Store one portable Ghostty configuration in the repository and expose it through the existing symlink installer. Keep shell startup responsible for launching Herdr, but restrict that behavior to interactive Ghostty shells outside Herdr and tmux.

**Tech Stack:** Ghostty, Homebrew casks, zsh, Bash, macOS plist preferences

**Spec:** `docs/superpowers/specs/2026-09-05-ghostty-migration-design.md`

## Global Constraints

- Keep iTerm installed as a fallback.
- Do not change global macOS file or terminal associations.
- Keep Ghostty's native keybindings.
- Keep `HERDR_AUTOSTART=0` as the manual escape hatch.
- Do not launch Herdr inside tmux, Claude Code, an existing Herdr pane, a non-interactive shell, or a shell without a TTY.

---

### Task 1: Install and inspect Ghostty

**Files:**
- No repository files changed.

**Interfaces:**
- Consumes: Homebrew's Ghostty cask.
- Produces: `/Applications/Ghostty.app`, its CLI executable, and locally installed configuration reference documentation.

- [ ] **Step 1: Verify the precondition**

Run:

```bash
test ! -d /Applications/Ghostty.app
```

Expected: PASS before installation. If Ghostty has appeared since planning, skip installation and continue with inspection.

- [ ] **Step 2: Install the signed Ghostty cask**

Run:

```bash
brew install --cask ghostty
```

Expected: Homebrew reports Ghostty installed in `/Applications/Ghostty.app`.

- [ ] **Step 3: Verify the application and CLI**

Run:

```bash
test -d /Applications/Ghostty.app
/Applications/Ghostty.app/Contents/MacOS/ghostty --version
```

Expected: both commands exit 0 and the second prints the installed Ghostty version.

### Task 2: Add the versioned Ghostty configuration

**Files:**
- Create: `ghostty/config`
- Test: `tests/test_ghostty_config.sh`

**Interfaces:**
- Consumes: Ghostty's native defaults.
- Produces: a stable, zero-config file loadable through `~/.config/ghostty/config`.

- [ ] **Step 1: Write the failing zero-config behavior test**

Create `tests/test_ghostty_config.sh` to load the versioned config and a truly
empty config in isolated XDG directories, then compare Ghostty's effective
`+show-config` output. Run:

```bash
bash tests/test_ghostty_config.sh
```

Expected: FAIL while the versioned config still contains visual overrides.

- [ ] **Step 2: Create the minimal configuration**

Create `ghostty/config` with:

```ini
# Ghostty — zero-config by design.
#
# Keep this file versioned so install.sh can provision the expected path, but
# let Ghostty choose its native theme, font, dimensions and keybindings. Add
# overrides here only after trying the defaults in daily use.
```

- [ ] **Step 3: Validate the versioned config in isolation**

Run:

```bash
mkdir -p /tmp/ghostty-cache
XDG_CACHE_HOME=/tmp/ghostty-cache /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$PWD/ghostty/config"
bash tests/test_ghostty_config.sh
```

Expected: exit 0 with no configuration errors on stderr.

- [ ] **Step 4: Check formatting and commit the configuration**

Run:

```bash
git diff --check
git add ghostty/config tests/test_ghostty_config.sh
git commit -m "feat: add Ghostty terminal config"
```

Expected: clean whitespace check and one commit containing only `ghostty/config`.

### Task 3: Wire installation and Herdr auto-start

**Files:**
- Modify: `install.sh:29-41`
- Modify: `zsh/.zshrc:15-44`
- Create: `tests/test_install.sh`
- Create: `tests/test_zsh_autostart.sh`

**Interfaces:**
- Consumes: `ghostty/config` from Task 2 and Ghostty's `TERM_PROGRAM=ghostty` environment contract.
- Produces: `~/.config/ghostty/config` and a Herdr auto-start predicate scoped to Ghostty.

- [ ] **Step 1: Write the failing behavioral checks**

Create behavioral tests that run the real installer twice in an isolated
temporary HOME and open interactive zsh under a pseudo-terminal. Then run:

```bash
bash tests/test_install.sh
bash tests/test_zsh_autostart.sh
```

Expected: the installer test fails because the Ghostty link is missing, and
the zsh test fails because Ghostty does not start Herdr.

- [ ] **Step 2: Add the Ghostty link to the installer**

Add this block after the tmux block in `install.sh`:

```bash
echo "→ ghostty"
mkdir -p "$HOME/.config/ghostty"
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
```

- [ ] **Step 3: Scope the Herdr auto-start block to Ghostty**

Update the prose in `zsh/.zshrc` from iTerm to Ghostty, change the terminal predicate to:

```zsh
  && [[ "$TERM_PROGRAM" == "ghostty" ]] \
```

and add the tmux guard next to the existing environment guards:

```zsh
  && [[ -z "$TMUX" ]] \
```

Keep the existing interactive, TTY, `HERDR_ENV`, `CLAUDECODE`,
`HERDR_AUTOSTART`, executable-presence, and non-`exec` behavior unchanged.

- [ ] **Step 4: Run syntax and structural checks**

Run:

```bash
bash -n install.sh
zsh -n zsh/.zshrc
bash tests/test_install.sh
bash tests/test_zsh_autostart.sh
! rg -n -i 'iterm' zsh/.zshrc
```

Expected: every command exits 0.

- [ ] **Step 5: Install the symlink without disturbing existing links**

Run:

```bash
./install.sh
```

Expected: the installer links the Ghostty config and retains valid links for zsh, git, tmux, Herdr, and Neovim. If a real `~/.config/ghostty/config` exists, it is moved to `config.bak` first.

- [ ] **Step 6: Verify the live configuration and existing Herdr config**

Run:

```bash
test -L "$HOME/.config/ghostty/config"
test "$(readlink "$HOME/.config/ghostty/config")" = "$PWD/ghostty/config"
XDG_CACHE_HOME=/tmp/ghostty-cache /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config
herdr config check
git diff --check
```

Expected: all commands exit 0 and Herdr prints `config: ok`.

- [ ] **Step 7: Commit the integration**

Run:

```bash
git add install.sh zsh/.zshrc tests/test_install.sh tests/test_zsh_autostart.sh docs/superpowers/plans/2026-09-05-ghostty-migration.md
git commit -m "feat: migrate terminal startup to Ghostty"
```

Expected: one commit containing the installer, shell startup changes, their
behavioral regressions, and the corrected validation commands in this plan.

### Task 4: Launch smoke test

**Files:**
- No repository files changed.

**Interfaces:**
- Consumes: the installed application, live Ghostty symlink, and updated zsh startup predicate.
- Produces: evidence that Ghostty opens successfully with its native appearance; the user retains control of the GUI session.

- [ ] **Step 1: Confirm the final repository state**

Run:

```bash
git status --short --branch
git log -4 --oneline
```

Expected: a clean worktree on `main`, with the design, configuration, and integration commits at the tip.

- [ ] **Step 2: Open Ghostty for visual verification**

Run:

```bash
open -a Ghostty
```

Expected: Ghostty opens with its native appearance and the interactive shell starts Herdr. iTerm remains installed.

- [ ] **Step 3: Verify the tmux escape path manually**

From a Ghostty shell left available after detaching Herdr, run:

```bash
tmux new-session
```

Expected: the tmux shell does not start another Herdr client because `$TMUX` is set.
