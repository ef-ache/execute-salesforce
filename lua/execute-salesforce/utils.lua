local M = {}

function M.show_result(result)
	-- Créer un nouveau buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

	-- Ouvrir un split vertical et afficher le buffer
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
end

return M
