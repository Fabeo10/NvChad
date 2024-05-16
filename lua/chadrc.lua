-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}
M.ui = {
	theme = "sweetpastel",
	nvdash = {
		load_on_startup = true,

		header = {
			"        Coffe into code      ",
			"        ██    ██    ██       ",
			"      ██      ██  ██         ",
			"      ██    ██    ██         ",
			"        ██  ██      ██       ",
			"        ██    ██    ██       ",
			"                             ",
			"    ████████████████████     ",
			"    ██                ██████ ",
			"    ██                ██  ██ ",
			"    ██                ██  ██ ",
			"    ██                ██████ ",
			"      ██            ██       ",
			"  ████████████████████████   ",
			"  ██                    ██   ",
			"    ████████████████████     ",
		},

		buttons = {
			{ "  Find Files", "Spc f f", "Telescope find_files" },
			{ "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
			{ "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
			{ "  Mappings", "Spc c h", "NvCheatsheet" },
		},
	},

	statusline = {
		theme = "default", -- default/vscode/vscode_colored/minimal
		-- default/round/block/arrow separators work only for default statusline theme
		-- round and block will work for minimal theme only
		separator_style = "default",
		order = {
			"mode",
			"file",
			"git",
			"%=",
			"harpoon",
			"diagnostics",
			"clients",
			"cwd",
			"cursor",
		},
		modules = {
			harpoon = function()
				-- simplified version of this https://github.com/letieu/harpoon-lualine
				local options = {
					icon_open = "{",
					icon_close = "}",
					indicators = { "1", "2", "3", "4" },
					active_indicators = { "[1]", "[2]", "[3]", "[4]" },
					separator = " ",
				}
				local list = require("harpoon"):list()
				local root_dir = list.config:get_root_dir()
				local current_file_path = vim.api.nvim_buf_get_name(0)

				-- how many files should be shown (maxes out at indicators.length)
				local length = math.min(list:length(), #options.indicators)

				-- if there are no files, return the icon
				-- this is a hack to prevent the statusline from breaking
				if length == 0 then
					return options.icon_open .. options.icon_close
				end

				local status = { options.icon_open }
				local get_full_path = function(root, value)
					if vim.loop.os_uname().sysname == "Windows_NT" then
						return root .. "\\" .. value
					end

					return root .. "/" .. value
				end

				-- build the status line with indicators if file is active or not
				for i = 1, length do
					local value = list:get(i).value
					local full_path = get_full_path(root_dir, value)

					if full_path == current_file_path then
						table.insert(status, options.active_indicators[i])
					else
						table.insert(status, options.indicators[i])
					end
				end

				-- use icon as end delimiter as well
				table.insert(status, #status + 1, options.icon_close)

				return table.concat(status, options.separator)
			end,

			clients = function()
				local clients = {}
				local buf = vim.api.nvim_get_current_buf()

				-- Iterate through all the clients for the current buffer
				for _, client in pairs(vim.lsp.get_active_clients({ bufnr = buf })) do
					-- Add the client name to the `clients` table
					table.insert(clients, client.name)
				end

				local conform_ok, conform = pcall(require, "conform")
				if conform_ok then
					local formatters = conform.list_formatters(0)
					for _, formatter in pairs(formatters) do
						table.insert(clients, formatter.name)
					end
				end

				if #clients == 0 then
					return ""
				else
					return (vim.o.columns > 100 and (" %#St_gitIcons#" .. table.concat(clients, ", ") .. " "))
						or "  LSP "
				end
			end,
		},
	},

	-- Disable tabufline
	tabufline = {
		enabled = false,
	},
}

-- read the custom plugins
M.plugins = "plugins"

-- check core.mappings for table structure

return M