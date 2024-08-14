
-- config is a module, configure dote by populating it with lookup tables, variables, functions
local M = {}

-- {{{ internal config only, delete if you've copied this out:
    -- pull the other files
    M.format = require'dote.configs.format'
    M.warn = require'dote.configs.warn'
    M.theme = require'dote.configs.theme'
    M.filter = require'dote.configs.filter'
    M.action = require'dote.configs.action'


    -- the default configs are part of the project itself, this is just where dote looks first for user configs.
    -- this is the ONLY line you should change of the internal default configs (if you're naughty and messing with those)
    -- if you've copied them out
    M.config_file_location = os.getenv("HOME") .. "/.config/dote/config.lua"
-- }}}

--{{{ if you've copied out, and keep the files split like it is in the internal defaults:
    -- if you know what you're doing you can use dofile or anything but like doing it with require
    -- you'll have to set the package path so require can get them, like:

    --[[ (delete this line to uncomment the whole section below, and make sure you delete the "internal config only" section above)

    -- first, shadow the package path, so we can mess with it and not cause conflicts later on
    local package_tmp = package.path

    -- then, set it to match lua files in the dir your configs are in
    package.path = os.gentenv("HOME") .. "./config/dote/?.lua"

    -- then you can require them
    M.format = require'format'
    M.warn = require'warn'
    M.theme = require'theme'
    M.filter = require'filter'
    M.action = require'action'

    -- then, use the shadowed path to restore package.path
    package.path = package_tmp
-- }}}]]


M.data_file_location = os.getenv("HOME").."/.config/dote/data.json"
M.archive_file_location = os.getenv("HOME").."/.config/dote/archive.json"
M.trash_file_location = os.getenv("HOME").."/.config/dote/trash.json"

-- commands to use (you change the left side, the right is actual function names)
M.action_lookup = {
    todo = "create_todo",
    add = "create_todo",
    note = "create_note",
    tag = "create_tag",
    done = "done",
    delete = "delete",
    modify = "modify",
    edit = "modify",
    print = "print",
    archive = "archive",
    fix = "repair",
    help = "help",

    compact = "compact",
    debug = "debug",
}

-- default command
M.default_action = "print"

-- after you delete, add, etc should it call the default print
M.print_after_change = true

-- symbols that specify the key in key:value pairs
-- (empty string behaves same as undefined, get dropped in title/body)
M.field_lookup = {
    ['$'] = "separator",
    ['+'] = "",
    ['-'] = "done",
    [':'] = "",
    ['_'] = "",
    ['^'] = "children",
    ['/'] = "parents",
    ['%'] = "",
    ['@'] = "tags", -- technically identical to parents
    ['='] = "date",
    ['['] = "",
    [']'] = "",
    ['{'] = "",
    ['}'] = "",
}

-- this is called to sort the list whenever things are removed, etc, controls order of ids
-- a and b are items
M.hard_sort = function(a, b)
    -- so the sort order is just "return true means a go first"
    if b.done and not a.done then -- sort done seperately from not done, all after
        return true
    elseif a.done and not b.done then
        return false
    elseif a.created < b.created then -- and sort both groups by date, this is FIFO
        return true
    else
        return false
    end
end

return M
-- vim:foldmethod=marker
