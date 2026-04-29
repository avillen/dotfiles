# Neovim Worktrees Design

## Goal

Add first-class Git worktree management to this Neovim setup so a new task can start from inside Neovim, create or reuse a branch, create the worktree in a predictable location, and switch directly into it without dropping to the terminal.

## Context

The current Neovim configuration already uses:

- `lazy.nvim` for plugin management
- `telescope.nvim` for interactive selection
- `neo-tree.nvim` for file navigation
- `diffview.nvim` and `gitsigns.nvim` for Git workflows
- central keymaps in `nvim/lua/config/keymaps.lua`

The requested workflow is:

1. Start from Neovim.
2. Create a worktree and open it immediately in the current session.
3. Support both:
   - a new worktree with a new branch
   - a new worktree from an existing branch
4. Store worktrees in a fixed convention: `../worktrees/<repo>-<branch>`.

## Proposed Approach

Use `afonsofrancof/worktrees.nvim` as the Git worktree management layer, and add a thin local wrapper to adapt it to this dotfiles setup.

This keeps Git worktree logic in a maintained plugin while preserving control over naming, prompts, and keymaps.

## Why This Approach

### Option 1: Plugin only

Using `worktrees.nvim` directly would provide create, switch, and delete flows quickly, but it would leave the naming convention and higher-level workflow mostly to the plugin's generic UI.

### Option 2: Plugin plus local wrapper

This adds a small config module that:

- separates "new branch" from "existing branch" workflows
- computes the target path using the repo name and branch name
- keeps keymaps and behavior aligned with the rest of the config

This is the recommended option because it balances low maintenance with precise UX.

### Option 3: Fully custom shell integration

Calling `git worktree` directly from custom Lua would give maximum control, but it would duplicate plugin behavior that already exists and increase maintenance cost for little gain.

## Detailed Design

### Plugin registration

Add a new plugin file under `nvim/lua/plugins/`, likely `worktrees.lua`, to install and configure `afonsofrancof/worktrees.nvim`.

The plugin config should:

- load lazily
- set `base_path` so new worktrees are created under `../worktrees`
- keep built-in switch and delete functionality available

`path_template` should not be the only naming mechanism, because the desired format includes both repo name and branch name. That logic belongs in the local wrapper module where the repo name can be derived explicitly.

### Local wrapper module

Add `nvim/lua/config/worktrees.lua` with focused helper functions:

- `create_new_branch_worktree()`
- `create_existing_branch_worktree()`
- `switch_worktree()`
- optionally `delete_worktree()`

Responsibilities of this module:

- determine the current Git repository root
- determine the repository name
- sanitize branch names if needed for filesystem-safe paths
- build target paths with the convention `../worktrees/<repo>-<branch>`
- call the plugin API to create or switch worktrees

This module should stay thin and avoid reimplementing Git worktree discovery or switching behavior that the plugin already provides.

### Keymaps

Add explicit keymaps in `nvim/lua/config/keymaps.lua` following the existing style.

Recommended mappings:

- `<leader>wn` for "new worktree from new branch"
- `<leader>we` for "new worktree from existing branch"
- `<leader>ws` for "switch worktree"
- optional: `<leader>wd` for "delete worktree"

These should not replace existing Telescope or Git bindings.

### User interaction

The desired UX is explicit rather than magical.

For a new branch worktree:

1. prompt for branch name
2. compute path `../worktrees/<repo>-<branch>`
3. create the worktree and branch
4. switch into it in the current Neovim session

For an existing branch worktree:

1. prompt for branch name
2. compute path `../worktrees/<repo>-<branch>`
3. create the worktree from that branch
4. switch into it in the current Neovim session

For switching:

1. show available worktrees
2. switch to the selected one
3. preserve the current file when the plugin can map it into the target worktree

### Scope boundaries

This first iteration will not manage:

- session persistence across worktrees
- opening a brand-new Neovim process
- special handling for `neo-tree`, terminal buffers, or `diffview`
- advanced branch selection UI through Telescope

Those can be added later if the basic workflow proves useful.

## Error Handling

The wrapper should handle and message these cases cleanly:

- not inside a Git repository
- empty branch name
- target worktree path already exists
- branch does not exist for the "existing branch" flow
- Git command or plugin operation failure

Errors should be shown with normal Neovim notifications instead of silent failure.

## Testing And Verification

Manual verification is sufficient for this change.

Test cases:

1. Create a worktree from a new branch inside a normal Git repo.
2. Create a worktree from an existing branch.
3. Switch between two existing worktrees.
4. Verify resulting paths match `../worktrees/<repo>-<branch>`.
5. Verify switching preserves the current file when that file exists in both worktrees.
6. Verify behavior outside a Git repo shows a clear error.

## Files Expected To Change

- `nvim/lua/plugins/worktrees.lua`
- `nvim/lua/config/worktrees.lua`
- `nvim/lua/config/keymaps.lua`
- possibly `nvim/lua/plugins/telescope.lua` only if later integration is added

## Non-Goals

- building a general project launcher
- replacing terminal Git workflows entirely
- adding persistent multi-worktree session management
- adding branch creation policies beyond what Git already supports

## Success Criteria

The design is successful if:

- a new task can be started from inside Neovim without dropping to shell
- both new-branch and existing-branch worktree creation flows work
- worktrees are created consistently under `../worktrees/<repo>-<branch>`
- switching between worktrees is fast and predictable
- the implementation stays small and maintainable within this dotfiles repo
