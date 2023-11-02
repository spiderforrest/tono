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

local store = require("store")
local output = require("output")
local fields = require("fields")
local util = require("util")
local c = require("config")

local M = {}

local function create (type)  -- {{{
    local data = store.load()

    local item = {} -- create new item
    item.type = type
    item.created = os.time()

    item.id = #data + 1
    data[#data + 1] = item
    -- hand it off to get it populated
    fields.process_all(data, #data)

    store.save(data)
end

-- lazily dispatch these
M.create_todo = function() create('todo') end
M.create_note = function() create('note') end
M.create_tag = function() create('tag') end
-- }}}

M.done = function()  -- {{{
    local id = tonumber(arg[1])
    local data = store.load()

    c.theme.primary("Completed ")
    c.theme.ternary(table.concat(data[id].title, ' '))
    io.write('\n')

    data[id].done = true
    store.save(data)
end
-- }}}

M.delete = function()  -- {{{
    local id = tonumber(arg[1])
    local data = store.load()
    c.theme.primary("Trashing ")
    c.theme.ternary(table.concat(data[id].title, ' '))
    io.write('\n')

    local trash = store.load(c.trash_file_location)
    table.insert(trash, data[id])
    store.save(trash, c.trash_file_location)

    table.remove(data, id)
    -- we MUST fix the table every time we remove something; splitting the array would be bad in like six ways
    M.repair(data)
    store.save(data)
end
-- }}}

M.modify = function()  -- {{{
    local data = store.load()
    -- non interactive
    if arg[2] then
        -- pull the target and field
        local id = tonumber(arg[1])
        table.remove(arg, 1)
        local field = arg[1]
        table.remove(arg, 1)

        -- strings are arrays internally so just dump what's left of arg in
        data[id][field] = { table.unpack(arg) }

        store.save(data)
    end
end
-- }}}

M.output = function()  -- {{{
    local filter
    -- get the filter function
    if c.filter[arg[1]] then
        filter = c.filter[arg[1]]
        table.remove(arg, 1) -- strip the action
    else
        filter = c.filter.default
    end

    local data = store.load()
    if data[tonumber(arg[1])] then
        -- if flagged or configs say to recurse
        if arg[2] == 'recurse' or (c.format.single_item_recurse and not arg[2]) then
            output.print_recurse(data, tonumber(arg[1]), 0, filter)
        else
            output.print_item(data, tonumber(arg[1]), 0)
        end
    else
        output.print_all(data, filter)
    end
    store.load()
end
-- }}}

M.archive = function() -- {{{
    local data = store.load()
    c.theme.primary("Where do you want to archive to? (")
    c.theme.ternary(c.archive_file_location)
    c.theme.primary("): ")
    local path = io.read()
    if path == '' then path = c.archive_file_location end

    c.theme.primary("Enter a range to move to archive, starting id (")
    c.theme.ternary(1)
    c.theme.primary("): ")
    local start_range = tonumber(io.read()) or 1

    c.theme.primary("Ending id (")
    c.theme.ternary(#data - 10)
    c.theme.primary("): ")
    local end_range = tonumber(io.read()) or #data - 10

    local archive = store.load(path)
    -- merge and cut
    for i = start_range, end_range do
        table.insert(archive, data[i])
        table.remove(data, i)
    end

    store.save(archive, path)
    -- this gotta stay after archive because it is removing data, lowest risk of data loss
    M.repair(data)
    store.save(data)

end
-- }}}

M.repair = function(data) -- {{{
    if not data then data = store.load() end

    -- make a list of the transforms, go through parents/kids/tags/members and change the ids {{{
    c.sort(data)
    -- where it was:where it will be
    local swaps = {}
    for k,item in ipairs(data) do
        swaps[item.id] = k
    end

    -- less repeated code this way
    local id_related_fields = { "parents", "children", "tags", "members" }
    -- for each number \ in each field (that exists) \ in each item, do the swap
    for _,item in ipairs(data) do
        for _,field in ipairs(id_related_fields) do
            if item[field] then
                for k, id in ipairs(item[field]) do -- triple baka
                    item[field][k] = swaps[id]
                end
            end
        end
        -- and then finally update the item's id
        item.id = swaps[item.id]
    end
    -- you know, this section worked first try at 4am
    -- i'm going to bed.
    --}}}

    -- now we can iteratete; handle parents, children {{{
    for id, item in ipairs(data) do
        -- this is gonna get messy ::::/
        if item.children then
            for child in ipairs(item.children) do
                data[child].parents = util.ensure_present(data[child].parents, id)
            end
        end

        if item.parents then
            for parent in ipairs(item.parents) do
                data[parent].children = util.ensure_present(data[parent].children, id)
            end
        end

        if item.tags then -- tags have members instead of kids so tagged things can still be top level
            for tag in ipairs(item.tags) do
                data[tag].members = util.ensure_present(data[tag].members, id)
            end
        end
    end
    -- }}}

    -- after that, we'll go over again, with the tree intact we can handle tags {{{
    for id, item in ipairs(data) do
        if item.type == "tag" and item.members then
            for _,v in ipairs(item.members) do
                util.ensure_present(data[v].tags, id)
            end
        end
    end
    -- }}}

    store.save(data)
end
-- }}}

return M

-- vim:foldmethod=marker
