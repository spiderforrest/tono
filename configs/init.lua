-- config is a module, configure by populating it with lookup tables, variables, functions
local M = {}

-- shadow the path while in this file to only pull config files from here only
local package = package
package.path = package.path .. ";./configs/?.lua;"

-- pull the other files
M.format = require('format')
M.warn = require('warn')
M.theme = require('theme')

-- the default configs are part of the project itself, this is just where dote looks first for user configs.
M.config_file_location = os.getenv("HOME") .. "/.config/dote/config.lua"

-- data file location
M.data_file_location = os.getenv("HOME").."/.config/dote/data.json"

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
    ['print'] = "output",
}

-- default command
M.default_action = "output"


-- symbols that specify the key in key:value pairs
-- (empty string behaves same as undefined, get dropped in title/body)
M.field_lookup = {
    ['$'] = "separator",
    ['+'] = "",
    ['-'] = "target",
    ['/'] = "",
    ['_'] = "",
    [':'] = "child",
    ['^^'] = "parent",
    ['%'] = "",
    ['@'] = "tag",
    ['='] = "date",
    ['['] = "new made up field",
    [']'] = "",
    ['{'] = "",
    ['}'] = "",
}

return M
