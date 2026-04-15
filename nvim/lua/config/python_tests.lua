local M = {}

function M.is_python_test_file(file_path)
  if not file_path or not vim.endswith(file_path, ".py") then
    return false
  end

  local normalized_path = file_path:gsub("\\", "/")
  local file_name = vim.fn.fnamemodify(file_path, ":t")

  return file_name == "test.py"
    or file_name == "tests.py"
    or vim.startswith(file_name, "test_")
    or vim.endswith(file_name, "_test.py")
    or vim.endswith(file_name, "_tests.py")
    or normalized_path:match("/tests?/") ~= nil
end

local function project_root(path)
  return vim.fs.root(path, { "Makefile", "pyproject.toml", "pytest.ini", "setup.cfg", ".git" })
    or vim.fn.getcwd()
end

local function makefile_contents(root)
  local makefile = root and (root .. "/Makefile") or nil
  if not makefile or vim.fn.filereadable(makefile) ~= 1 then
    return nil
  end

  local lines = vim.fn.readfile(makefile)
  return table.concat(lines, "\n")
end

local function docker_project_name(root)
  local contents = makefile_contents(root)
  if not contents then
    return nil
  end

  local project_name = contents:match("PROJECT_NAME%s*:?=%s*([%w%-%._]+)")
  return project_name or nil
end

local function docker_command(root)
  local project_name = docker_project_name(root)
  local compose_file = root .. "/docker/docker-compose.yml"
  if not project_name or vim.fn.filereadable(compose_file) ~= 1 then
    return nil
  end

  local command = {
    "docker",
    "compose",
    "-p",
    project_name,
    "-f",
    compose_file,
  }

  local override_file = root .. "/docker/docker-compose.local.yml"
  if vim.fn.filereadable(override_file) == 1 then
    vim.list_extend(command, { "-f", override_file })
  end

  return command
end

local function docker_available(root)
  local compose_command = docker_command(root)
  local contents = makefile_contents(root)
  return compose_command ~= nil
    and contents ~= nil
    and contents:match("docker compose")
    and contents:match("exec %-T app pytest")
end

local function local_pytest_available(root)
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    return true
  end

  for _, candidate in ipairs({
    root .. "/.venv/pyvenv.cfg",
    root .. "/venv/pyvenv.cfg",
  }) do
    if vim.fn.filereadable(candidate) == 1 then
      return true
    end
  end

  return false
end

function M.detect_mode(path)
  local configured_mode = vim.g.python_test_mode or "auto"
  local root = project_root(path)

  if configured_mode == "docker" then
    return "docker", root
  end

  if configured_mode == "local" then
    return "local", root
  end

  if docker_available(root) then
    return "docker", root
  end

  if local_pytest_available(root) then
    return "local", root
  end

  return "none", root
end

local function field_text(node, bufnr, field_name)
  local field = node:field(field_name)
  local field_node = field and field[1] or nil
  if not field_node then
    return nil
  end

  return vim.treesitter.get_node_text(field_node, bufnr)
end

local function pytest_selector(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil, "Buffer has no file path"
  end

  local root = project_root(path)
  local relative_path = vim.fs.relpath(root, path) or vim.fn.fnamemodify(path, ":.")
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local parser = vim.treesitter.get_parser(bufnr, "python")
  local tree = parser:parse()[1]
  local node = tree:root():named_descendant_for_range(row, col, row, col)

  local test_name
  local class_name

  while node do
    if node:type() == "function_definition" and not test_name then
      local candidate = field_text(node, bufnr, "name")
      if candidate and candidate:match("^test") then
        test_name = candidate
      end
    elseif node:type() == "class_definition" and test_name and not class_name then
      class_name = field_text(node, bufnr, "name")
    end

    node = node:parent()
  end

  if test_name and class_name then
    return relative_path .. "::" .. class_name .. "::" .. test_name
  end

  if test_name then
    return relative_path .. "::" .. test_name
  end

  if M.is_python_test_file(path) then
    return relative_path
  end

  return nil, "Cursor is not inside a Python test"
end

local function open_terminal(command, cwd)
  vim.cmd("botright 15split")
  vim.cmd("enew")

  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buflisted = false

  vim.fn.termopen(command, { cwd = cwd })
  vim.cmd("startinsert")
end

local function run_docker_test(path)
  local root = project_root(path)
  local selector, selector_error = pytest_selector(0)
  if not selector then
    vim.notify(selector_error, vim.log.levels.WARN)
    return
  end

  local compose_command = docker_command(root)
  if not compose_command then
    vim.notify("Docker test configuration not found for this project", vim.log.levels.ERROR)
    return
  end

  local command = vim.list_extend(vim.deepcopy(compose_command), { "exec", "-T", "app", "pytest", selector })
  open_terminal(command, root)
end

function M.run_nearest()
  local path = vim.api.nvim_buf_get_name(0)
  local mode = M.detect_mode(path)

  if mode == "docker" then
    run_docker_test(path)
    return
  end

  if mode == "local" then
    require("neotest").run.run()
    return
  end

  vim.notify("No Python test runner available: no Docker project and no local pytest environment", vim.log.levels.ERROR)
end

return M
