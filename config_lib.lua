
local M = {}
-- {{{ define action functions
local function create (type, args)
    print("create " .. type)
    field_parser(args)
end
M.create_todo = function (args)
    create('todo', args)
end
M.create_note = function ()
    create('note', args)
end
M.create_tag = function ()
    create('tag', args)
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

local function field_parser(args)
    for i, word in ipairs(args) do
        local first_char = string.sub(word, 1, 1) -- get the first letter of the arg
        if parsing_symbols[first_char] then
            -- execute correlated function
            -- parsing_symbols[first_char](word)
            print(word .. ", " .. first_char)
        else
            parse_plain(word) -- otherwise just chuck in name/body
        end
    end
end
-- }}}

return M

-- vim:foldmethod=marker
