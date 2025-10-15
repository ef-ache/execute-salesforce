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
  
  -- Build command with pipe to get logs
  local base_cmd
  if cli == "sf" then
    base_cmd = cli .. " apex run --file " .. tmpfile
  else
    base_cmd = cli .. " force:apex:execute --file " .. tmpfile
  end
  local cmd = utils.build_command(base_cmd, config)

  -- Add log retrieval command (get last log after execution)
  local log_cmd
  if cli == "sf" then
    log_cmd = cli .. " apex get log --number 1"
  else
    log_cmd = cli .. " force:apex:log:get --number 1"
  end
  log_cmd = utils.build_command(log_cmd, config)

  -- Combine: execute then get log
  cmd = cmd .. " && " .. log_cmd
  
  -- Execute asynchronously
  utils.start_spinner("Executing Apex code...")

  local stdout_data = {}
  local stderr_data = {}

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      utils.stop_spinner()
      os.remove(tmpfile)

      local stdout_result = table.concat(stdout_data, "\n")
      local stderr_result = table.concat(stderr_data, "\n")

      -- Filter out CLI update warnings from stderr
      stderr_result = stderr_result:gsub("Warning:.-cli update available[^\n]*\n?", "")
      stderr_result = stderr_result:gsub("›%s+Warning:[^\n]*\n?", "")
      stderr_result = stderr_result:gsub("^%s+", ""):gsub("%s+$", "")

      if exit_code ~= 0 then
        -- Show error logs in buffer
        local error_output = "=== Apex Execution Failed (exit code: " .. exit_code .. ") ===\n\n"

        if stderr_result ~= "" then
          error_output = error_output .. "STDERR:\n" .. stderr_result .. "\n\n"
        end

        if stdout_result ~= "" then
          error_output = error_output .. "STDOUT:\n" .. stdout_result
        end

        vim.schedule(function()
          utils.show_result(error_output, config)
        end)
      elseif stdout_result ~= "" then
        -- Show successful result
        vim.schedule(function()
          utils.show_result(stdout_result, config)
        end)
      end
    end,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(stdout_data, line)
        end
      end
    end,
    on_stderr = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(stderr_data, line)
        end
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end

return M