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

local c = require("config")
local util = require("util")

local M = {}

local function render_fields(item) -- {{{
    local content = {}
    if item.title then
        util.safe_app(content, 'Title: ')
        util.safe_app(content, item.title, ' ')
    end

    util.safe_app(content, c.theme.accent(), '')
    util.safe_app(content, ' | ')
    util.safe_app(content, c.theme.primary(), '')
    if item.body then
        util.safe_app(content, 'Body: ')
        util.safe_app(content, item.body, ' ')
    end
    return content
end -- }}}

M.print_item = function(data, id, level) -- {{{
    local content = {}

    -- render id {{{
    if c.format.left_align_id then
        -- how many digits are shown?
        local base10_digits = math.floor(#data/10 + 1)

        util.safe_app(content,
            -- pad with printf trix
            string.format('%' .. base10_digits .. "s", id),
            '')
    else
        util.safe_app(content, tostring(id), '')
    end
    util.safe_app(content, ": ") -- }}}

    -- calculate indentation
    local whitespace = level * c.format.indentation
    -- build the string of whitespace
    if whitespace > 0 then
    util.safe_app(content, string.format('%' .. whitespace .. 's', ''))
    end

    util.safe_app(content, render_fields(data[id]))

    util.safe_app(content, '\n')

    c.theme.primary(true)
    io.write(table.concat(content, ''))
end
-- }}}

M.print_recurse = function(data, id, level) -- {{{
    -- print the current node
    M.print_item(data, id, level)

    if not data[id].children then return end

    -- increment recurse counter-this is just for indentation
    level = level + 1
    -- M.warn("recurse: " .. level)


    for child_id in ipairs(data[id].children) do
        M.print_recurse(data, child_id, level)
    end
end                          -- }}}

M.print_all = function(data) -- {{{
    for item_id in ipairs(data) do
        -- only print top level nodes at the top level
        -- recurse will print the rest
        if not data[item_id].parent then
            M.print_recurse(data, item_id, 0)
        end
    end
end -- }}}

return M
-- vim:foldmethod=marker
