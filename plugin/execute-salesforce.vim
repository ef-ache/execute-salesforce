if exists("g:loaded_executesalesforce")
    finish
endif
let g:loaded_executesalesforce = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/execute-salesforce/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -range ExecuteApex <line1>,<line2>lua require("execute-salesforce").execute_apex(<line1>, <line2>)
command! -range ExecuteSoql <line1>,<line2>lua require("execute-salesforce.soql").execute_soql(<line1>, <line2>)
