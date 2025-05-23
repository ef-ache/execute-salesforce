local M = {}
local utils = require("execute-salesforce.utils")

function M.execute_apex(start_line, end_line)
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
    utils.show_error("No code selected")
    return
  end
  
  -- Add to history
  local code = table.concat(lines, "\n")
  require("execute-salesforce.history").add_apex(code)
  
  -- Create temporary file
  local tmpfile = os.tmpname() .. ".apex"
  local file = io.open(tmpfile, "w")
  if not file then
    utils.show_error("Failed to create temporary file")
    return
  end
  
  file:write(table.concat(lines, "\n"))
  file:close()
  
  -- Build command
  local base_cmd = cli .. " force:apex:execute --file " .. tmpfile
  if cli == "sf" then
    base_cmd = cli .. " apex run --file " .. tmpfile
  end
  local cmd = utils.build_command(base_cmd, config)
  
  -- Execute asynchronously
  utils.start_spinner("Executing Apex code...")
  
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      utils.stop_spinner()
      os.remove(tmpfile)
      
      if exit_code ~= 0 then
        utils.show_error("Apex execution failed with exit code: " .. exit_code)
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
          utils.show_error("Apex execution error: " .. error)
        end)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return M