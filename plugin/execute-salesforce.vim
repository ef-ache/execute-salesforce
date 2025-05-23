" Prevent loading file twice
if exists('g:loaded_execute_salesforce') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

" Define commands
command! -range ExecuteApex lua require("execute-salesforce").execute_apex(<line1>, <line2>)
command! -range ExecuteSoql lua require("execute-salesforce").execute_soql(<line1>, <line2>)
command! -range ExecuteApexOrg lua require("execute-salesforce.org").execute_apex_with_org(<line1>, <line2>)
command! -range ExecuteSoqlOrg lua require("execute-salesforce.org").execute_soql_with_org(<line1>, <line2>)
command! ExecuteApexHistory lua require("execute-salesforce.history").execute_apex_from_history()
command! ExecuteSoqlHistory lua require("execute-salesforce.history").execute_soql_from_history()
command! ExecuteHistory lua require("execute-salesforce.history").execute_from_history()
command! ExecuteClearApexHistory lua require("execute-salesforce.history").clear_apex_history()
command! ExecuteClearSoqlHistory lua require("execute-salesforce.history").clear_soql_history()

" Setup function for users to configure the plugin
command! -nargs=? ExecuteSalesforceSetup lua require("execute-salesforce").setup(<q-args> ~= '' and vim.fn.eval(<q-args>) or {})

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_execute_salesforce = 1