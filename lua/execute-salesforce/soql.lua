local M = {}
local utils = require("execute-salesforce.utils")

-- Escape single quotes in SOQL query
local function escape_query(query)
  return query:gsub("'", "\\'")
end

function M.execute_soql(start_line, end_line)
  local config = require('execute-salesforce.config').get()
  
  -- Check for CLI
  local cli = utils.get_cli_command(config)
  if not cli then
    utils.show_error("Salesforce CLI not found. Please install 'sf' or 'sfdx'.")
    return
  end
  
  -- Get selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then
    utils.show_error("No query selected")
    return
  end
  
  -- Join lines into single query
  local query = table.concat(lines, " "):gsub("^%s+", ""):gsub("%s+$", "")
  if query == "" then
    utils.show_error("Empty query")
    return
  end
  
  -- Add to history
  require("execute-salesforce.history").add_soql(query)
  
  -- Escape query for shell
  query = escape_query(query)
  
  -- Build command
  local base_cmd = cli .. " force:data:soql:query --query \"" .. query .. "\""
  if cli == "sf" then
    base_cmd = cli .. " data query --query \"" .. query .. "\""
  end
  local cmd = utils.build_command(base_cmd, config)
  
  -- Execute asynchronously
  utils.start_spinner("Executing SOQL query...")
  
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      utils.stop_spinner()
      
      if exit_code ~= 0 then
        utils.show_error("SOQL query failed with exit code: " .. exit_code)
      end
    end,
    on_stdout = function(_, data, _)
      local result = table.concat(data, "\n")
      if result ~= "" then
        vim.schedule(function()
          utils.show_result(result, config)
        end)
      end
    end,
    on_stderr = function(_, data, _)
      local error = table.concat(data, "\n")
      if error ~= "" and not error:match("^%s*$") then
        -- Filter out CLI update warnings
        if error:match("Warning:.*cli update available") or error:match("›%s+Warning:") then
          return
        end
        
        vim.schedule(function()
          -- Parse common Salesforce errors
          if error:match("INVALID_FIELD") then
            utils.show_error("Invalid field in query: " .. error)
          elseif error:match("MALFORMED_QUERY") then
            utils.show_error("Malformed SOQL query: " .. error)
          elseif error:match("No active org found") then
            utils.show_error("No Salesforce org connected. Run 'sf org login web' first.")
          else
            utils.show_error("SOQL error: " .. error)
          end
        end)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return M