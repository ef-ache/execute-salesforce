local M = {}

function M.show_result(result)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	}
	vim.api.nvim_open_win(buf, true, opts)
end

function M.execute_anonymous(line1, line2)
	local bufnr = vim.api.nvim_get_current_buf()

	local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
	if #lines == 0 then
		print("Aucun code à exécuter.")
		return
	end

	local code = table.concat(lines, "\n")

	local command = 'sfdx force:apex:execute --apexcode "' .. code:gsub('"', '\\"') .. '"'
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()

	M.show_result(result)
end

function M.setup()
	vim.api.nvim_create_user_command("ExecuteApex", function(opts)
		M.execute_anonymous(opts.line1, opts.line2)
	end, {
		range = true, -- Autorise l'utilisation de plages
		desc = "Exécute le code Apex sur la plage sélectionnée ou sur une ligne",
	})
end
