-- config is a module, configure by populating it with lookup tables, variables, functions
local M = { warn = {}, format = {}, theme = {} }

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
M.format.left_align_id = true

-- whitelist or blacklist what fields show by default
-- M.format.field_whitelist = {}
M.format.field_blacklist = {}

-- set the colorscheme for things without their own color!
M.theme.primary = { g = 255, bg = {} } -- hacker green on black
M.theme.primary = { r=160, g=20, b=140 } -- something tolerable

M.theme.accent = { r=255 }
M.theme.red = { r=255 }
M.theme.green = { g=255 }
M.theme.blue = { b=255 }

return M
