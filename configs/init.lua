-- config is a module, configure by populating it with lookup tables, variables, functions
local M = {}

-- {{{ default config only
-- shadow the path while in this file to pull config files from here only
local package_tmp = package.path
package.path = "./configs/?.lua"

-- pull the other files
M.format = require('format')
M.warn = require('warn')
M.theme = require('theme')
M.filter = require('filter')
M.action = require('action')

package.path = package_tmp

-- the default configs are part of the project itself, this is just where dote looks first for user configs.
M.config_file_location = os.getenv("HOME") .. "/.config/dote/config.lua"
-- }}}


M.data_file_location = os.getenv("HOME").."/.config/dote/data.json"
M.archive_file_location = os.getenv("HOME").."/.config/dote/archive.json"
M.trash_file_location = os.getenv("HOME").."/.config/dote/trash.json"

-- commands to use (you change the left side, the right is actual function names)
M.action_lookup = {
    ['todo'] = "create_todo",
    ['add'] = "create_todo",
    ['note'] = "create_note",
    ['tag'] = "create_tag",
    ['done'] = "done",
    ['delete'] = "delete",
    ['modify'] = "modify",
    ['edit'] = "modify",
    ['print'] = "print",
    ['archive'] = "archive",
    ['fix'] = "repair",

    ['compact'] = "compact",
}

-- default command
M.default_action = "print"

-- after you delete, add, etc should it print it out
M.print_after_change = true

-- symbols that specify the key in key:value pairs
-- (empty string behaves same as undefined, get dropped in title/body)
M.field_lookup = {
    ['$'] = "separator",
    ['+'] = "",
    ['-'] = "target",
    ['/'] = "",
    ['_'] = "",
    [':'] = "child",
    ['^'] = "parent",
    ['%'] = "",
    ['@'] = "tag",
    ['='] = "date",
    ['['] = "new made up field",
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
