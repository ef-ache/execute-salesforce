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
  },
  
  -- Show spinner while executing
  show_spinner = true,
  
  -- Use new 'sf' CLI instead of deprecated 'sfdx'
  use_sf_cli = true,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  
  -- Set up keymaps if enabled
  if M.options.keymaps then
    if M.options.keymaps.apex then
      vim.keymap.set("v", M.options.keymaps.apex, ":ExecuteApex<CR>", { desc = "Execute Apex" })
    end
    if M.options.keymaps.soql then
      vim.keymap.set("v", M.options.keymaps.soql, ":ExecuteSoql<CR>", { desc = "Execute SOQL" })
    end
  end
end

function M.get()
  return M.options
end

return M