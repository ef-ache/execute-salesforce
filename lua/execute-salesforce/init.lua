local M = {}

local apex = require("execute-salesforce.apex")

M.execute_apex = apex.execute_apex

M.execute_soql = apex.execute_soql

return M
