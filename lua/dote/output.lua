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

local c = require("dote.config")
local util = require("dote.util")
local store = require("dote.store")

local M = {}

M.format_field = function (field, item, content) -- {{{
    -- format the actual field content
    util.safe_app(content, c.theme.primary())

    if c.format.field_type[field] == "date" then
        util.safe_app(content, os.date(c.format.date, item[field]))
        return

    elseif c.format.field_type[field] == "bool" then
        if item[field] then
            util.safe_app(content, c.format.true_string)
        else
            util.safe_app(content, c.format.false_string)
        end
        return

    elseif not c.format.field_type[field] then
        util.safe_app(content, item[field], ' ')
    end

    local data = store.get() -- only get the store if needed idk '''performant'''

    if c.format.field_type[field] == "id" then -- if only one id
        if c.format.deref_show_id then
            util.safe_app(content, item[field])
            util.safe_app(content, c.format.ascii_diagram.after_id)
        end
        util.safe_app(content, data[item[field]].title or "<no title>")

    elseif c.format.field_type[field] == "deref" then -- if array of ids
        for k, id in ipairs(item[field]) do
            if k ~= 1 then util.safe_app(content, c.format.ascii_diagram.list_sep) end

            if c.format.deref_show_id then
                util.safe_app(content, id)
                util.safe_app(content, c.format.ascii_diagram.after_id)
            end
            util.safe_app(content, data[id].title or "<no title>", ' ')
        end
    end
end
-- }}}

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
        util.safe_app(content, c.format.ascii_diagram.field_key_val)

        M.format_field(field, item, content)

        -- format space between fields
        if c.format.line_split_fields then
            if field_list[i+1] then -- prevents putting a trailing one at the end
                util.safe_app(content, '\n')
                -- stinky padding, can't believe that worked i can't count
                util.safe_app(content, string.format('%' .. indent .. 's', ''))
            end
        else
            if field_list[i+1] then
                util.safe_app(content, c.theme.accent())
                util.safe_app(content, c.format.ascii_diagram.inline)
            end
        end
    end
end
-- }}}

local function arrange_fields(item, indent) -- {{{
    local content, rendered, ordered, i = {}, {}, {}, 1 -- lua brain small i no kno what a zee ro is
    -- first go through their fav fields
    for _,field in ipairs(c.format.field_order) do
        -- skip if missing/blacklisted
        if item[field] and item[field] ~= {} and not c.format.blacklist[field] then
            -- do not render empty id lists
            if not (c.format.field_type[field] == "deref" and #item[field] == 0) then
                -- check add it to a list to be rendered in a bit
                ordered[i] = field
                -- track that it's been done
                rendered[field] = true
                i = i + 1
            end
        end

        -- create the tags field in place by reading parents
        if field == "tags" and item.parents then
            local data = store.get()
            item.tags = {}
            for _, parent in ipairs(item.parents) do
                if data[parent].type == "tag" then
                    table.insert(item.tags, parent)
                end
            end
        end
    end

    -- next, we just dump the rest in
    for field in pairs(item) do
        if (not c.format.blacklist[field]) and (not rendered[field]) then
            if not (c.format.field_type[field] == "deref" and #item[field] == 0) then
                ordered[i] = field
                rendered[field] = true
                i = i + 1
            end
        end
    end

    render_fields(content, item, ordered, indent)
    return content
end
-- }}}

M.print_item = function(id, level) -- {{{
    local data = store.get()
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
    util.safe_app(content, c.format.ascii_diagram.after_id) -- }}}

    -- calculate indentation
    local whitespace = level * c.format.indentation
    -- build the string of whitespace
    if whitespace > 0 then
        util.safe_app(content, string.format('%' .. whitespace .. 's', ''))
    end

    util.safe_app(content,
        arrange_fields(data[id], whitespace + base10_digits + 2)
    )

    util.safe_app(content, '\n')

    c.theme.primary(table.concat(content, ''))
end
-- }}}

-- store the current queue here for accessing in other places
M.current_queue = { level = 0, id = 0}
M.queue = function (id, filter) -- {{{
    -- print("queuer called on " .. tostring(id))
    local data = store.get()

    if not filter(data[id], c, require("dote"), M.current_queue) then return M.current_queue end
    -- print(tostring(id) .. " passes filter")

    table.insert(M.current_queue, { id = id, level = M.current_queue.level })

    -- save the item as last entered
    M.current_queue.id = id

    -- now do recursion
    M.current_queue.level = M.current_queue.level + 1
    for _, child_id in ipairs(data[id].children) do
        -- checks to keep recursion finite
        if id ~= child_id and not (c.format.never_duplicate and M.current_queue[child_id]) then
            M.current_queue = M.queue(child_id, filter)
        end
    end
    M.current_queue.level = M.current_queue.level - 1

    return M.current_queue
end

--}}}

return M
-- vim:foldmethod=marker
