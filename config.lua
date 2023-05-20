local dote = require('config_lib')

-- commands to use
dote.action_commands = {
    todo = dote.create_note,
    note = dote.create_todo,
    tag = dote.create_tag,
    done = dote.done,
    delete = dote.delete,
    modify = dote.modify,
    output = dote.output,
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

return dote
