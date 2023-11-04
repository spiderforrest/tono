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
local store = require("store")

local M = {}

local function render_fields(content, item, field_list, indent) -- {{{
    for i, field in ipairs(field_list) do
        -- the symbol at the start of the field
        if c.format.line_split_fields then
            local sym_key

            if i == 1 then
                if field_list[i+1] then
                    sym_key = "first_line"
                else
                    sym_key = "only_line"
                end
            elseif not field_list[i+1] then
                sym_key = "last_line"
            else
                sym_key = "middle_line"
            end
            util.safe_app(content, c.theme.accent())
            util.safe_app(content, c.format.ascii_diagram[sym_key])
        end

        -- the field name
        util.safe_app(content, c.theme.ternary())
        util.safe_app(content, field)
        util.safe_app(content, c.format.ascii_diagram["field_key_val"])

        -- format the actual field content
        util.safe_app(content, c.theme.primary())
        if c.format.field_type[field] == "date" then
            util.safe_app(content, os.date(c.format.date, item[field]))

        elseif c.format.field_type[field] == "int" then
            util.safe_app(content, tostring(item[field]))


        elseif c.format.field_type[field] == "bool" then
            if item[field] then
                util.safe_app(content, c.format.true_string)
            else
                util.safe_app(content, c.format.false_string)
            end

        else -- strings
            util.safe_app(content, item[field], ' ')
        end

        -- format space between fields
        if c.format.line_split_fields then
            if field_list[i+1] then -- this just strips the newline between them
                util.safe_app(content, '\n')
                -- stinky padding, can't believe that worked i can't count
                util.safe_app(content, string.format('%' .. indent .. 's', ''))
            end
        else
            util.safe_app(content, c.theme.accent())
            util.safe_app(content, c.format.ascii_diagram["inline"])
        end
    end
end
-- }}}

local function sort_fields(item, indent) -- {{{
    local content, rendered, ordered, i = {}, {}, {}, 1 -- lua brain small i no kno what a zee ro is
    -- first go through their fav fields
    for _,v in ipairs(c.format.field_order) do
        -- skip if missing/blacklisted
        if item[v] and item[v] ~= {} and not c.format.blacklist[v] then
            -- add it to a list to be rendered in a bit
            ordered[i] = v
            -- track that it's been done
            rendered[v] = true
            i = i + 1
        end
    end

    -- next, we just dump the rest in
    for k in pairs(item) do
        if (not c.format.blacklist[k]) and (not rendered[k]) then
            ordered[i] = k
            i = i + 1
        end
    end

    render_fields(content, item, ordered, indent)
    return content
end
-- }}}

M.print_item = function(id, level) -- {{{
    local data = store.load()
    local content, base10_digits = {}, 0

    -- render id {{{
    if c.format.left_align_id then
        -- how many digits are shown?
        base10_digits = math.floor(#data/10 + 1)

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

    util.safe_app(content,
        sort_fields(data[id], whitespace + base10_digits + 2)
    )

    util.safe_app(content, '\n')

    c.theme.primary(table.concat(content, ''))
end
-- }}}

M.queue_print = function (queue, id, level) -- {{{
    local data = store.load()

    -- let recursion handle non top level nodes
    if level == 0 and data[id].parents then return queue end

    table.insert(queue, { id = id, level = level })

    -- now do recursion
    level = level + 1
    for _, child_id in ipairs(data[id].children or {}) do
        -- checks to keep recursion finite
        if id ~= child_id and (not queue[child_id]) then
            queue = M.queue_print(queue, child_id, level)
        end
    end
    return queue
end

--}}}

M.print_all = function(filter) -- {{{
    local data = store.load()
    local queue = {}
    if c.format.order_decending then
        for id = #data, 1, -1 do -- mom said we have ipairs at home
            queue = M.queue_print(queue, id, 0)
        end
    else
        for id in ipairs(data) do
            queue = M.queue_print(queue, id, 0)
        end
    end

    for _, entry in ipairs(queue or {}) do
        if filter(data[entry.id], c, require("libs")) then
            M.print_item(entry.id, entry.level)
        end
    end


end
-- }}}

return M
-- vim:foldmethod=marker
