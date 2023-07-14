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

M.print = function (item, id, indentation) -- {{{
    local str = ''
    -- build the string of whitespace
    for _=1,indentation do
        str = str .. ' '
    end

    str = str .. id .. ": "

    -- add the words
    if item.title then
        for _, word in ipairs(item.title) do
            str = str .. word .. ' '
        end
    end

    str = str .. '/ '
    if item.body then
        for _, word in ipairs(item.body) do
            str = str .. word .. ' '
        end
    end

    str = str .. '\n'

    io.write(str)
end -- }}}

M.print_recurse = function (data, indentation, id, level) -- {{{
    -- print the current node
    M.print(data[id], id, indentation * level)

    if not data[id].children then return end

    -- increment recurse counter-this is just for indentation
    level = level + 1
    M.warn("recurse: " .. level)


    for child_id in ipairs(data[id].children) do
        M.print_recurse(data, indentation, child_id, level)
    end
end -- }}}

M.print_all = function (data, indentation) -- {{{
    for item_id in ipairs(data) do
        -- only print top level nodes at the top level
        -- recurse will print the rest
        if not data[item_id].parent then
            M.print_recurse(data, indentation, item_id, 0)
        end
    end
end -- }}}


M.color = {} -- {{{
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

    M.dump_table_of_arrays = function (tbl) -- {{{
        for k,v in pairs(tbl) do
            if type(v) == 'table' then
                print(k .. ": " .. table.concat(v, " "))
            elseif type(v) == 'string' then
                print(k .. ": " .. v)
            end
        end
    end
    -- }}}

    return M
    -- vim:foldmethod=marker
