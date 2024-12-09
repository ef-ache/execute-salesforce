local M = {}
local telescope = require("telescope")

function M.execute_anonymous()
	local code = vim.fn.getreg('"')
	if code == "" then
		print("Aucun code à exécuter.")
		return
	end

	local command = 'sfdx force:apex:execute --apexcode "' .. code .. '"'
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()

	M.show_result(result)
end

function M.show_result(result)
	-- Préparation des données pour l'affichage
	local lines = {}
	for line in result:gmatch("([^\r\n]*)\r?\n?") do
		table.insert(lines, line)
	end

	-- Affichage avec telescope
	telescope.pickers
		.new({}, {
			prompt_title = "Apex Execution Result",
			finder = telescope.finders.new_table({
				results = lines,
			}),
			sorter = telescope.sorters.get_generic_fuzzy_sorter(),
			previewer = telescope.previewers.new_buffer_previewer({
				define_preview = function(self, entry, _status)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { entry.value })
				end,
			}),
		})
		:find()
end

function M.setup()
	vim.api.nvim_create_user_command("ExecuteApex", M.execute_anonymous, { desc = "Execute Apex code" })
end

return M
