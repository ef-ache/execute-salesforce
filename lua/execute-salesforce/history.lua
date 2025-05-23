local M = {}

-- History storage
local apex_history = {}
local soql_history = {}
local max_history = 50

-- Get data directory
local function get_data_dir()
  local data_dir = vim.fn.stdpath("data") .. "/execute-salesforce"
  vim.fn.mkdir(data_dir, "p")
  return data_dir
end

-- Get history file paths
local function get_apex_history_file()
  return get_data_dir() .. "/apex_history.json"
end

local function get_soql_history_file()
  return get_data_dir() .. "/soql_history.json"
end

-- Load history from disk
local function load_history()
  -- Load Apex history
  local apex_file = get_apex_history_file()
  if vim.fn.filereadable(apex_file) == 1 then
    local content = vim.fn.readfile(apex_file)
    if #content > 0 then
      local ok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
      if ok and type(data) == "table" then
        apex_history = data
      end
    end
  end
  
  -- Load SOQL history
  local soql_file = get_soql_history_file()
  if vim.fn.filereadable(soql_file) == 1 then
    local content = vim.fn.readfile(soql_file)
    if #content > 0 then
      local ok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
      if ok and type(data) == "table" then
        soql_history = data
      end
    end
  end
end

-- Save history to disk
local function save_apex_history()
  local file = get_apex_history_file()
  local content = vim.fn.json_encode(apex_history)
  vim.fn.writefile({content}, file)
end

local function save_soql_history()
  local file = get_soql_history_file()
  local content = vim.fn.json_encode(soql_history)
  vim.fn.writefile({content}, file)
end

-- Initialize - load history on startup
load_history()

-- Add to history
function M.add_apex(code)
  -- Don't add duplicates
  for i, item in ipairs(apex_history) do
    if item == code then
      table.remove(apex_history, i)
      break
    end
  end
  
  table.insert(apex_history, 1, code)
  
  -- Limit history size
  if #apex_history > max_history then
    table.remove(apex_history)
  end
  
  -- Save to disk
  save_apex_history()
end

function M.add_soql(query)
  -- Don't add duplicates
  for i, item in ipairs(soql_history) do
    if item == query then
      table.remove(soql_history, i)
      break
    end
  end
  
  table.insert(soql_history, 1, query)
  
  -- Limit history size
  if #soql_history > max_history then
    table.remove(soql_history)
  end
  
  -- Save to disk
  save_soql_history()
end

-- Delete individual item from history
function M.delete_apex_item(index)
  if index > 0 and index <= #apex_history then
    table.remove(apex_history, index)
    save_apex_history()
    require("execute-salesforce.utils").show_info("Apex history item deleted")
  end
end

function M.delete_soql_item(index)
  if index > 0 and index <= #soql_history then
    table.remove(soql_history, index)
    save_soql_history()
    require("execute-salesforce.utils").show_info("SOQL history item deleted")
  end
end

-- Clear history
function M.clear_apex_history()
  apex_history = {}
  save_apex_history()
  require("execute-salesforce.utils").show_info("Apex history cleared")
end

function M.clear_soql_history()
  soql_history = {}
  save_soql_history()
  require("execute-salesforce.utils").show_info("SOQL history cleared")
end

-- Get history
function M.get_apex_history()
  return apex_history
end

function M.get_soql_history()
  return soql_history
end

-- Open buffer for editing
local function open_edit_buffer(content, filetype, callback)
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
  
  -- Set buffer options
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
  vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
  
  -- Open in a split
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
  
  -- Add instructions in buffer name only
  vim.api.nvim_buf_set_name(buf, "Edit and Execute (press <CR> to run, <Esc> to cancel)")
  
  -- Set up keymaps
  vim.keymap.set('n', '<CR>', function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local edited_content = table.concat(lines, "\n")
    vim.cmd('close')
    callback(edited_content)
  end, { buffer = buf, desc = "Execute edited code" })
  
  vim.keymap.set('n', '<Esc>', function()
    vim.cmd('close')
  end, { buffer = buf, desc = "Cancel execution" })
end

