------------------------------------------------------------
-- BASIC OPTIONS
------------------------------------------------------------
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

------------------------------------------------------------
-- Disable netrw (we use Telescope instead)
------------------------------------------------------------
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

------------------------------------------------------------
-- KEYMAPS
------------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

------------------------------------------------------------
-- LAZY.NVIM (PLUGIN MANAGER)
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

------------------------------------------------------------
-- TREESITTER
------------------------------------------------------------
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "cpp", "c", "python", "lua", "bash" },
      highlight = { enable = true },
    })
  end
},

------------------------------------------------------------
-- FILE EXPLORER
------------------------------------------------------------

{
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup()
    vim.keymap.set("n", "-", "<CMD>Oil<CR>") -- Press '-' to browse current dir
  end
},

------------------------------------------------------------
-- TELESCOPE (FUZZY SEARCH)
------------------------------------------------------------
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        --------------------------------------------------
        -- SORTING & RANKING
        --------------------------------------------------
        sorting_strategy = "ascending",
        -- selection_strategy = "reset",
        file_sorter = require("telescope.sorters").get_lexicographical_sorter,

        --------------------------------------------------
        -- BETTER SEARCH BEHAVIOR
        --------------------------------------------------
        initial_mode = "insert",
        case_mode = "smart_case",
        path_display = { "truncate" },

        --------------------------------------------------
        -- IGNORE JUNK
        --------------------------------------------------
        file_ignore_patterns = {
          "build/",
          "dist/",
          ".git/",
          "node_modules/",
          "__pycache__/",
          "%.o",
          "%.a",
          "%.out"
        },

        --------------------------------------------------
        -- KEYBINDINGS INSIDE TELESCOPE
        --------------------------------------------------
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Esc>"] = actions.close,
          },
        },
      },

      --------------------------------------------------
      -- PICKER-SPECIFIC ORDERING
      --------------------------------------------------
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          only_sort_text = true,
        },
        buffers = {
          sort_lastused = true,
          previewer = false,
        },
      },
    })

    --------------------------------------------------
    -- KEYMAPS
    --------------------------------------------------
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>fb", builtin.buffers)
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols)
  end
},


------------------------------------------------------------
-- GIT SIGNS
------------------------------------------------------------
{
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup()
  end
},

------------------------------------------------------------
-- LSP (NEOVIM 0.11 NATIVE, NO DEPRECATED API)
------------------------------------------------------------
{
  "williamboman/mason.nvim",
  config = true
},
{
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = { "clangd", "pyright", "lua_ls" }
    })
  end
},
{
  "neovim/nvim-lspconfig", -- kept ONLY for server presets
  config = function()
    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end

    -- ✅ NEW NATIVE API (Neovim 0.11+)
    vim.lsp.config("clangd", {
      on_attach = on_attach
    })

    vim.lsp.config("pyright", {
      on_attach = on_attach
    })

    vim.lsp.config("lua_ls", {
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } }
        }
      }
    })
  end
},

------------------------------------------------------------
-- AUTOCOMPLETION
------------------------------------------------------------
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip"
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true })
      }),
      sources = {
        { name = "nvim_lsp" }
      }
    })
  end
},

------------------------------------------------------------
-- DEBUGGER (DAP)
------------------------------------------------------------
{
  "mfussenegger/nvim-dap",
},
{
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio"
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup()

    dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end

    map("n", "<F5>", dap.continue)
    map("n", "<F10>", dap.step_over)
    map("n", "<F11>", dap.step_into)
    map("n", "<F12>", dap.step_out)
    map("n", "<leader>b", dap.toggle_breakpoint)
  end
},

{
  "theHamsta/nvim-dap-virtual-text",
  dependencies = { "mfussenegger/nvim-dap" },
  config = true
}
})


------------------------------------------------------------
-- PYTHON DEBUGGING (debugpy)
------------------------------------------------------------
local dap = require("dap")

dap.adapters.python = function(cb, config)
  if config.request == "attach" then
    local port = (config.connect or {}).port or 5678
    cb({
      type = "server",
      host = "127.0.0.1",
      port = port,
    })
  else
    cb({
      type = "executable",
      command = "python",
      args = { "-m", "debugpy.adapter" },
    })
  end
end

dap.configurations.python = {
  {
    name = "Launch Python file",
    type = "python",
    request = "launch",
    program = "${file}",
    pythonPath = function()
      -- 1️⃣ Prefer venv if exists
      if vim.fn.executable("python3") == 1 then
        return vim.fn.exepath("python3")
      end
      return "python"
    end,
    console = "integratedTerminal",
    justMyCode = false,
  },
}

