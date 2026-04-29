local M = {}

local uv = vim.uv or vim.loop

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function trim(value)
  return vim.trim(value or "")
end

local function system(cmd, cwd)
  local result = vim.system(cmd, { text = true, cwd = cwd }):wait()
  return result.code, trim(result.stdout), trim(result.stderr)
end

local function current_dir()
  return vim.fn.getcwd()
end

local function git_repo_root()
  local code, stdout = system({ "git", "rev-parse", "--show-toplevel" }, current_dir())
  if code ~= 0 or stdout == "" then
    return nil
  end
  return stdout
end

local function repo_name(repo_root)
  return vim.fs.basename(repo_root)
end

local function sanitize_branch_name(branch)
  return branch:gsub("[/\\%s]+", "-")
end

local function branch_exists(branch, repo_root)
  local code = system({ "git", "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }, repo_root)
  return code == 0
end

local function path_exists(path)
  return uv.fs_stat(path) ~= nil
end

local function worktree_path(repo_root, branch)
  local parent = vim.fs.dirname(repo_root)
  local repo = repo_name(repo_root)
  local safe_branch = sanitize_branch_name(branch)
  return vim.fs.joinpath(parent, "worktrees", repo .. "-" .. safe_branch)
end

local function prompt_branch(prompt)
  return trim(vim.fn.input(prompt))
end

local function require_repo_root()
  local repo_root = git_repo_root()
  if not repo_root then
    notify("Not inside a Git repository", vim.log.levels.ERROR)
    return nil
  end
  return repo_root
end

local function ensure_branch_name(branch)
  if branch == "" then
    notify("Branch name cannot be empty", vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.create_new_branch_worktree()
  local repo_root = require_repo_root()
  if not repo_root then
    return
  end

  local branch = prompt_branch("New branch name: ")
  if not ensure_branch_name(branch) then
    return
  end

  if branch_exists(branch, repo_root) then
    notify("Local branch already exists: " .. branch, vim.log.levels.ERROR)
    return
  end

  local path = worktree_path(repo_root, branch)
  if path_exists(path) then
    notify("Worktree path already exists: " .. path, vim.log.levels.ERROR)
    return
  end

  local created = require("worktrees").utils.create_worktree(path, branch, true)
  if not created then
    notify("Failed to create worktree for branch: " .. branch, vim.log.levels.ERROR)
    return
  end

  notify("Created worktree: " .. path)
end

function M.create_existing_branch_worktree()
  local repo_root = require_repo_root()
  if not repo_root then
    return
  end

  local branch = prompt_branch("Existing branch name: ")
  if not ensure_branch_name(branch) then
    return
  end

  if not branch_exists(branch, repo_root) then
    notify("Local branch does not exist: " .. branch, vim.log.levels.ERROR)
    return
  end

  local path = worktree_path(repo_root, branch)
  if path_exists(path) then
    notify("Worktree path already exists: " .. path, vim.log.levels.ERROR)
    return
  end

  local code, _, stderr = system({ "git", "worktree", "add", path, branch }, repo_root)
  if code ~= 0 then
    local message = stderr ~= "" and stderr or "git worktree add failed"
    notify("Failed to create worktree: " .. message, vim.log.levels.ERROR)
    return
  end

  local switched = require("worktrees").utils.switch_worktree(path)
  if not switched then
    notify("Created worktree but failed to switch: " .. path, vim.log.levels.WARN)
    return
  end

  notify("Created worktree: " .. path)
end

function M.switch_worktree()
  require("worktrees").switch()
end

function M.delete_worktree()
  require("worktrees").delete()
end

return M
