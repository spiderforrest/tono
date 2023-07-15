-- local dote = require('config_lib')

-- config is a module, configure by populating it with lookup tables, variables, functions
local M = { warn = {}, format = {} }

-- data file location
-- M.data_file_location = os.getenv("HOME").."/.config/dote/data.json"
M.datafile_path = "./data.json"

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

-- the escape sequence for setting colors
M.format.term_escape_seq = "\27["

-- for printing the tree, how much whitespace
M.format.indentation = 4

-- whitelist or blacklist what fields show by default
-- M.format.field_whitelist = {}
M.format.field_blacklist = {}

return M
