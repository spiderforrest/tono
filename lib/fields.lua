
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

M.plain = function (word, context) -- {{{
    if context.past_separator then
        -- add this word to the body
        M.add_to_field("body", word, context)
    else
        M.add_to_field("title", word, context)
    end
end
-- }}}

M.tag = function (word, context) -- {{{
    M.add_to_field("tag", word, context)
end
-- }}}

M.target = function (word, context) -- {{{
    M.add_to_field("target", word, context)
end
-- }}}

M.date = function (word) print("date: " .. word) end

M.parent = function (word, context) -- {{{
    M.add_to_field("parent", word, context)
end
-- }}}

M.child = function (word, context) -- {{{
    M.add_to_field("child", word, context)
end
-- }}}

M.aux_parent = function (word, context) -- {{{
    M.add_to_field("aux_parent", word, context)
end
-- }}}

M.aux_child = function (word, context) -- {{{
    M.add_to_field("aux_child", word, context)
end
-- }}}


return M

-- vim:foldmethod=marker
