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

require("lazy").setup({
  'jose-elias-alvarez/null-ls.nvim',
  'lukas-reineke/lsp-format.nvim',
  {'romgrk/barbar.nvim',
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      animation = true,
      auto_hide = true,
      maximum_padding = 1,
      icons = {
        filetype = { enabled = false },
        button = '×',
        modified = {
          button = ''
        },
        separator = {
          left = '> '
        },
        inactive = {
          separator = {
            left = ''
          }
        },
      }
    }
  },
  'neovim/nvim-lspconfig',
  'kyazdani42/nvim-tree.lua',
  'nvim-treesitter/nvim-treesitter',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-ui-select.nvim',
  'junegunn/vim-easy-align',
  'hail2u/vim-css3-syntax',
  'ap/vim-css-color',
  'isRuslan/vim-es6',
  'NoahTheDuke/vim-just',
  'vim-scripts/fish-syntax',
  'udalov/kotlin-vim',
  'martingms/vipsql',
  'junegunn/goyo.vim',
  'linkinpark342/xonsh-vim',
  'rust-lang/rust.vim',
  'dart-lang/dart-vim-plugin',
  'nvim-lua/plenary.nvim',
  'scalameta/nvim-metals',
  'akinsho/toggleterm.nvim',
  'rebelot/kanagawa.nvim',
  'github/copilot.vim',
  'folke/tokyonight.nvim',
})

-- options for vim.api.nvim_set_keymap
local noremap = { noremap = true, silent = true }

-- enable syntax highlighting
vim.opt.syntax = "on"

-- theme
vim.opt.compatible = false
vim.opt.background = "dark"
vim.cmd.colorscheme("tokyonight")

-- set utf8 as standard encoding and en_US as the standard language
vim.opt.encoding="utf-8"

-- turn TAB into spaces
vim.opt.expandtab = true

-- 1 tab == 4 spaces
vim.opt.shiftwidth = 0 -- match tabstop
vim.opt.tabstop = 4

-- show these characters in place of tabs
vim.opt.list = true
vim.opt.listchars = { tab = "|>" }

-- for airline to work
vim.opt.laststatus = 2

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true


-- vipsql
vim.cmd([[
let g:vipsql_separator_enabled = 1
let g:vipsql_separator = '===================================================================='
vnoremap <leader>ssql :VipsqlSendSelection<CR>
nnoremap <leader>lsql :VipsqlSendCurrentLine<CR>
nnoremap <leader>fsql :VipsqlSendBuffer<CR>
nnoremap <leader>psql :VipsqlShell<CR>
]])

-- don't let the cursor be at the top or at the bottom
vim.opt.scrolloff = 10

-- remove autoindent, autocomment, autobizarrethings
vim.opt.autoindent = false
vim.opt.smarttab = false
vim.cmd([[
filetype plugin off
filetype indent off
]])

-- ESC removes the highlighted matches that bother me after I search something with /
vim.api.nvim_set_keymap('n', '<esc>', ':noh<return><esc>', noremap)

-- U reruns the syntax highlighting to unfuck my screen, as per https://vi.stackexchange.com/questions/2172/why-i-am-losing-syntax-highlighting-when-folding-code-within-a-script-tag
vim.api.nvim_set_keymap('n', 'U', ':syntax sync fromstart<cr>:redraw!<cr>', noremap)

-- markdown tables
vim.cmd([[
au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
]])

vim.opt.termguicolors = true
vim.opt.mouse = 'a'

-- null-ls (linters and formatters)
local null_ls = require("null-ls")

null_ls.setup {
  diagnostics_format = "[#{c}] #{m} (#{s})",
  sources = {
    null_ls.builtins.formatting.trim_whitespace,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.scalafmt,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.eslint,
    null_ls.builtins.formatting.prettier
      .with({
        extra_filetypes = { "svelte" }
      }),
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.fish,
    null_ls.builtins.formatting.dart_format,
    null_ls.builtins.formatting.rustfmt.with({
      extra_args = function(params)
        local Path = require("plenary.path")
        local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")
        if cargo_toml:exists() and cargo_toml:is_file() then
            for _, line in ipairs(cargo_toml:readlines()) do
                local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
                if edition then
                    return { "--edition=" .. edition }
                end
            end
        end
        -- default edition when we don't find `Cargo.toml` or the `edition` in it.
        return { "--edition=2021" }
      end,
    }),
  },
  on_attach = require("lsp-format").on_attach
}

require("lsp-format").setup {}

-- nvim-treesitter
require("nvim-treesitter.configs").setup({
  -- playground = { enable = true },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { "BufWrite", "CursorHold" },
  },
  ensure_installed = { "scala", "javascript", "go", "rust" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
})

-- lspconfig stuff
local lspconfig = require('lspconfig')

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', noremap)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', noremap)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
-- see also the telescope settings as some of the lsp stuff will be done on telescope

