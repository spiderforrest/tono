-- commands to use
modifier = {
    create = function () create() end,
    done = function () done() end,
    delete = function () delete() end,
    modify = function () modify() end,
    output = function () output() end,
}

-- default command
default_action = "output"

-- data file location
data_file_location = os.getenv("HOME").."/.config/dote/data.json"
