require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.colorscheme"
require "user.cmp"
require "user.lsp"

-- ensuer packer is loaded
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_wrapper = ensure_packer()
local packer = require('packer')

packer.startup(function(use)
	use 'wbthomason/packer.nvim' -- Packer manages itself
	use 'neovim/nvim-lspconfig'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp' -- Removed ft = 'lua'
	use 'hrsh7th/cmp-buffer' -- Removed ft = 'lua'
	use 'hrsh7th/cmp-path'  -- Removed ft = 'lua'
	use 'L3MON4D3/LuaSnip'  -- Add LuaSnip plugin
	use 'saadparwaiz1/cmp_luasnip' -- Add cmp_luasnip plugin
	use 'morhetz/gruvbox'
	use "lukas-reineke/indent-blankline.nvim"
	use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' } }
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }

	if packer_wrapper then
		packer.sync()
	end
end)
vim.opt.signcolumn = "yes"
-- vim.o.termguicolors = true
vim.o.relativenumber = true
vim.cmd.colorscheme("gruvbox")
-- Decrease update time
vim.o.updatetime = 250
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Enable break indent
vim.o.breakindent = true
-- Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Telescope
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

-- Add telescope shortcuts
vim.keymap.set('n', '<leader><space>', function() require('telescope.builtin').buffers { sort_lastused = true } end)
vim.keymap.set('n', '<leader>sf', function() require('telescope.builtin').find_files { previewer = false } end)
vim.keymap.set('n', '<leader>sb', function() require('telescope.builtin').current_buffer_fuzzy_find() end)
vim.keymap.set('n', '<leader>sh', function() require('telescope.builtin').help_tags() end)
vim.keymap.set('n', '<leader>st', function() require('telescope.builtin').tags() end)
vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').grep_string() end)
vim.keymap.set('n', '<leader>sp', function() require('telescope.builtin').live_grep() end)
vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').oldfiles() end)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*'
})

-- Add indent guides
require("ibl").setup {
	indent = { char = "|" },
	whitespace = {
		remove_blankline_trail = false,
	}
}

-- Diagnostic settings
vim.diagnostic.config {
	virtual_text = false,
	update_in_insert = true,
}

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist) --have no idea what it is
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setqflist)  -- have no idea what it is
vim.keymap.set('n', '<leader>/', function() vim.cmd("noh") end)

-- Specify how the border looks like
local border = {
	{ '┌', 'FloatBorder' },
	{ '─', 'FloatBorder' },
	{ '┐', 'FloatBorder' },
	{ '│', 'FloatBorder' },
	{ '┘', 'FloatBorder' },
	{ '─', 'FloatBorder' },
	{ '└', 'FloatBorder' },
	{ '│', 'FloatBorder' },
}

-- Add border to the diagnostic popup window
vim.diagnostic.config({
	virtual_text = {
		prefix = '■ ', -- Could be '●', '▎', 'x', '■', , 
	},
	float = { border = border },
})

-- Add the border on hover and on signature help popup window
local handlers = {
	['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
	['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

local on_attach = function(_, bufnr)
	local attach_opts = { silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, attach_opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, attach_opts)
	vim.keymap.set('n', 'K',
	function() vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 } end, attach_opts)
	vim.keymap.set('n', '.', vim.lsp.buf.code_action, attach_opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, attach_opts)
	vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, attach_opts)
	vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, attach_opts)
	vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, attach_opts)
	vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
	attach_opts)
	vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, attach_opts)
	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, attach_opts)
	vim.keymap.set('n', '<leader>kd', function() vim.lsp.buf.format { async = true } end, attach_opts)
	-- vim.keymap.set('n', 'so', require('telescope.builtin').lsp_references, attach_opts)
end

-- nvim-cmp supports additional completion capabilities
local clientCapabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities(clientCapabilities)
local lspconfig = require('lspconfig')

-- Enable the following language servers
local servers = { 'pyright' }
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup {
		handlers = handlers,
		on_attach = on_attach,
		capabilities = capabilities,
	}
end

lspconfig.lua_ls.setup {
	handlers = handlers,
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			completion = {
				callSnippet = 'Replace',
			},
		},
	},
}

local cmp = require('cmp')
local luasnip = require 'luasnip'
require 'cmp_luasnip'
luasnip.config.setup {}

-- Autocommand to load Lua-specific configuration
cmp.setup {
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		[']'] = cmp.mapping.scroll_docs(-2),
		['['] = cmp.mapping.scroll_docs(2),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
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
