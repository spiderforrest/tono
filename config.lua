-- local dote = require('config_lib')

-- config is a module, configure by populating it with lookup tables, variables, functions
local M = { warn = {} }

-- data file location
-- M.data_file_location = os.getenv("HOME").."/.config/dote/data.json"
M.data_file_location = "./data.json"

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
M.warn.unmatched_sym = true
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
