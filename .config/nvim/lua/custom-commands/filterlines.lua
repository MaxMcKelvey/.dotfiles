-- filterlines.lua
-- Filter lines using ripgrep (ALWAYS regex).

local M = {}

---@class FilterLinesPreset
---@field pattern string        -- ripgrep regex (Rust regex or PCRE2 if enabled)
---@field desc? string
---@field invert? boolean
---@field case? 'sensitive'|'insensitive'|'smart'

---@class FilterLinesConfig
---@field presets table<string, FilterLinesPreset>
---@field case 'sensitive'|'insensitive'|'smart'
---@field engine 'rust'|'pcre2'
---@field ripgrep_path string
---@field rg_args string[]
---@field open 'split'|'vsplit'|'tab'|'new'|'replace'
---@field header boolean
---@field map_defaults boolean

M.config = {
    presets = {
        todo     = { pattern = [[TODO|FIXME|BUG|HACK]], desc = 'Find TODO-like markers', case = 'insensitive' },
        numbers  = { pattern = [[^\s*\d+]],            desc = 'Lines starting with numbers' },
        errors   = { pattern = [[error|fail|exception|traceback]], desc = 'Common error keywords', case = 'insensitive' },
        urls     = { pattern = [[https?://\S+]],       desc = 'HTTP/HTTPS URLs', case = 'insensitive' },
        nonempty = { pattern = [[\S]],                 desc = 'Non-empty lines' },
    },
    case = 'smart',           -- 'sensitive' | 'insensitive' | 'smart'
    engine = 'rust',          -- or 'pcre2' (adds -P)
    ripgrep_path = 'rg',
    rg_args = {},             -- e.g. { '--max-columns', '200' }
    open = 'new',
    header = true,
    map_defaults = true,
}

local function tbl_deep_extend(dst, src)
    for k, v in pairs(src or {}) do
        if type(v) == 'table' and type(dst[k]) == 'table' then
            tbl_deep_extend(dst[k], v)
        else
            dst[k] = v
        end
    end
    return dst
end

local function get_lines(buf, srow, erow)
    return vim.api.nvim_buf_get_lines(buf, srow, erow, false)
end

local function put_lines_in_new_buffer(lines, src_buf, title, open)
    open = open or M.config.open
    if open == 'split' then vim.cmd.split()
    elseif open == 'vsplit' then vim.cmd.vsplit()
    elseif open == 'tab' then vim.cmd.tabnew()
    elseif open == 'new' then vim.cmd.enew()
    elseif open == 'replace' then
        vim.api.nvim_buf_set_lines(src_buf, 0, -1, false, lines)
        return src_buf
    else
        vim.cmd.split()
    end

    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false

    if M.config.header and open ~= 'replace' then
        table.insert(lines, 1, string.format('# filterlines (rg): %s (%s)', title or '', os.date('%Y-%m-%d %H:%M:%S')))
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local src_ft = vim.bo[src_buf].filetype
    if src_ft and src_ft ~= '' then vim.bo[buf].filetype = src_ft end
    vim.api.nvim_buf_set_name(buf, title ~= '' and ('filter://rg/' .. title) or 'filter://rg/result')
    return buf
end

local function write_tempfile(lines)
    local tmp = vim.fn.tempname()
    -- ensure trailing newline so last line is read
    vim.fn.writefile(lines, tmp)
    return tmp
end

---@param pattern string
---@param lines string[]
---@param opts { invert?: boolean, case?: 'sensitive'|'insensitive'|'smart' }
---@return string[] matched_lines
local function ripgrep_filter(pattern, lines, opts)
    opts = opts or {}
    local tmpfile = write_tempfile(lines)

    local args = { '--color', 'never', '-n', '--no-heading' }

    -- engine
    if M.config.engine == 'pcre2' then table.insert(args, '-P') end

    -- case
    local casemode = opts.case or M.config.case or 'smart'
    if casemode == 'insensitive' then
        table.insert(args, '-i')
    elseif casemode == 'sensitive' then
        table.insert(args, '-s')
    else
        table.insert(args, '-S') -- smart-case
    end

    if opts.invert then table.insert(args, '-v') end

    -- user extra args
    for _, a in ipairs(M.config.rg_args or {}) do table.insert(args, a) end

    -- pattern & file
    table.insert(args, '-e'); table.insert(args, pattern)
    table.insert(args, tmpfile)

    -- run
    local cmd = { M.config.ripgrep_path }
    vim.list_extend(cmd, args)

    local stdout, code, stderr = '', 0, ''
    if vim.system then
        local res = vim.system(cmd, { text = true }):wait()
        stdout, code, stderr = res.stdout or '', res.code or 0, res.stderr or ''
    else
        stdout = table.concat(vim.fn.systemlist(cmd), '\n')
        code = vim.v.shell_error
    end

    -- rg returns 0 if matches found, 1 if none (not an error)
    if not (code == 0 or code == 1) then
        vim.notify('filterlines: ripgrep failed: ' .. (stderr or ('exit ' .. tostring(code))), vim.log.levels.ERROR)
        pcall(vim.fn.delete, tmpfile)
        return {}
    end

    local out = {}
    for line in (stdout or ''):gmatch('([^\n]+)') do
        local _, _, _file, _lineno, text = line:find('^([^:]+):(%d+):(.*)$')
        table.insert(out, text or line)
    end

    pcall(vim.fn.delete, tmpfile)
    return out
end

---@param opts { pattern: string, invert?: boolean, case?: 'sensitive'|'insensitive'|'smart', bufnr?: integer, srow?: integer, erow?: integer, open?: string, title?: string }
local function filter_lines_rg(opts)
    opts = opts or {}
    local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    local srow = (opts.srow or 1) - 1 -- 1-based to 0-based
    local erow = (opts.erow or vim.api.nvim_buf_line_count(bufnr))
    local src = get_lines(bufnr, srow, erow)
    local matched = ripgrep_filter(opts.pattern, src, { invert = opts.invert, case = opts.case })
    local title = opts.title or (opts.invert and ('not ' .. opts.pattern) or opts.pattern)
    return put_lines_in_new_buffer(matched, bufnr, title, opts.open)
end

-- Presets UI
local function complete_presets()
    local items = {}
    for name, p in pairs(M.config.presets or {}) do
        table.insert(items, (p.desc and p.desc ~= '') and (name .. '\t' .. p.desc) or name)
    end
    table.sort(items)
    return items
end

local function run_preset(name, range, line1, line2, bang)
    local p = M.config.presets[name]
    if not p then
        vim.notify("filterlines: unknown preset '" .. name .. "'", vim.log.levels.ERROR)
        return
    end
    return filter_lines_rg({
        pattern = p.pattern,
        invert  = p.invert,
        case    = p.case or M.config.case,
        srow    = range and line1 or nil,
        erow    = range and line2 or nil,
        open    = bang and 'replace' or M.config.open,
        title   = 'preset:' .. name,
    })
end

local function FilterLines(opts)
    -- set args to nil if opts is nil
    if not opts then opts = { fargs = {} } end
    local args = opts.fargs

    if #args > 1 then
        vim.notify('FilterLines: provide at most one argument (the regex pattern)', vim.log.levels.WARN)
        return
    end

    local range = vim.fn.mode():match('^[Vv\22]') ~= nil
    local srow, erow
    if range then
        local a = vim.fn.getpos('<')[2]; local b = vim.fn.getpos('>')[2]
        srow, erow = math.min(a,b), math.max(a,b)
    end

    -- If input option, use that, else prompt
    if #args == 1 then
        filter_lines_rg({ pattern = opts.fargs[1], srow = srow, erow = erow })
        return
    end

    -- if number of args > 1, error
    if #opts.fargs > 1 then
        vim.notify('FilterLines: provide at most one argument (the regex pattern)', vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = 'Ripgrep regex: ' }, function(input)
        if input and input ~= '' then filter_lines_rg({ pattern = input, srow = srow, erow = erow }) end
    end)
end

local function FilterPreset(opts)
    -- set args to nil if opts is nil
    if not opts then opts = { fargs = {} } end
    local args = opts.fargs

    if #args == 0 then
        local items = {}
        for name, p in pairs(M.config.presets) do
            table.insert(items, string.format('%s\t%s', name, p.desc or p.pattern))
        end
        table.sort(items)
        if pcall(require, 'fzf-lua') then
            require('fzf-lua').fzf_exec(items, {
                prompt = 'filter preset> ',
                actions = {
                    ['default'] = function(sel)
                        local pick = sel[1]; if not pick then return end
                        local nm = pick:match('^(.-)\t') or pick
                        run_preset(nm)
                    end,
                },
            })
        else
            vim.ui.select(items, { prompt = 'filter preset' }, function(choice)
                if not choice then return end
                run_preset(choice:match('^(.-)\t') or choice)
            end)
        end
        return
    end

    -- args = 1 (try to match preset by number if possible, else by name)

    -- check if args[1] is a number
    local num = tonumber(args[1])
    if num then
        local items = {}
        for name, p in pairs(M.config.presets) do
            table.insert(items, string.format('%s\t%s', name, p.desc or p.pattern))
        end
        table.sort(items)
        if num < 1 or num > #items then
            vim.notify('FilterPreset: preset number out of range', vim.log.levels.WARN)
            return
        end
        local pick = items[num]
        if not pick then
            vim.notify('FilterPreset: preset number out of range', vim.log.levels.WARN)
            return
        end
        local nm = pick:match('^(.-)\t') or pick
        run_preset(nm)
        return
    end

    -- else by name
    -- check if preset exists
    if not M.config.presets[args[1]] then
        vim.notify("FilterPreset: unknown preset '" .. args[1] .. "'", vim.log.levels.WARN)
        return
    end
    run_preset(args[1])
end

function M.setup(user)
    -- Pull out presets (handled specially)
    local user_presets = nil
    if user.presets ~= nil then
        user_presets = user.presets
        user.presets = nil
    end

    -- Deep-extend config with user config (except replace presets if provided)
    M.config = tbl_deep_extend(vim.deepcopy(M.config), user or {})

    -- Replace presets if provided
    if user_presets ~= nil then
        M.config.presets = user_presets
    end

    vim.api.nvim_create_user_command('FilterLines', FilterLines, { nargs = '*', bang = true, range = true, desc = 'Filter lines via ripgrep (prompt for pattern)' })

    vim.api.nvim_create_user_command('FilterInvert', function(opts)
        if not opts.args or opts.args == '' then
            vim.notify('FilterInvert: provide a regex pattern', vim.log.levels.WARN); return
        end
        filter_lines_rg({
            pattern = opts.args, invert = true,
            srow = (opts.range > 0) and opts.line1 or nil,
            erow = (opts.range > 0) and opts.line2 or nil,
            open = opts.bang and 'replace' or M.config.open,
        })
    end, { nargs = 1, range = true, bang = true, desc = 'Keep only NON-matching lines (rg -v)' })

    vim.api.nvim_create_user_command('FilterPreset', FilterPreset, { nargs = '*', range = true, bang = true, complete = complete_presets, desc = 'Run a predefined rg filter preset' })

    vim.api.nvim_create_user_command('FilterPresets', function()
        local lines = { '# filterlines presets (ripgrep)' }
        for name, p in pairs(M.config.presets) do
            table.insert(lines, string.format('%-12s  %s  %s', name, p.pattern, p.desc or ''))
        end
        local cur = vim.api.nvim_get_current_buf()
        put_lines_in_new_buffer(lines, cur, 'presets', M.config.open)
    end, { desc = 'List presets' })

    if M.config.map_defaults then
        vim.keymap.set({'n','v'}, '<leader>fl', FilterLines, { desc = 'Filter lines (ripgrep)' })
        vim.keymap.set({'n','v'}, '<leader>fp', FilterPreset, { desc = 'Run a filter preset (ripgrep)' })
    end
end

return M
