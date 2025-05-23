local M = {}

M.defaults = {
  -- Output format: json, csv, or table
  output_format = "json",
  
  -- Split direction: vertical, horizontal, or float
  split_direction = "vertical",
  
  -- Target org alias (nil uses default)
  target_org = nil,
  
  -- Reuse existing result buffer
  reuse_buffer = true,
  
  -- Buffer name for results
  result_buffer_name = "Salesforce Results",
  
  -- Timeout in milliseconds
  timeout = 30000,
  
  -- Keymaps (set to false to disable)
  keymaps = {
    apex = "<leader>sa",
    soql = "<leader>sq",
    history = "<leader>sh",
    apex_history = "<leader>sah",
    soql_history = "<leader>sqh",
  },
  
  -- Show spinner while executing
  show_spinner = true,
  
  -- Use new 'sf' CLI instead of deprecated 'sfdx'
  use_sf_cli = true,
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  
  -- Set up keymaps if enabled
  if M.options.keymaps then
    -- Visual mode keymaps for execution
    if M.options.keymaps.apex then
      vim.keymap.set("v", M.options.keymaps.apex, ":ExecuteApex<CR>", { desc = "Execute Apex" })
    end
    if M.options.keymaps.soql then
      vim.keymap.set("v", M.options.keymaps.soql, ":ExecuteSoql<CR>", { desc = "Execute SOQL" })
    end
    
    -- Normal mode keymaps for history
    if M.options.keymaps.history then
      vim.keymap.set("n", M.options.keymaps.history, ":ExecuteHistory<CR>", { desc = "Salesforce History" })
    end
    if M.options.keymaps.apex_history then
      vim.keymap.set("n", M.options.keymaps.apex_history, ":ExecuteApexHistory<CR>", { desc = "Apex History" })
    end
    if M.options.keymaps.soql_history then
      vim.keymap.set("n", M.options.keymaps.soql_history, ":ExecuteSoqlHistory<CR>", { desc = "SOQL History" })
    end
  end
  
  -- Confirm setup was called
  vim.notify("Execute Salesforce configured successfully", vim.log.levels.INFO, { title = "Execute Salesforce" })
end

function M.get()
  return M.options
end

return M