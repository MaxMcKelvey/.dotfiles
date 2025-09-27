-- vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- vim.opt.colorcolumn = "80"

-- if xclip is available on the system, use it!
if vim.fn.executable('xclip') == 1 then
    vim.g.clipboard = {
        name = 'xclip',
        copy = {
            ['+'] = {'xclip', '-quiet', '-i', '-selection', 'clipboard'},
            ['*'] = {'xclip', '-quiet', '-i', '-selection', 'primary'},
        },
        paste = {
            ['+'] = {'xclip', '-o', '-selection', 'clipboard'},
            ['*'] = {'xclip', '-o', '-selection', 'primary'},
        },
        cache_enabled = 1,
    }
end

-- Forwarding for copy if using vscode tunneling (y to copy, p to paste from vim buffer, Ctrl+Shift+V to paste from client)
if vim.env.SSH_TTY then
    local osc52 = require('vim.ui.clipboard.osc52')

    local function osc52_and_xclip(reg)
        -- OSC52 copy function for this register
        local osc_copy = osc52.copy(reg)

        return function(lines, _)
            -- 1) Copy via OSC52
            osc_copy(lines)

            -- 2) Also copy via xclip (send the same text)
            local text = table.concat(lines, '\n')
            if reg == '+' then
                -- system clipboard
                vim.fn.system({ 'xclip', '-i', '-selection', 'clipboard' }, text)
            else
                -- primary selection
                vim.fn.system({ 'xclip', '-i', '-selection', 'primary' }, text)
            end
        end
    end

    vim.g.clipboard = {
        name = 'OSC52+xclip',
        copy = {
            ['+'] = osc52_and_xclip('+'),
            ['*'] = osc52_and_xclip('*'),
        },
        paste = {
            ['+'] = { 'xclip', '-o', '-selection', 'clipboard' },
            ['*'] = { 'xclip', '-o', '-selection', 'primary' },
        },
    }
end
