local M = {}

-- Create input buffer for code/query
local function create_input_buffer(type, callback)
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
  
  -- Set filetype based on type
  if type == "apex" then
    vim.api.nvim_set_option_value('filetype', 'apex', { buf = buf })
    vim.api.nvim_buf_set_name(buf, "Quick Apex Execute (press <CR> to run, <Esc> to cancel)")
    -- Add example
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "// Enter your Apex code here",
      "System.debug('Hello World');"
    })
  else
    vim.api.nvim_set_option_value('filetype', 'sql', { buf = buf })
    vim.api.nvim_buf_set_name(buf, "Quick SOQL Execute (press <CR> to run, <Esc> to cancel)")
    -- Add example
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "-- Enter your SOQL query here",
      "SELECT Id, Name FROM Account LIMIT 5"
    })
  end
  
  -- Open in a split
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
  
  -- Set up keymaps
  vim.keymap.set('n', '<CR>', function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    -- Filter out comment lines
    local code_lines = {}
    for _, line in ipairs(lines) do
      if not line:match("^%s*//") and not line:match("^%s*%-%-") and line:match("%S") then
        table.insert(code_lines, line)
      end
    end
    
    if #code_lines > 0 then
      local content = table.concat(code_lines, "\n")
      vim.cmd('close')
      callback(content)
    else
      require("execute-salesforce.utils").show_error("No code/query to execute")
    end
  end, { buffer = buf, desc = "Execute code" })
  
  vim.keymap.set('n', '<Esc>', function()
    vim.cmd('close')
  end, { buffer = buf, desc = "Cancel" })
  
  -- Clear example and position cursor
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {""})
    vim.api.nvim_win_set_cursor(0, {1, 0})
  end)
end

-- Quick execute with type selection
function M.quick_execute()
  vim.ui.select({"Apex", "SOQL"}, {
    prompt = "Select type to execute:",
  }, function(choice)
    if choice == "Apex" then
      create_input_buffer("apex", function(code)
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
    elseif choice == "SOQL" then
      create_input_buffer("soql", function(query)
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
  end)
end

-- Quick Apex execute
function M.quick_apex()
  create_input_buffer("apex", function(code)
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

-- Quick SOQL execute
function M.quick_soql()
  create_input_buffer("soql", function(query)
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