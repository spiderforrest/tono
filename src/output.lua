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

local config = require("config")

local M = {}

M.color = {} -- {{{

M.color.rgb = function (r, g, b, background, do_not_write) -- {{{

    -- also accept an table
    if type(r) == "table" then
        do_not_write = r.write or r.do_not_write -- programming
        background = r.bg or r.background
        b = r.b or r.blue
        g = r.g or r.green
        r = r.r or r.red
    end

    -- rgb codes are formatted as: "\27[38;2;<r>;<g>;<b>m"-this generates that
    local seq = ''
    seq = seq .. config.format.term_escape_seq

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

    -- set the color-or don't if told not to
    if not do_not_write then return seq end
    io.write(seq)
    -- also return it idk how i'm gonna use these
    return seq
end
-- }}}

M.color.red = function () io.write("\27[31m") end
M.color.orange = function () io.write("\27[33m") end
M.color.reset = function () io.write("\27[0m") end
-- }}}

M.warn = function (body) -- {{{
    M.color.orange()
    io.write(body .. '\n')
    M.color.reset()
end
--}}}

M.err = function (body) -- {{{
    M.color.red()
    io.write(body .. '\n')
    M.color.reset()
    os.exit()
end -- }}}

local function render_field (field) -- {{{
    local str = ''
    for _, word in ipairs(field) do
        str = str .. word .. ' '
    end
    return str
end -- }}}

local function render_fields (item) -- {{{
    local str = ''
    for name, field in pairs(item) do
        str = str .. name .. ": "
        str = str .. render_field(field)
        str = str .. '/ '
    end
    return str
end
-- }}}

M.print_item = function (item, id, level) -- {{{
    local str = ''
    -- calculate indentation
    local whitespace = level * config.format.indentation
    -- build the string of whitespace
    for _=1,whitespace do
        str = str .. ' '
    end

    str = str .. id .. ": "

    str = str .. render_fields(item)

    str = str .. '\n'

    M.color.rgb(80,10,68)

    io.write(str)
    M.color.reset()
end -- }}}

M.print_recurse = function (data, id, level) -- {{{
    -- print the current node
    M.print_item(data[id], id, level)

    if not data[id].children then return end

    -- increment recurse counter-this is just for indentation
    level = level + 1
    M.warn("recurse: " .. level)


    for child_id in ipairs(data[id].children) do
        M.print_recurse(data, child_id, level)
    end
end -- }}}

M.print_all = function (data) -- {{{
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
