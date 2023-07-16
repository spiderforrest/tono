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

M.construct_item = function(config) -- {{{
    local new_item = {
        title = {},
        body = {},
    }
    return new_item
end
-- }}}

M.merge_tbl_recurse = function(primary, aux) -- {{{
    -- iterate each
    for k,v in pairs(aux) do
        -- just clobber
        if type(primary[k]) ~= "table" then
            primary[k] = v
        else
            -- if it's a table, just recurse this function
            M.merge_tbl_recurse(primary[k] or {}, aux[k] or {})
        end
    end
    return primary
end -- }}}

M.dump_table_of_arrays = function(tbl) -- {{{
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(k .. ": " .. table.concat(v, " "))
        elseif type(v) == 'string' then
            print(k .. ": " .. v)
        end
    end
end
-- }}}

M.safe_app = function(arr, maybe_str, separator)  -- {{{
    -- we're working with arrays of strings instead of strings here
    -- that's just better in lua so here's a function that appends strings or arrays safely

    if type(maybe_str) == "string" then
        arr[#arr + 1] = maybe_str
    -- allows treating table stuff just like a string, it's nice
    elseif type(maybe_str) == "table" then
        arr[#arr + 1] = table.concat(maybe_str, separator or '')
    end
    return arr
end
-- }}}

M.warn = function(body) -- {{{
    io.write("\27[33m") -- hard code error color strings because it feels right
    io.write(body .. '\n')
    io.write("\27[0m")
end
--}}}

M.err = function(body) -- {{{
    io.write("\27[31m")
    io.write(body .. '\n')
    io.write("\27[0m")
    os.exit()
end -- }}}
return M

-- vim:foldmethod=marker