-- Show history picker with edit option
function M.pick_apex(callback, allow_edit)
  if #apex_history == 0 then
    require("execute-salesforce.utils").show_info("No Apex history")
    return
  end
  
  vim.ui.select(apex_history, {
    prompt = "Select Apex code from history (press <Tab> to edit):",
    format_item = function(item)
      -- Show first line or up to 80 chars
      local preview = item:match("^[^\n]+") or item
      if #preview > 80 then
        preview = preview:sub(1, 77) .. "..."
      end
      return preview
    end,
  }, function(choice, idx)
    if not choice then
      return
    end
    
    -- Check if Tab was pressed (we'll handle this differently)
    if allow_edit then
      -- Show a second prompt for action
      vim.ui.select({"Execute", "Edit then Execute", "Delete from History"}, {
        prompt = "Action for selected code:",
      }, function(action)
        if action == "Edit then Execute" then
          open_edit_buffer(choice, "apex", callback)
        elseif action == "Execute" then
          callback(choice)
        elseif action == "Delete from History" then
          M.delete_apex_item(idx)
        end
      end)
    else
      callback(choice)
    end
  end)
end

function M.pick_soql(callback, allow_edit)
  if #soql_history == 0 then
    require("execute-salesforce.utils").show_info("No SOQL history")
    return
  end
  
  vim.ui.select(soql_history, {
    prompt = "Select SOQL query from history:",
    format_item = function(item)
      -- Show first line or up to 80 chars
      local preview = item:gsub("%s+", " ")
      if #preview > 80 then
        preview = preview:sub(1, 77) .. "..."
      end
      return preview
    end,
  }, function(choice, idx)
    if not choice then
      return
    end
    
    if allow_edit then
      -- Show a second prompt for action
      vim.ui.select({"Execute", "Edit then Execute", "Delete from History"}, {
        prompt = "Action for selected query:",
      }, function(action)
        if action == "Edit then Execute" then
          open_edit_buffer(choice, "sql", callback)
        elseif action == "Execute" then
          callback(choice)
        elseif action == "Delete from History" then
          M.delete_soql_item(idx)
        end
      end)
    else
      callback(choice)
    end
  end)
end

-- Commands to execute from history
function M.execute_apex_from_history()
  M.pick_apex(function(code)
    -- Create temporary buffer with code
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(code, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Execute
    vim.api.nvim_set_current_buf(buf)
    require("execute-salesforce.apex").execute_apex(1, #lines)
    
    -- Clean up
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end, 100)
  end, true) -- Allow editing
end

function M.execute_soql_from_history()
  M.pick_soql(function(query)
    -- Create temporary buffer with query
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(query, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Execute
    vim.api.nvim_set_current_buf(buf)
    require("execute-salesforce.soql").execute_soql(1, #lines)
    
    -- Clean up
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end, 100)
  end, true) -- Allow editing
end

-- Unified history command
function M.execute_from_history()
  local counts = M.get_history_counts()
  local choices = {
    string.format("Apex History (%d items)", counts.apex),
    string.format("SOQL History (%d items)", counts.soql)
  }
  
  vim.ui.select(choices, {
    prompt = "Select history type:",
  }, function(choice)
    if choice and choice:match("^Apex History") then
      M.execute_apex_from_history()
    elseif choice and choice:match("^SOQL History") then
      M.execute_soql_from_history()
    end
  end)
end

-- Get history counts for display
function M.get_history_counts()
  return {
    apex = #apex_history,
    soql = #soql_history
  }
end

-- Manage history (view/delete items)
function M.manage_apex_history()
  if #apex_history == 0 then
    require("execute-salesforce.utils").show_info("No Apex history")
    return
  end
  
  vim.ui.select(apex_history, {
    prompt = "Select Apex history item to manage:",
    format_item = function(item)
      local preview = item:match("^[^\n]+") or item
      if #preview > 80 then
        preview = preview:sub(1, 77) .. "..."
      end
      return preview
    end,
  }, function(choice, idx)
    if not choice then
      return
    end
    
    vim.ui.select({"View", "Delete", "Cancel"}, {
      prompt = "Action:",
    }, function(action)
      if action == "View" then
        -- Show in a preview buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(choice, "\n"))
        vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
        vim.api.nvim_set_option_value('filetype', 'apex', { buf = buf })
        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, buf)
      elseif action == "Delete" then
        M.delete_apex_item(idx)
      end
    end)
  end)
end

function M.manage_soql_history()
  if #soql_history == 0 then
    require("execute-salesforce.utils").show_info("No SOQL history")
    return
  end
  
  vim.ui.select(soql_history, {
    prompt = "Select SOQL history item to manage:",
    format_item = function(item)
      local preview = item:gsub("%s+", " ")
      if #preview > 80 then
        preview = preview:sub(1, 77) .. "..."
      end
      return preview
    end,
  }, function(choice, idx)
    if not choice then
      return
    end
    
    vim.ui.select({"View", "Delete", "Cancel"}, {
      prompt = "Action:",
    }, function(action)
      if action == "View" then
        -- Show in a preview buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(choice, "\n"))
        vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
        vim.api.nvim_set_option_value('filetype', 'sql', { buf = buf })
        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, buf)
      elseif action == "Delete" then
        M.delete_soql_item(idx)
      end
    end)
  end)
end

return M