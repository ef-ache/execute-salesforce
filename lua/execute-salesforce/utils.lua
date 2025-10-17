local M = {}

-- Find or create result buffer
local function get_result_buffer(config)
  local result_bufnr = nil
  
  if config.reuse_buffer then
    -- Look for existing buffer with our name
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match(config.result_buffer_name) then
          result_bufnr = bufnr
          break
        end
      end
    end
  end
  
  -- Create new buffer if needed
  if not result_bufnr then
    result_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(result_bufnr, config.result_buffer_name)
  end
  
  -- Make buffer modifiable before clearing content
  vim.api.nvim_set_option_value('modifiable', true, { buf = result_bufnr })
  
  -- Clear existing content
  vim.api.nvim_buf_set_lines(result_bufnr, 0, -1, false, {})
  
  -- Set buffer options
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = result_bufnr })
  vim.api.nvim_set_option_value('bufhidden', config.reuse_buffer and 'hide' or 'wipe', { buf = result_bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = result_bufnr })
  vim.api.nvim_set_option_value('modifiable', true, { buf = result_bufnr })
  
  return result_bufnr
end

-- Open buffer in window
local function open_result_window(bufnr, config)
  local current_win = vim.api.nvim_get_current_win()
  
  -- Check if buffer is already visible
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  
  -- Open new window
  if config.split_direction == "vertical" then
    vim.cmd('vsplit')
  elseif config.split_direction == "horizontal" then
    vim.cmd('split')
  elseif config.split_direction == "float" then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    vim.api.nvim_open_win(bufnr, true, {
      relative = 'editor',
      row = row,
      col = col,
      width = width,
      height = height,
      border = 'rounded',
      title = ' ' .. config.result_buffer_name .. ' ',
      title_pos = 'center',
    })
    return
  end
  
  -- Set buffer in new window
  vim.api.nvim_win_set_buf(0, bufnr)
end

-- Apply syntax highlighting based on content
local function apply_syntax_highlighting(bufnr, content)
  -- Detect JSON
  if content:match('^%s*[{[]') then
    vim.api.nvim_set_option_value('filetype', 'json', { buf = bufnr })
  -- Detect CSV (simple check for comma-separated header)
  elseif content:match('^[^,]+,[^,]+') then
    vim.api.nvim_set_option_value('filetype', 'csv', { buf = bufnr })
  end
end

function M.show_result(result, config)
  config = config or require('execute-salesforce.config').get()
  
  local bufnr = get_result_buffer(config)
  local lines = vim.split(result, '\n')
  
  -- Set content
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Open window
  open_result_window(bufnr, config)
  
  -- Apply syntax highlighting
  apply_syntax_highlighting(bufnr, result)
  
  -- Make buffer non-modifiable after setting content
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
end

-- Check if command exists
function M.command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Get CLI command based on config
function M.get_cli_command(config)
  if config.use_sf_cli and M.command_exists('sf') then
    return 'sf'
  elseif M.command_exists('sfdx') then
    return 'sfdx'
  else
    return nil
  end
end

-- Build command with options
function M.build_command(base_cmd, config)
  local cmd = base_cmd
  
  -- Add target org if specified
  if config.target_org then
    cmd = cmd .. ' --target-org ' .. config.target_org
  end
  
  -- Add output format for SOQL
  if base_cmd:match('soql:query') or base_cmd:match('data query') then
    if config.output_format == 'csv' then
      cmd = cmd .. ' --result-format csv'
    elseif config.output_format == 'table' then
      cmd = cmd .. ' --result-format human'
    else
      cmd = cmd .. ' --result-format json'
    end
  end
  
  return cmd
end

-- Show error message
function M.show_error(message)
  vim.notify(message, vim.log.levels.ERROR, { title = "Salesforce Execute" })
end

-- Show info message
function M.show_info(message)
  vim.notify(message, vim.log.levels.INFO, { title = "Salesforce Execute" })
end

-- Create spinner
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_timer = nil

function M.start_spinner(message)
  if not require('execute-salesforce.config').get().show_spinner then
    return
  end
  
  local frame = 1
  spinner_timer = vim.loop.new_timer()
  spinner_timer:start(0, 100, vim.schedule_wrap(function()
    vim.api.nvim_echo({{ spinner_frames[frame] .. " " .. message, "Normal" }}, false, {})
    frame = frame % #spinner_frames + 1
  end))
end

function M.stop_spinner()
  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
    vim.api.nvim_echo({{ "", "Normal" }}, false, {})
  end
end

return M