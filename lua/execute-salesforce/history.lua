local M = {}

-- History storage
local apex_history = {}
local soql_history = {}
local max_history = 50

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
end

-- Get history
function M.get_apex_history()
  return apex_history
end

function M.get_soql_history()
  return soql_history
end

-- Show history picker
function M.pick_apex(callback)
  if #apex_history == 0 then
    require("execute-salesforce.utils").show_info("No Apex history")
    return
  end
  
  vim.ui.select(apex_history, {
    prompt = "Select Apex code from history:",
    format_item = function(item)
      -- Show first line or up to 80 chars
      local preview = item:match("^[^\n]+") or item
      if #preview > 80 then
        preview = preview:sub(1, 77) .. "..."
      end
      return preview
    end,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

function M.pick_soql(callback)
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
  }, function(choice)
    if choice then
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
  end)
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
  end)
end

return M