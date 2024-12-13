local utils = require("execute-salesforce.utils")
local M = {}

function M.show_result(result)
	-- Créer un nouveau buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

	-- Ouvrir un split vertical et afficher le buffer
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
end

function M.execute_soql(line1, line2)
	local bufnr = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(bufnr)

	if line1 < 1 or line2 > total_lines then
		print("Erreur : les numéros de ligne sont hors des limites du tampon.")
		return
	end

	line1 = line1 - 1
	line2 = line2 - 1

	if line1 > line2 then
		print("Erreur : line1 doit être inférieur ou égal à line2.")
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, line1, line2 + 1, false)

	if #lines == 0 then
		print("Aucune requête SOQL à exécuter.")
		return
	end

	local query = table.concat(lines, " ")
	local command = 'sfdx force:data:soql:query --query "' .. query .. '"'
	local handle, err = io.popen(command, "r")
	if not handle then
		print("Erreur lors de l'exécution de la commande : " .. tostring(err))
		return
	end
	local result = handle:read("*a")
	handle:close()

	if result then
		utils.show_result(result)
	else
		print("Erreur lors de la lecture du résultat.")
	end
end

return M
