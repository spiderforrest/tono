-- {{{ License
 -- Copyright (C) 2023 Spider Forrest & Allie Zhao
 -- contact: dote@spood.org
 --
 -- This program is free software: you can redistribute it and/or modify
 -- it under the terms of the GNU Affero General Public License as published
 -- by the Free Software Foundation, either version 3 of the License, or
 -- (at your option) any later version.
 --
 -- This program is distributed in the hope that it will be useful,
 -- but WITHOUT ANY WARRANTY; without even the implied warranty of
 -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 -- GNU Affero General Public License for more details.
 --
 -- You should have received a copy of the GNU Affero General Public License
 -- along with this program, at /LICENSE. If not, see <https://www.gnu.org/licenses/>.
 -- }}}

local M = {}

M.print = function (data)
    print(data.title)
-- print(data.title .. " / " .. data.body)
end

M.print_recurse = function (data, id, level)
    -- print the current node
    M.print(data[id], level)
    -- increment recurse counter-this is just for indentation
    level = level + 1
    for child_id in ipairs(data[id].children) do
        M.print_recurse(data, child_id, level)
    end
end

M.print_all = function (data)
    for item_id in ipairs(data) do
        M.print_recurse(data, item_id, 0)
    end
end

return M
-- vim:foldmethod=marker
