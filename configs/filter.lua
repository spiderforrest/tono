local M = {}

-- filter functions return true when the item should be rendered
-- and false when the item should not be.

-- fields are stored internally as they are named, and accessible
-- inside the item table passed into the function. If you create a
-- custom field, it'll be named as you named it and just as accessible.

-- every filter is just called by name with the text of the arg
-- also your configs and the libs are passed as args 2/3 just in casesies

-- except this one it's called when there's no args to dote
M.default = function (item)
    if item.done == true then return false end
    if item.type ~= "tag" then return true end
    return false
end

M.all = function ()
    return true
end

M.tags = function (item)
    if item.done == true then return false end
    -- if item.type == "tag" then return true end
    -- return false
    return true
end

M.todos = function (item)
    if item.done == true then return false end
    if item.type == "todo" then return true end
    return false
end

M.notes = function (item)
    if item.done == true then return false end
    if item.type == "note" then return true end
    return false
end

return M
-- vim:foldmethod=marker
