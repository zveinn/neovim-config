local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)
vim.opt.swapfile = false
vim.opt.background = "dark"
vim.g.mapleader = " "
vim.g.maplocalleader = ' '
vim.wo.number = false
vim.opt.splitright = true

vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.wrap = false
vim.opt.softtabstop = 2
vim.opt.signcolumn = "yes:1"

require("lazy").setup({
	{ 'numToStr/Comment.nvim',          opts = {} },
	{ 'folke/which-key.nvim',           opts = {} },
	{ "EdenEast/nightfox.nvim" },
	{ "nvim-treesitter/nvim-treesitter" },
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons', opt = {} },
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
		},
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'williamboman/mason.nvim', config = true },
			'williamboman/mason-lspconfig.nvim',
			{ 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
			'folke/neodev.nvim',
		},
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	}
})

local nightfox = require("nightfox")
nightfox.setup({
	options = {
		transparent = true
	}
})
nightfox.load()

vim.cmd("colorscheme nightfox")

require('neodev').setup()

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
require("nvim-tree").setup({
	sort_by = "case_sensitive",
	view = {
		width = 30,

	},
	diagnostics = {
		enable = true,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})


require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})


require 'lspconfig'.gopls.setup {}
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.keymap.set('n', '<C-o>', '<C-o>zz')                                  -- TODO: find a way to overwrite the original keymapping
vim.keymap.set('n', '<A-o>', ':w<cr> :!goimports -w % <cr><cr> :bw<cr>') -- Save and close buffer
-- vim.keymap.set('n', '<A-o>', ':w<cr> :bw<cr>')         -- Save and close buffer
vim.keymap.set('n', '<A-C-q>', ':source $MYVIMRC<cr>')                   -- Source config
vim.keymap.set('n', '<A-.>', ':NvimTreeToggle<CR>')                      -- Source config

vim.keymap.set('n', '<S-l>', '<C-w>l')                                   -- Source config
vim.keymap.set('n', '<S-h>', '<C-w>h')                                   -- Source config
vim.keymap.set('n', '<S-j>', '<C-w>j')
vim.keymap.set('n', '<S-k>', '<C-w>k')

vim.keymap.set('n', '<A-j>', '<C-d>')
vim.keymap.set('n', '<A-k>', '<C-u>')


vim.keymap.set({ 'n', 'i' }, '<A-s>', '<esc> :w<cr> :!goimports -w % <cr><cr>') -- Source config
-- vim.keymap.set({ 'n', 'i' }, '<A-s>', '<esc> :w<cr>') -- Source config
--
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
-- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<A-S-o>', function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
		winblend = 20,
		previewer = true,
	})
end, { desc = '[/] Fuzzily search in current buffer' })

--vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<A-S-u>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<A-S-y>', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
-- vim.keymap.set('n', '<A-S-y>', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<A-S-p>', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
--vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })
--
-- FULL GREP, files, file grep, diagnostics
--
-- SEARCH FILE, Global symbol, file grep, diagnostics

local on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
	nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('<C-p>', vim.lsp.buf.definition, '[G]oto [D]efinition')

	--	requires vim.opt.splitright = true
	nmap('<A-p>', ':vsp<cr> :lua vim.lsp.buf.definition()<CR>', '[G]oto [D]efinition')
	nmap('<A-S-i>', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
	nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

	-- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
	-- nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
	-- nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

	-- See `:help K` for why this keymap
	nmap('Q', vim.lsp.buf.hover, 'Hover Documentation')
	-- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Lesser used LSP functionality
	--	nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
	--	nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
	--	nmap('<leader>wl', function()
	--		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	--	end, '[W]orkspace [L]ist Folders')

	vim.api.nvim_create_augroup('AutoFormatting', {})
	vim.api.nvim_create_autocmd('BufWritePre', {
		pattern = '*.*',
		group = 'AutoFormatting',
		callback = function()
			vim.lsp.buf.format()
		end,
	})

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, { desc = 'Format current buffer with LSP' })
end

local servers = {
	-- clangd = {},
	gopls = {
		gofumpt = true
	},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	html = { filetypes = { 'html', 'twig', 'hbs' } },

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
	ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
	function(server_name)
		require('lspconfig')[server_name].setup {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		}
	end
}

