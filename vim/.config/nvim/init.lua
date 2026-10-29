-- ~/.config/nvim/init.lua
-- Requires Neovim >= 0.11 (Ubuntu 26.04 ships 0.11.6).
-- External requirements: git, gopls, fzf, ripgrep, a clipboard tool (wl-clipboard or xclip).

vim.g.mapleader = ","
vim.g.maplocalleader = ","

local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local aug = vim.api.nvim_create_augroup("user", { clear = true })

------------------------------------------------------------------------
-- Options (only what differs from Neovim's already sane defaults)
------------------------------------------------------------------------
local o = vim.opt
o.number = true
o.mouse = "a"
o.clipboard = "unnamedplus"      -- yank/paste use the system clipboard
o.termguicolors = true
o.signcolumn = "yes"             -- avoid text jumping when diagnostics appear
o.updatetime = 250
o.undofile = true                -- persistent undo (stored in ~/.local/state/nvim)
o.exrc = true                    -- per-project .nvim.lua (Neovim asks you to :trust it)
o.winborder = "rounded"          -- border on hover/float windows (0.11+)

-- search
o.ignorecase = true
o.smartcase = true
o.gdefault = true                -- :s/a/b/ is global on the line by default

-- splits
o.splitbelow = true
o.splitright = true
o.diffopt:append("vertical")

-- show tabs / trailing spaces (disabled for Go and C below)
o.list = true
o.listchars = { tab = "▷⋅", trail = "⋅", nbsp = "⋅" }

-- indentation (vim-sleuth auto-detects per file; these are the fallbacks)
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true

-- completion popup: no preselection, fuzzy matching, docs in a side popup
o.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }

-- folds are provided by the LSP (see LspAttach); start with everything open
o.foldlevelstart = 99

vim.cmd.colorscheme("habamax") -- fallback until gruvbox is installed

------------------------------------------------------------------------
-- Keymaps
------------------------------------------------------------------------
map("n", "<space>", "za", { desc = "Toggle fold" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<A-Left>", "<C-o>", { desc = "Jump back" })
map("n", "<A-Right>", "<C-i>", { desc = "Jump forward" })
map("n", "<leader><C-Left>", "<cmd>tabprevious<CR>")
map("n", "<leader><C-Right>", "<cmd>tabnext<CR>")

-- Handy built-ins you no longer need to configure (Neovim 0.11 defaults):
--   K          hover docs          grr  references        gri  implementation
--   grn        rename              gra  code action       grt  type definition
--   gO         document symbols    <C-s> (insert) signature help
--   [d / ]d    prev/next diagnostic, <C-w>d  diagnostic float
--   <C-]> / <C-t>  go to definition / pop back (gopls via tagfunc, replaces ctags)
--   gc / gcc   comment (replaces nerdcommenter)

------------------------------------------------------------------------
-- Filetypes
------------------------------------------------------------------------
vim.filetype.add({
  extension = { vert = "glsl", frag = "glsl", ivy = "r" },
})

autocmd("FileType", {
  group = aug,
  pattern = { "go", "c" },
  callback = function() vim.opt_local.list = false end,
})

autocmd("FileType", {
  group = aug,
  pattern = "gitcommit",
  callback = function() vim.opt_local.textwidth = 72 end,
})

-- Toggle between foo.go and foo_test.go (replaces :GoAlternate)
local function go_alternate()
  local f = vim.api.nvim_buf_get_name(0)
  local alt
  if f:match("_test%.go$") then
    alt = f:gsub("_test%.go$", ".go")
  else
    alt = f:gsub("%.go$", "_test.go")
  end
  vim.cmd.edit(vim.fn.fnameescape(alt))
end

autocmd("FileType", {
  group = aug,
  pattern = "go",
  callback = function(ev)
    map("n", "<leader>o", go_alternate, { buffer = ev.buf, desc = "Go: toggle test file" })
    -- :make runs `go test` and fills the quickfix list
    vim.opt_local.makeprg = "go test"
    vim.opt_local.errorformat = "%\\s%#%f:%l:%c: %m,%\\s%#%f:%l: %m,%-G%.%#"
    map("n", "<leader>r", "<cmd>make! ./...<CR><cmd>cwindow<CR>",
      { buffer = ev.buf, desc = "Go: run all tests" })
  end,
})

------------------------------------------------------------------------
-- Diagnostics
------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  underline = true,
})

