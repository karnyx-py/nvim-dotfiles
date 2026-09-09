-- essential UI settings 
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"

-- bootstrap lazy.nvim 
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blobl:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- plugins
--
--
vim.g.mapleader = " "
vim.g.maplocalleader = " "
--
require ("lazy").setup({
	-- 1. dark shadow theme (vague)
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require ("vague").setup({
				transparent = false,
				style = {
					comments = "italic",
					strings = "none",
					keywords = "bold",
				},
			})
			vim.cmd([[colorscheme vague]])
		end,
	},

	-- 2. monochrome / auto-adapting statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto", -- dynamically adopts vague.nvim colors without warnings
                icons_enabled = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
        },	
	},

	-- 3. side file explorer (ctrl + n to toggle)
	{
		"nvim-tree/nvim-tree.lua", 
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
                hijack_netrw = false,
                hijack_directories = {
                    enable = false,
                },
                filesystem_watchers = {
                    enable = false, -- stops watching background app directories like Firefox
                },
				view = {
                    width = 30,
                    relativenumber = false,
                },
                renderer = {
                    group_empty = true,
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                    },
                },

                filters = {
                    dotfiles = true, -- automatically hides ".[filename]"
                    custom = {
                        "^\\.git$",
                        "^NTUSER",
                        "^ntuser",
                        "^AppData$",
                        "\\.sys$",
                        "\\.dll$"
                    },
                },
			})
			vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true })
		end,
	},

	-- 4. tree-sitter for syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
            local status, configs = pcall(require, "nvim-treesitter.configs")
            if not status then
                return
            end

            require("nvim-treesitter.install").prefer_git = true

            configs.setup({
                ensure_installed = { "c", "cpp", "lua", "markdown", "python", "java" },
                auto_install = false,
                sync_install = false,
                highlight = { enable = true },
            })
        end,
	},

    -- 5. dashboard / home page shortcut plugin
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("alpha").setup(require("alpha.themes.startify").config)
            -- map <leader>H (Space + h) to return to the home dashboard anytime
            vim.keymap.set("n", "<leader>h", ":Alpha<CR>", { silent = true })
        end,
    },

    -- 6. telescope plugin (easier file directory)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find open buffers" })

            -- space + th opens the theme switcher with instant live previuew
            vim.keymap.set("n", "<leader>th", function()
                builtin.colorscheme({ enable_preview = true })
            end, { desc = "Switch Theme (Live Preview)" })
        end,
    },

    -- 7. vs code style minimap
    {
        "Isrothy/neominimap.nvim",
        version = "v3.*.*",
        lazy = false,
        keys = {
            { "<leader>mn", "<cmd>Neominimap toggle<cr>", desc = "Toggle minimap" },
            { "<leader>mo", "<cmd>Neominimap focus<cr>", desc = "Focus minimap" },
        },
        init = function()
            vim.opt.wrap = false
            vim.opt.sidescrolloff = 36
            vim.g.neominimap = {
                auto_enable = true,
            }            
        end,
    },

    -- 8. toggleterm plugin (vs code-style dropdown terminal)
    {
        "akinsho/toggleterm.nvim",
        version = "*", 
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-\>]], -- press ctrl + \ to toggle terminal open/shut
                direction = "horiztonal",
            })
        end,
    },

    --9. flash.nvim (instant jump navigation) 
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
        },
    },

    --10. bufferline (top file tabs) [clickable, numbered file tabs along top edge of the screen]
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                separator_style = "silent",
            },
        },
    },

    --11. mini.surround (manage surrounding characters)
    {
        "echasnovski/mini.surround",
        opts = {},
    },

    --12. todo-comments (project task highlighter)
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    --13. indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "|" },
            scope = { enabled = false }, -- keeps it clean and minimalistic
        },
    },

    --14. luasnip + friendly-snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    --15. mason.nvim + nvim-lspconfig
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim" },
    },



    -- color themes
    { "vague2k/vague.nvim", lazy = false, priority = 1000 },
    { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
    { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
    { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
    { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
    { "navarasu/onedark.nvim", lazy = false, priority = 1000 },



})
