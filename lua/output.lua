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

M.color = {}                                                  -- {{{

M.rgb = function(maybe_r, maybe_g, maybe_b, background) -- {{{
    -- users don't have to put everything in i guess
    -- ''''users''''
    local r, g, b = maybe_r or 0, maybe_g or 0, maybe_b or 0

    -- also accept an table {{{
    if type(maybe_r) == "table" then
        -- if so you can also set background
        if maybe_r.bg then
            M.rgb(maybe_r.bg, nil, nil, "bg")
        end

        -- deconstruct
        b = maybe_r.b or maybe_r.blue or 0
        g = maybe_r.g or maybe_r.green or 0
        r = maybe_r.r or maybe_r.red or 0
    end -- }}}

    -- rgb codes are formatted as: "\27[38;2;<r>;<g>;<b>m"-this generates that
    local seq = ''
    seq = seq .. c.format.term_escape_seq

    -- default foreground or use background
    if background ~= "fg" and background then
        seq = seq .. "48;2;"
    else
        seq = seq .. "38;2;"
    end

    -- assemble the actual rgb zero padded because ANSI escape codes are a beast
    seq = seq .. string.format("%03d", r) .. ';'
    seq = seq .. string.format("%03d", g) .. ';'
    seq = seq .. string.format("%03d", b) .. 'm'

    -- actually set the color in the term
    io.write(seq)
    -- also return it idk how i'm gonna use these
    return seq
end
-- }}}

-- reset colors to the user defined or the terminal default
M.color.reset = function() return M.rgb(c.format.base_color) end
M.color.clear = function() io.write("\27[0m") end
-- }}}

local function render_field(field) -- {{{
    local str = ''
    for _, word in ipairs(field) do
        str = str .. word .. ' '
    end
    return str
end                                -- }}}

local function render_fields(item) -- {{{
    local str = ''

    -- lua pairs but consistent order
    local fields = {}
    for key in pairs(item) do
        table.insert(fields, key)
    end
    table.sort(fields)

    for _, field in ipairs(fields) do
        str = str .. field .. ": "
        str = str .. render_field(item[field])
        str = str .. '/ '
    end
    return str
end
-- }}}

local function render_fields_smart(item, whitespace) -- {{{
    local content = {}
    if item.title then
        util.safe_app(content, 'Title: ')
        util.safe_app(content, item.title, ' ')
    end

    util.safe_app(content, M.rgb{r=255}, '')
    util.safe_app(content, ' | ')
    util.safe_app(content, M.color.reset(), '')
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

    util.safe_app(content, render_fields_smart(data[id], whitespace))

    util.safe_app(content, '\n')

    M.color.reset()
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
    M.rgb(80, 10, 68)
end -- }}}

return M
-- vim:foldmethod=marker
