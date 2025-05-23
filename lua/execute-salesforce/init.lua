local M = {}

-- Load modules
local apex = require("execute-salesforce.apex")
local soql = require("execute-salesforce.soql")
local config = require("execute-salesforce.config")

-- Export functions
M.execute_apex = apex.execute_apex
M.execute_soql = soql.execute_soql
M.setup = config.setup

return M