require 'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "javascript" },
	sync_install = false,
	auto_install = true,
	ignore_install = {},
	highlight = {
		enable = true,
		disable = {},
		disable = function(lang, buf)
			local max_filesize = 1000 * 1024 -- 1000 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		additional_vim_regex_highlighting = false,
	},
}

local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}
local s = luasnip.snippet
local t = luasnip.text_node

luasnip.add_snippets("all", {
	s("d", {
		t(
			{ "defer func(){"
			, "\tr := recover()"
			, "\tif r != nil {"
			, "\t\tlog.Println(r, string(debug.Stack()))"
			, "\t}"
			, "}()"
			})
	})
})


cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		-- ['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
}


-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
	defaults = {
		mappings = {
			i = {
				['<C-u>'] = false,
				['<C-d>'] = false,
			},
		},
	},
}


require('Comment').setup({
	toggler = {
		line = '<A-/>',
		block = "g",
	},
	opleader = {
		line = "<A-/>",
		block = "g",
	},
})


-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require('lualine')

-- Color table for highlights
-- stylua: ignore
local colors = {
	bg       = '#202328',
	fg       = '#bbc2cf',
	yellow   = '#ECBE7B',
	cyan     = '#008080',
	darkblue = '#081633',
	green    = '#98be65',
	orange   = '#FF8800',
	violet   = '#a9a1e1',
	magenta  = '#c678dd',
	blue     = '#51afef',
	red      = '#ec5f67',
}

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand('%:p:h')
		local gitdir = vim.fn.finddir('.git', filepath .. ';')
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}

-- Config
local config = {
	options = {
		-- Disable sections and component separators
		component_separators = '',
		section_separators = '',
		theme = {
			-- We are going to use lualine_c an lualine_x as left and
			-- right section. Both are highlighted by c theme .  So we
			-- are just setting default looks o statusline
			normal = { c = { fg = colors.fg, bg = colors.bg } },
			inactive = { c = { fg = colors.fg, bg = colors.bg } },
		},
	},
	sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		-- These will be filled later
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
	table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
	table.insert(config.sections.lualine_x, component)
end

ins_left { 'location' }

ins_left {
	'filename',
	cond = conditions.buffer_not_empty,
	color = { fg = colors.magenta, gui = 'bold' },
}

ins_left {
	function()
		return "--"
	end,
}

ins_left {
	'branch',
	icon = "",
	color = { fg = colors.violet, gui = 'bold' },
	padding = { left = 0, right = 0 }, -- We don't need space before this
}

ins_left {
	'diff',
	-- Is it me or the symbol for modified us really weird
	symbols = { added = 'A ', modified = 'M ', removed = 'R ' },
	diff_color = {
		added = { fg = colors.green },
		modified = { fg = colors.orange },
		removed = { fg = colors.red },
	},
	cond = conditions.hide_in_width,
}

ins_left {
	function()
		return "--"
	end,
}

ins_left {
	'diagnostics',
	sources = { 'nvim_diagnostic' },
	symbols = { error = 'E ', warn = 'W ', info = 'I ', hint = 'H ' },
	diagnostics_color = {
		color_error = { fg = colors.red },
		color_warn = { fg = colors.yellow },
		color_info = { fg = colors.cyan },
	},
}

ins_right {
	-- Lsp server name .
	function()
		local msg = 'No Active Lsp'
		local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
		local clients = vim.lsp.get_active_clients()
		if next(clients) == nil then
			return msg
		end
		for _, client in ipairs(clients) do
			local filetypes = client.config.filetypes
			if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
				return client.name
			end
		end
		return msg
	end,
	color = { fg = '#ffffff', gui = 'bold' },
}

ins_right {
	'o:encoding',      -- option component same as &encoding in viml
	fmt = string.upper, -- I'm not sure why it's upper case either ;)
	cond = conditions.hide_in_width,
	color = { fg = colors.green, gui = 'bold' },
}

ins_right {
	'fileformat',
	fmt = string.upper,
	icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
	color = { fg = colors.green, gui = 'bold' },
}


-- Now don't forget to initialize lualine
lualine.setup(config)
