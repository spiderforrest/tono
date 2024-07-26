local M = {}

-- if there's multiple filters, does it whitelist or blacklist items
M.multifilter_whitelist = true

-- filter functions return true when the item should be rendered
-- and false when the item should not be.

-- fields are stored internally as they are named, and accessible
-- inside the item table passed into the function. If you create a
-- custom field, it'll be named as you named it and just as accessible.

-- every filter is just called by name with the text of the arg
-- your configs, the libs and the current item printing queue are passed
-- as args 2-4 so you can use them
-- the queue is an array of objects, with {id, depth} showing the represented
-- item's id and how deep in recursion it is

-- this one is called when there's no args to dote

M.default = function (item, _, lib, q)
    if item.done then return false end
    if item.hide then return false end
    if item.type == "tag" then return false end
    if item.done then return false end
    if item.hide then return false end

    -- check for direct parent being hidden/done
    local data = lib.store.get()
    for _,id in ipairs(item.parents) do
        if data[id].done then return false end
        if data[id].hide then return false end
    end

    return M.clean(item, _, lib, q)
end

M.all = function ()
    return true
end

-- prevent duplicates rendering all over the place
-- note: this also hides loops entirely, as it can't find an 'entry point' to render one and recurse
M.clean = function (item, _, c, q)
    -- items with no parents pass
    if #item.parents == 0 then return true end

    -- if they have parents, no printing top level
    for  _, v in ipairs(q) do
        if v.id == item.id then
            return false
        end
    end

    return true
end


M.tags = function (item, ...)
    if item.type == "tag" then return true end

    return M.default(item, ...)
end

M.todos = function (item, ...)
    if item.type == "todo" then return true end

    return M.default(item, ...)
end

M.notes = function (item, ...)
    if item.type == "note" then return true end

    return M.default(item, ...)
end

return M
-- vim:foldmethod=marker
