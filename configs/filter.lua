local M = {}

-- filter functions return true when the item should be rendered
-- and false when the item should not be.

-- fields are stored internally as they are named, and accessible
-- inside the item table passed into the function. If you create a
-- custom field, it'll be named as you named it and just as accessible.

M.default = function (item)
    if item.type ~= "tag" then return true end
    return false
end

M.all = function (_)
    return true
end

return M
-- vim:foldmethod=marker