-- Use a loop to conveniently call 'setup' on multiple servers
local custom_opts = {
  tsserver = {
    root_dir = lspconfig.util.root_pattern('tsconfig.json')
  },
  kotlin_language_server = {
    root_dir = lspconfig.util.root_pattern('build.gradle')
  }
}
for _, lsp in pairs({
  'gopls',
  'clangd',
  'flow',
  'jedi_language_server',
  'tsserver',
  'svelte',
  'rust_analyzer',
  'kotlin_language_server',
  'dartls'
}) do
  local opts = {}
  local custom = custom_opts[lsp] or {}
  for k, v in pairs(custom) do
    opts[k] = v
  end
  lspconfig[lsp].setup(opts)
end

-- nvim-metals
metals_config = require("metals").bare_config()
metals_config.settings = {
  serverVersion = "latest.snapshot",
  -- useGlobalExecutable = true,
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl", "android", "androidx" },
  showInferredType = true,
  useGlobalExecutable = false,
  superMethodLensesEnabled = true,
  showImplicitConversionsAndClasses = true,
}
metals_config.init_options.statusBarProvider = "on"
vim.cmd([[augroup lsp]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType scala setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
vim.cmd([[autocmd FileType java,scala,sbt lua require("metals").initialize_or_attach(metals_config)]])
vim.cmd([[augroup end]])

-- status line copied from https://github.com/ckipp01/dots
vim.opt.statusline = [[%!luaeval('require("statusline").super_custom_status_line()')]]
-- vim.opt.winbar = [[%!luaeval('require("statusline").super_custom_winbar()')]]

-- cmd (autocomplete)
local cmp = require'cmp'
local compare = require'cmp.config.compare'
local cmp_types = require'cmp.types.cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp", priority = 10 },
    { name = "buffer" },
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i'}),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }),
    ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
  },
  sorting = {
    comparators = {
      compare.exact,
      compare.score,
      function (a, b)
        if a:get_kind() == 5 and b:get_kind() == 2 then
          return true
        elseif a:get_kind() == 2 and b:get_kind() == 5 then
          return false
        end
        return nil
      end,
      compare.kind,
      compare.recently_used,
      compare.locality,
      compare.offset,
      compare.sort_text,
      compare.length,
      compare.order
    }
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['gopls'].setup { capabilities = capabilities }
require('lspconfig')['flow'].setup { capabilities = capabilities }

-- telescope setup
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
}
require("telescope").load_extension("ui-select")
-- telescope (find files)
vim.api.nvim_set_keymap('n', '<C-p>', "<cmd>lua require('telescope.builtin').find_files()<CR>", noremap)
vim.api.nvim_set_keymap('n', '<C-a>', "<cmd>lua require('telescope.builtin').live_grep()<CR>", noremap)
vim.api.nvim_set_keymap('n', '<C-n>', "<cmd>lua require('telescope.builtin').buffers()<CR>", noremap)
vim.api.nvim_set_keymap('n', '<C-g>', "<cmd>lua require('telescope.builtin').oldfiles()<CR>", noremap)
-- telescope lsp stuff
vim.api.nvim_set_keymap('n', '<C-s>', "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>", noremap)
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", noremap)
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua require('telescope.builtin').lsp_implementations()<CR>", noremap)
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", noremap)
vim.api.nvim_set_keymap("n", "<C-e>", "<cmd>lua vim.lsp.buf.code_action()<CR>", noremap)

-- toggle-terminal
require("toggleterm").setup({
  -- size can be a number or function which is passed the current terminal
  size = function (term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-\>]],
  shell = '/usr/bin/fish',
})

-- barbar keybindings
-- navigate between tabs
vim.api.nvim_set_keymap('n', 'H', '<Cmd>BufferPrevious<CR>', noremap)
vim.api.nvim_set_keymap('n', 'L', '<Cmd>BufferNext<CR>', noremap)
-- move tab position
vim.api.nvim_set_keymap('n', '<C-h>', '<Cmd>BufferMovePrevious<CR>', noremap)
vim.api.nvim_set_keymap('n', '<C-l>', '<Cmd>BufferMoveNext<CR>', noremap)
-- close buffer and open new terminal window
vim.api.nvim_set_keymap('n', '<C-x>', '<Cmd>BufferClose<CR>', noremap)
vim.api.nvim_set_keymap('n', '<C-b>c', '<Cmd>e term://fish<CR>', noremap)

-- nvim tree
require('nvim-tree').setup()
vim.api.nvim_set_keymap('n', '<C-t>', '<Cmd>NvimTreeOpen<CR>', noremap)

-- this is so we can prevent neovim from opening new neovim windows
-- inside neovim terminals
vim.env.IN_NEOVIM = 'yes'
