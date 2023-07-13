
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

M.add_to_field = function(field, word, item) -- {{{
    -- create field if needed
    if not item[field] then
        item[field] = {}
    end
    table.insert(item[field], word)
    return item
end --  }}}


M.tag = function (word, item) -- {{{
    M.add_to_field("tag", word, item)
end
-- }}}

M.target = function (word, item) -- {{{
    M.add_to_field("target", word, item)
end
-- }}}

M.date = function (word) print("date: " .. word) end

M.parent = function (word, item) -- {{{
    M.add_to_field("parent", word, item)
end
-- }}}

M.child = function (word, item) -- {{{
    M.add_to_field("child", word, item)
end
-- }}}

M.aux_parent = function (word, item) -- {{{
    M.add_to_field("aux_parent", word, item)
end
-- }}}

M.aux_child = function (word, item) -- {{{
    M.add_to_field("aux_child", word, item)
end
-- }}}


return M

-- vim:foldmethod=marker
