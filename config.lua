-- commands to use
modifier = {
    todo = function () create('todo') end,
    note = function () create('note') end,
    tag = function () create('tag') end,
    done = function () done() end,
    delete = function () delete() end,
    modify = function () modify() end,
    output = function () output() end,
}

-- default command
default_action = "output"

-- data file location
data_file_location = os.getenv("HOME").."/.config/dote/data.json"

-- symbols for specifying properties in CLI
parsing_symbols = {
}
