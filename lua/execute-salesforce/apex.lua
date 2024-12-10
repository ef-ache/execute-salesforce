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

function M.execute_apex(line1, line2)
	print("starting executing apex")

	local bufnr = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(bufnr) -- nombre total de lignes dans le tampon

	-- Vérifier que les lignes demandées sont valides
	if line1 < 1 or line2 > total_lines then
		print("Erreur : les numéros de ligne sont hors des limites du tampon.")
		return
	end

	-- Ajuster les indices pour Vim (indices de ligne sont basés sur 0, mais line1 et line2 sont probablement 1-based)
	line1 = line1 - 1 -- Convertir line1 de 1-based à 0-based
	line2 = line2 - 1 -- Convertir line2 de 1-based à 0-based

	-- Vérifier que line1 <= line2
	if line1 > line2 then
		print("Erreur : line1 doit être inférieur ou égal à line2.")
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, line1, line2 + 1, false) -- +1 car line2 est inclus dans l'intervalle

	if #lines == 0 then
		print("Aucun code à exécuter.")
		return
	end

	local code = table.concat(lines, "\n")
	local command = 'sfdx force:apex:execute --apexcode "' .. code:gsub('"', '\\"') .. '"'
	local handle, err = io.popen(command, "r")
	if not handle then
		print("Erreur lors de l'exécution de la commande : " .. tostring(err))
		return
	end
	local result = handle:read("*a")
	handle:close()

	if result then
		M.show_result(result)
	else
		print("Erreur lors de la lecture du résultat.")
	end
end
