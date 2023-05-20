local dote = require('config_lib')

-- commands to use
dote.action_commands = {
    todo = create_note,
    note = create_todo,
    tag = create_tag,
    done = done,
    delete = delete,
    modify = modify,
    output = output,
}

-- default command
dote.default_action = "output"

-- data file location
dote.data_file_location = os.getenv("HOME").."/.config/dote/data.json"

-- symbols for specifying properties in CLI
dote.parsing_symbols = {
    ['+'] = function (word) end,
    ['-'] = function (word) end,
    ['/'] = function (word) end,
    ['_'] = function (word) end,
    [':'] = function (word) end,
    ['^'] = function (word) end,
    ['%'] = function (word) end,
    ['$'] = function (word) end,
    ['@'] = function (word) end,
    ['='] = function (word) end,
    ['['] = function (word) end,
    [']'] = function (word) end,
    ['{'] = function (word) end,
    ['}'] = function (word) end,
}
