
local M = {}

-- {{{ define parsing functions

M.parse_tag = function (word)
end
M.parse_plain = function (word)
end
M.parse_target = function (word)
end
M.parse_date = function (word)
end
M.parse_parent = function (word)
end
M.parse_child = function (word)
end
M.parse_aux_parent = function (word)
end
M.parse_aux_child = function (word)
end

-- }}}

M.field_parser = function (args, symbol_table)
    for _, word in ipairs(args) do
        local first_char = string.sub(word, 1, 1) -- get the first letter of the arg
        if symbol_table[first_char] then
            -- execute correlated function
            -- parsing_symbols[first_char](word)
            print(word .. ", " .. first_char)
        else
            M.parse_plain(word) -- otherwise just chuck in name/body
        end
    end
end

-- {{{ define action functions
local function create (type, args, symbol_table)
    print("create " .. type)
    M.field_parser(args, symbol_table)
end
M.create_todo = function (args, symbol_table)
    create('todo', args, symbol_table)
end
M.create_note = function (args, symbol_table)
    create('note', args, symbol_table)
end
M.create_tag = function (args, symbol_table)
    create('tag', args, symbol_table)
end
M.done = function ()
    print("done")
end
M.delete = function ()
    print("delete")
end
M.modify = function ()
    print("modify")
end
M.output = function ()
    print("outupt")
end
-- }}}


return M

-- vim:foldmethod=marker
