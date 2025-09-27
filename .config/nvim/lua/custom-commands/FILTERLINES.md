# filterlines.nvim

Filter the current buffer’s lines with **ripgrep**—fast, flexible, and always-regex—right from Neovim.

* 🔎 Prompt for a regex and keep only matching (or non-matching) lines
* 🧰 Built-in **presets** for TODOs, errors, URLs, etc. (customizable)
* 🧠 Smart case, case-sensitive, or case-insensitive
* 🧪 Choose the ripgrep engine: Rust regex (default) or **PCRE2** (`-P`)
* 🪟 Open results in a split/vsplit/tab/new buffer, or **replace in place**
* 💻 Optional fzf-lua picker for presets (if installed)
* 🚀 Works on the whole buffer or a **visual selection**

---

## Requirements

* **Neovim** 0.9+ (uses `vim.system` when available; falls back gracefully)
* **ripgrep** (`rg`) in `$PATH`

  * If you set `engine = 'pcre2'`, your ripgrep build must support PCRE2 (`rg -P`).

---

## Installation

### lazy.nvim

```lua
{
  "yourname/filterlines.nvim",
  config = function()
    require("custom-commands.filterlines").setup({})
  end,
}
```

### packer.nvim

```lua
use {
  "yourname/filterlines.nvim",
  config = function()
    require("custom-commands.filterlines").setup({})
  end,
}
```

### Plain init.lua (as provided)

```lua
require("custom-commands.filterlines").setup({})
```

---

## Quick start

* `:FilterLines` → prompts for a ripgrep **regex** and shows only matching lines
* Visual mode → select lines, then `:FilterLines` to restrict to the selection
* `:FilterInvert {regex}` → keep **non-matching** lines (uses `rg -v`)
* `:FilterPreset [name|index]` → run a predefined preset (picker shown if no arg)
* `:FilterPresets` → list configured presets in a scratch buffer

Default keymaps (can be disabled; see config):

* Normal/Visual: `<leader>fl` → `:FilterLines`
* Normal/Visual: `<leader>fp` → `:FilterPreset`

> Tip: Add `!` to **replace** the current buffer contents instead of opening a new result buffer (e.g., `:FilterInvert! ERROR`).

---

## Commands

### `:FilterLines [regex]`

* With an argument, runs immediately.
* With no argument, prompts via `vim.ui.input`.
* Honors a visual selection (linewise).
* Opens results according to `config.open` (`'new'` by default).

### `:FilterInvert[!] {regex}`

* Keeps only **non-matching** lines (`rg -v`).
* Accepts a visual range.
* `!` replaces the source buffer instead of opening a new one.

### `:FilterPreset[!] [name|index]`

* With no args: shows a sorted list of presets.

  * If `fzf-lua` is available, uses it; otherwise uses `vim.ui.select`.
* With a number: runs the Nth item in the sorted list.
* With a name: runs that preset.
* `!` replaces the source buffer.

### `:FilterPresets`

* Opens a scratch buffer listing all presets (name, pattern, description).

---

## Configuration

All fields are optional; these are the defaults:

```lua
require("custom-commands.filterlines").setup({
  presets = {
    todo     = { pattern = [[TODO|FIXME|BUG|HACK]], desc = 'Find TODO-like markers', case = 'insensitive' },
    numbers  = { pattern = [[^\s*\d+]],            desc = 'Lines starting with numbers' },
    errors   = { pattern = [[error|fail|exception|traceback]], desc = 'Common error keywords', case = 'insensitive' },
    urls     = { pattern = [[https?://\S+]],       desc = 'HTTP/HTTPS URLs', case = 'insensitive' },
    nonempty = { pattern = [[\S]],                 desc = 'Non-empty lines' },
  },

  case = 'smart',            -- 'sensitive' | 'insensitive' | 'smart'
  engine = 'rust',           -- 'rust' (default) or 'pcre2' (adds -P)
  ripgrep_path = 'rg',       -- path to ripgrep
  rg_args = {},              -- extra args, e.g. { '--max-columns', '200' }
  open = 'new',              -- 'split' | 'vsplit' | 'tab' | 'new' | 'replace'
  header = true,             -- insert a header line in result buffers (except replace)
  map_defaults = true,       -- install <leader>fl and <leader>fp
})
```

### Notes

* **Presets merging**: If you pass `presets` in `setup`, they **replace** the built-ins (not deep-merged). Everything else deep-merges into defaults.
* **Per-preset case**: A preset can override case mode (`'sensitive'|'insensitive'|'smart'`).
* **Engines**:

  * `'rust'` uses ripgrep’s default Rust regex engine (fast, no backtracking).
  * `'pcre2'` enables `-P` (lookarounds, backreferences, etc.). Requires an rg build with PCRE2.
* **Result buffers**:

  * Scratch-style (`buftype=nofile`, `bufhidden=wipe`, no swap).
  * Inherit the **filetype** of the source buffer for syntax/highlights.
  * Named like `filter://rg/<title>`; includes a timestamp header if `header = true`.
* **Ranges**:

  * Visual selection is detected automatically for `:FilterLines` and respected for other commands via `:help :range` (`:'<,'>FilterInvert /foo/`).

---

## Examples

### Keep only log lines with “ERROR” or “WARN”, case-insensitive

```vim
:FilterLines (?i)ERROR|WARN
```

(Or use PCRE2 lookbehind if `engine='pcre2'`.)

### Remove comment lines

```vim
:FilterInvert ^\s*#
```

### Only non-empty lines in the current selection, replace in place

1. Visual select the block
2. `:'<,'>FilterPreset! nonempty`

### Use presets with fzf-lua (if installed)

* `<leader>fp` → fuzzy-pick a preset
* Hit `<CR>` to run it on the whole buffer

---

## Custom presets

```lua
require("custom-commands.filterlines").setup({
  presets = {
    todo     = { pattern = [[TODO|FIXME|BUG|HACK]], desc = 'Todos', case = 'insensitive' },
    pythonfn = { pattern = [[^\s*def\s+\w+\(]], desc = 'Python function defs' },
    jslogs   = { pattern = [[console\.(log|error|warn)\(]], desc = 'JS logs' },
  },
  case = 'smart',
  open = 'split',
  rg_args = { '--max-columns', '200' },
})
```

---

## FAQ

**Q: Does this modify my file on disk?**
A: No—results open in scratch buffers by default. Use `!` (bang) or `open = 'replace'` to replace in place.

**Q: Why do I get “ripgrep failed” errors?**
A: Ensure `rg` is installed and on your `$PATH`. If you use `engine='pcre2'`, make sure your ripgrep supports `-P`. Run `rg -V` to verify.

**Q: What does “smart” case mean?**
A: Matches ripgrep’s `-S`: case-insensitive if the pattern is all lowercase; case-sensitive otherwise.

**Q: Can I pass extra ripgrep flags?**
A: Yes—set `rg_args = { ... }` in `setup()`.

---

## API

This module exposes a single entrypoint:

```lua
require("custom-commands.filterlines").setup(user_config)
```

All other functions are internal.

---

## Troubleshooting

* **No matches shown**: ripgrep exits with code `1` for “no matches”—that’s not an error; you’ll just get an empty result.
* **Windows/Temp files**: The plugin writes the selected lines to a temp file for ripgrep to read, then deletes it. If you see permission issues, check your system temp directory and Neovim permissions.

---
