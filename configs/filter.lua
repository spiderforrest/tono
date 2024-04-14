local M = {}

-- if there's multiple filters, does it whitelist or blacklist items
M.multifilter_whitelist = true

-- filter functions return true when the item should be rendered
-- and false when the item should not be.

-- fields are stored internally as they are named, and accessible
-- inside the item table passed into the function. If you create a
-- custom field, it'll be named as you named it and just as accessible.

-- every filter is just called by name with the text of the arg
-- also your configs and the libs are passed as args 2/3 just in casesies

-- except this one it's called when there's no args to dote
M.default = function (item, _, lib)
    if item.done then return false end
    if item.hide then return false end
    if item.type == "tag" then return false end

    -- check for tag being hidden/done
    local data = lib.store.get()
    if item.tags then
        for _,id in ipairs(item.tags) do
            if data[id].done then return false end
            if data[id].hide then return false end
        end
    end

    return true
end

M.all = function ()
    return true
end

M.top = function (item, ...)
    if #item.parents > 0 then return false end

    return M.default(item, ...)
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