------------------------------------------------------------------------
-- LSP: gopls
------------------------------------------------------------------------
-- Install gopls with:  go install golang.org/x/tools/gopls@latest
-- (make sure ~/go/bin is in your PATH)
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,     -- function calls complete with parameter placeholders
      semanticTokens = true,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {                   -- shown when inlay hints are toggled on (<leader>i)
        parameterNames = true,
        assignVariableTypes = true,
        compositeLiteralFields = true,
        rangeVariableTypes = true,
      },
    },
  },
})
vim.lsp.enable("gopls")

-- Letters trigger completion, so it pops up as you type (not only after ".")
local trigger_chars = {}
for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._"):gmatch(".") do
  trigger_chars[#trigger_chars + 1] = c
end

autocmd("LspAttach", {
  group = aug,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    local buf = ev.buf
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- native completion
    if client:supports_method("textDocument/completion") then
      client.server_capabilities.completionProvider.triggerCharacters = trigger_chars
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    -- LSP-based folding
    if client:supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldmethod = "expr"
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
    bmap("n", "<leader>i", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
    end, "Toggle inlay hints")

    -- <Tab>: next completion item, or jump in an active snippet, or a real <Tab>
    map("i", "<Tab>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-n>"
      elseif vim.snippet.active({ direction = 1 }) then
        vim.schedule(function() vim.snippet.jump(1) end)
        return ""
      end
      return "<Tab>"
    end, { buffer = buf, expr = true, desc = "Next completion / snippet jump" })
    map("i", "<S-Tab>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-p>"
      elseif vim.snippet.active({ direction = -1 }) then
        vim.schedule(function() vim.snippet.jump(-1) end)
        return ""
      end
      return "<S-Tab>"
    end, { buffer = buf, expr = true, desc = "Previous completion / snippet jump" })
  end,
})

-- Organize imports + format on save for Go (goimports behaviour, via gopls)
autocmd("BufWritePre", {
  group = aug,
  pattern = "*.go",
  callback = function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })[1]
    if not client then return end
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { "source.organizeImports" } }
    -- if you have to save twice for imports to be applied, raise the timeout
    local res = client:request_sync("textDocument/codeAction", params, 3000, 0)
    for _, action in ipairs(res and res.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
    end
    vim.lsp.buf.format({ async = false, name = "gopls" })
  end,
})

------------------------------------------------------------------------
-- Plugins (lazy.nvim, bootstraps itself on first start)
------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- look
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "gruvbox" } } },

  -- treesitter parsers: syntax highlighting for Go, and the "markdown" parser
  -- that K (hover) needs to render docs. Needs `gcc` and the `tree-sitter` CLI.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "go", "gomod", "gosum", "gowork",
        "markdown", "markdown_inline",
        "lua", "vim", "vimdoc", "query", "bash", "json", "yaml",
      })
      -- start highlighting whenever a parser exists for the filetype
      autocmd("FileType", {
        group = aug,
        callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
      })
    end,
  },

  -- git
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        m("n", "]c", function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
        end, "Next hunk")
        m("n", "[c", function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
        end, "Previous hunk")
        m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        m("n", "<leader>hu", gs.reset_hunk, "Undo (reset) hunk")
        m("n", "<leader>hb", gs.blame_line, "Blame line")
        m({ "o", "x" }, "ih", gs.select_hunk, "Hunk text object")
      end,
    },
  },
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- fuzzy finding (needs the `fzf` and `rg` binaries)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = {},
    keys = {
      { "<leader>f", "<cmd>FzfLua files<CR>", desc = "Files" },
      { "<leader>F", function() require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") }) end,
        desc = "Files next to current file" },
      { "<leader>b", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>m", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>/", "<cmd>FzfLua live_grep<CR>", desc = "Grep" },
      { "<leader>l", "<cmd>FzfLua blines<CR>", desc = "Lines in buffer" },
      { "<leader>t", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>T", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>x", "<cmd>FzfLua diagnostics_document<CR>", desc = "Diagnostics" },
    },
  },

  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    keys = { { "<F2>", "<cmd>NvimTreeToggle<CR>", desc = "File tree" } },
    opts = {},
  },

  -- editing
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "tpope/vim-sleuth",
  "vim-scripts/argtextobj.vim",
  {
    "unblevable/quick-scope",
    init = function() vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" } end,
  },
  {
    "will133/vim-dirdiff",
    cmd = "DirDiff",
    init = function() vim.g.DirDiffExcludes = ".git,.svn,*.pyc,*.exe,*.so,*.o,.*.swp" end,
  },
})
