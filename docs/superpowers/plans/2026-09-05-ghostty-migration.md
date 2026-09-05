# Ghostty Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install Ghostty and make it the configured terminal that automatically opens Herdr while preserving the current iTerm palette.

**Architecture:** Store one portable Ghostty configuration in the repository and expose it through the existing symlink installer. Keep shell startup responsible for launching Herdr, but restrict that behavior to interactive Ghostty shells outside Herdr and tmux.

**Tech Stack:** Ghostty, Homebrew casks, zsh, Bash, macOS plist preferences

**Spec:** `docs/superpowers/specs/2026-09-05-ghostty-migration-design.md`

## Global Constraints

- Keep iTerm installed as a fallback.
- Do not change global macOS file or terminal associations.
- Preserve the exact sRGB palette recorded in the spec.
- Use `JetBrainsMono Nerd Font Mono` at 13 points.
- Keep Ghostty's native keybindings.
- Keep `HERDR_AUTOSTART=0` as the manual escape hatch.
- Do not launch Herdr inside tmux, Claude Code, an existing Herdr pane, a non-interactive shell, or a shell without a TTY.

---

### Task 1: Install and inspect Ghostty

**Files:**
- No repository files changed.

**Interfaces:**
- Consumes: Homebrew cask repository and the installed JetBrains Mono Nerd Font.
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

- [ ] **Step 4: Verify the selected font family name**

Run:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +list-fonts | rg -F "JetBrainsMono Nerd Font Mono"
```

Expected: at least one matching regular face. If Ghostty exposes a different family spelling for the already-installed `JetBrainsMonoNFM-Regular`, use the exact family returned and update both spec and config consistently.

### Task 2: Add the versioned Ghostty configuration

**Files:**
- Create: `ghostty/config`

**Interfaces:**
- Consumes: the palette and font choice from the design spec.
- Produces: a complete Ghostty configuration loadable through `~/.config/ghostty/config`.

- [ ] **Step 1: Verify that the configuration is absent**

Run:

```bash
test ! -e ghostty/config
```

Expected: PASS, proving the test detects the pre-implementation state.

- [ ] **Step 2: Create the minimal configuration**

Create `ghostty/config` with:

```ini
# Ghostty — reproduce the former iTerm profile while leaving terminal
# navigation and pane management to Herdr.
font-family = JetBrainsMono Nerd Font Mono
font-size = 13

window-width = 80
window-height = 25
background-opacity = 1

background = #fafafa
foreground = #101010
cursor-color = #000000
cursor-text = #ffffff
selection-background = #b3d7ff
selection-foreground = #000000

palette = 0=#14191e
palette = 1=#b43c2a
palette = 2=#00c200
palette = 3=#c7c400
palette = 4=#2744c7
palette = 5=#c040be
palette = 6=#00c5c7
palette = 7=#c7c7c7
palette = 8=#686868
palette = 9=#dd7975
palette = 10=#58e790
palette = 11=#ece100
palette = 12=#a7abf2
palette = 13=#e17ee1
palette = 14=#60fdff
palette = 15=#ffffff
```

- [ ] **Step 3: Validate the versioned config in isolation**

Run:

```bash
mkdir -p /tmp/ghostty-cache
XDG_CACHE_HOME=/tmp/ghostty-cache /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$PWD/ghostty/config"
```

Expected: exit 0 with no configuration errors on stderr.

- [ ] **Step 4: Check formatting and commit the configuration**

Run:

```bash
git diff --check
git add ghostty/config
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
- Produces: evidence that Ghostty opens successfully with the migrated appearance; the user retains control of the GUI session.

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

Expected: Ghostty opens an 80×25 light terminal using the migrated palette and 13-point Nerd Font, and the interactive shell starts Herdr. iTerm remains installed.

- [ ] **Step 3: Verify the tmux escape path manually**

From a Ghostty shell left available after detaching Herdr, run:

```bash
tmux new-session
```

Expected: the tmux shell does not start another Herdr client because `$TMUX` is set.
