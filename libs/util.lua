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

M.merge_tbl_recurse = function(primary, aux) -- {{{
    for k,v in pairs(primary) do
        -- just clobber
        if type(aux[k]) ~= "table" then
            aux[k] = v
        else
            -- if it's a table, just recurse this function
            M.merge_tbl_recurse(primary[k] or {}, aux[k])
        end
    end
    return aux
end -- }}}

M.dump_table_of_arrays = function(tbl) -- {{{
    if not tbl then return end
    print('dumping table with continuous legnth ' .. tostring(#tbl))
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(k .. ": " .. table.concat(v, "; "))
        elseif type(v) == 'string' then
            print(k .. ": " .. v)
        else
            print(k .. ": " .. tostring(v))
        end
    end
end
-- }}}

M.safe_app = function(arr, maybe_str, separator)  -- {{{
    -- we're working with arrays of strings instead of strings here
    -- that's just better in lua so here's a function that appends strings or arrays safely

    -- allows treating table stuff just like a string, it's nice
    if type(maybe_str) == "table" then
        arr[#arr + 1] = table.concat(maybe_str, separator or '')
    else
        arr[#arr + 1] = tostring(maybe_str)
    end
    return arr
end
-- }}}

M.ensure_present = function(tbl, item) -- {{{
    -- oh sometimes tbl will be part of a bigger table and nil
    if not tbl then tbl = {} end
    -- go thru and check if the thing is in the table
    for _,v in pairs(tbl) do
        if v == item then
            return tbl, false
        end
    end
    -- if not, toss er in!
    table.insert(tbl, item)
    return tbl, true
end -- }}}

M.ensure_not_present = function(tbl, val) -- {{{
    if not tbl then tbl = {} end
    -- go thru and check if the thing is in the table
    for k,v in pairs(tbl) do
        if v == val then
            table.remove(tbl, k)
            return tbl, true
        end
    end
    return tbl, false
end -- }}}

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

M.rgb = function(maybe_r, maybe_g, maybe_b, background) -- {{{
    -- users don't have to put everything in i guess
    -- ''''users''''
    local r, g, b = maybe_r or 0, maybe_g or 0, maybe_b or 0
    local suppress_write, escape_seq = nil, nil
    local seq = {}

    -- also accept an table {{{
    if type(maybe_r) == "table" then
        -- if so you can also set background
        if maybe_r.bg then
            maybe_r.bg.term_escape_seq = maybe_r.term_escape_seq
            maybe_r.bg.suppress_write = maybe_r.suppress_write
            M.safe_app(seq, M.rgb(maybe_r.bg, nil, nil, "bg"))
        end
        escape_seq = maybe_r.term_escape_seq
        suppress_write = maybe_r.suppress_write

        -- deconstruct
        r = maybe_r.r or maybe_r.red or 0
        g = maybe_r.g or maybe_r.green or 0
        b = maybe_r.b or maybe_r.blue or 0
    end -- }}}

    -- {{{ rgb codes are formatted as: "\27[38;2;<r>;<g>;<b>m"-this generates that
    M.safe_app(seq, escape_seq or "\27[")

    -- default foreground or use background
    if background ~= "fg" and background then
        M.safe_app(seq,"48;2;")
    else
        M.safe_app(seq,"38;2;")
    end

    -- assemble the actual rgb zero padded because ANSI escape codes are a beast
    M.safe_app(seq, string.format("%03d", r) .. ';')
    M.safe_app(seq, string.format("%03d", g) .. ';')
    M.safe_app(seq, string.format("%03d", b) .. 'm')

    local str = table.concat(seq, '')
    -- }}}

    -- actually set the color in the term
    if not suppress_write then
        io.write(str)
    end
    -- also return it idk how i'm gonna use these
    return str
end
-- }}}

M.bake_theme = function (colors, escape_seq) -- {{{
    -- this one takes a table of rgb and converts them into actual function calls to set said color
    -- meant to streamline user theming-pass it c.theme and it'll spit out a table with keys
    -- named the same but values of functions that return/set a baked rgb code
    -- so we can just call c.theme.primary() or whatever to set it ;)

    local converted = {}
    for k,v in pairs(colors) do
        -- add the config escape sequence to the table we're passing rgb()
        v.term_escape_seq = escape_seq
        -- and disable spamming output with colorcodes while baking
        v.suppress_write = true

        local colorcode = M.rgb(v)

        -- generate the function
        -- take a bool control if writes on call
        local func = function (write)
            if write == true then
                io.write(colorcode)
                -- or just take and write a string
            elseif write then
                io.write(colorcode)
                io.write(tostring(write))
            end
            return colorcode
        end

        converted[k] = func
    end
    return converted
end
-- }}}

-- store a table of flags so they can be stripped from arg but if this is called again they'll be remembered
local flag_cache = {}
M.get_flag = function (flag) -- {{{
    -- check if the flag's been stored and leave it at that if so
    if flag_cache[flag] then return flag_cache[flag] end

    -- iterate thru args and check for the flag specified
    local value
    for i, v in ipairs(arg) do
        if v == flag then
            if arg[i + 1] == nil then -- if flag passed by itself
                M.err("The flag '" .. flag .. "' requires a path")
            end
            value = arg[i + 1]
            table.remove(arg, i)
            -- removing both the flag and the value specified after it so we remove twice
            table.remove(arg, i)
        end
    end

    flag_cache[flag] = value
    return value
end
-- }}}

M.get_id_by_maybe_title = function (word, data) -- {{{
    -- if not filter then filter = function(_,_) return true end end

    -- if valid id just return
        if data[tonumber(word)] then return tonumber(word) end

        -- check everything for tags with the same name
        for _, item in ipairs(data) do
            -- if item.title and item.title[1] == word and filter(item, data) then
            if item.title and item.title[1] == word  then
                return item.id
            end
        end
        -- rip
        M.err("Search for title " .. tostring(word) .. " failed!")
end

-- }}}

return M
-- vim:foldmethod=marker
