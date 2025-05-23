local M = {}
local utils = require("execute-salesforce.utils")

-- Get list of authenticated orgs
function M.list_orgs()
  local config = require('execute-salesforce.config').get()
  local cli = utils.get_cli_command(config)
  
  if not cli then
    utils.show_error("Salesforce CLI not found.")
    return {}
  end
  
  local cmd = cli .. " org list --json"
  if cli == "sf" then
    cmd = "sf org list --json"
  end
  
  local result = vim.fn.system(cmd)
  local ok, decoded = pcall(vim.json.decode, result)
  
  if not ok then
    return {}
  end
  
  local orgs = {}
  if decoded and decoded.result and decoded.result.nonScratchOrgs then
    for _, org in ipairs(decoded.result.nonScratchOrgs) do
      table.insert(orgs, {
        alias = org.alias or org.username,
        username = org.username,
        is_default = org.isDefaultUsername or false
      })
    end
  end
  
  return orgs
end

-- Select org interactively
function M.select_org(callback)
  local orgs = M.list_orgs()
  
  if #orgs == 0 then
    utils.show_error("No Salesforce orgs found. Run 'sf org login web' first.")
    return
  end
  
  local items = {}
  for _, org in ipairs(orgs) do
    local label = org.alias
    if org.is_default then
      label = label .. " (default)"
    end
    table.insert(items, label)
  end
  
  vim.ui.select(items, {
    prompt = "Select Salesforce Org:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx then
      callback(orgs[idx])
    end
  end)
end

-- Execute with specific org
function M.execute_apex_with_org(start_line, end_line)
  M.select_org(function(org)
    local config = require('execute-salesforce.config').get()
    config.target_org = org.username
    require("execute-salesforce.apex").execute_apex(start_line, end_line)
  end)
end

function M.execute_soql_with_org(start_line, end_line)
  M.select_org(function(org)
    local config = require('execute-salesforce.config').get()
    config.target_org = org.username
    require("execute-salesforce.soql").execute_soql(start_line, end_line)
  end)
end

return M