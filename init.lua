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
vim.wo.number = true
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
