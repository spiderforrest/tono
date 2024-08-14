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

local store = require("dote.store")
local output = require("dote.output")
local fields = require("dote.fields")
local util = require("dote.util")
local c = require("dote.config")

local M = {}

local function create (type)  -- {{{
    local data = store.get()
    -- create new item
    local item = {
        type = type,
        created = os.time(),
        id = #data + 1,
        parents = {},
        children = {}
    }

    table.insert(data, item)
    -- hand it off to get it populated
    fields.process_all(#data)

    store.save(data)

    if c.print_after_change then M.print(#data) end
end

-- lazily dispatch these
M.create_todo = function() create('todo') end
M.create_note = function() create('note') end
M.create_tag = function() create('tag') end
-- }}}

M.done = function()  -- {{{
    local data = store.get()
    local id = util.get_id_by_maybe_title(arg[1], data)

    c.theme.primary("Completed ")
    c.theme.ternary(data[id].title)
    io.write('\n')

    data[id].done = true
    store.save(data)

    if c.print_after_change then M.print(true) end
end
-- }}}

M.delete = function()  -- {{{
    local id = tonumber(arg[1])
    local data = store.get()
    if data[id] == 'number' then util.err"Must use numerical id with delete!" end

    c.theme.primary("Trashing ")
    c.theme.ternary(data[id].title or '<no title>')
    io.write('\n')

    -- wipe connections
    for item in ipairs(data[id].parents) do
        data[item].children = util.ensure_not_present(data[item].children, id)
    end
    for item in ipairs(data[id].children) do
        data[item].parents = util.ensure_not_present(data[item].parents, id)
    end

    local trash = store.get(c.trash_file_location)
    table.insert(trash, data[id])
    store.save(trash, c.trash_file_location)

    table.remove(data, id)
    -- we MUST fix the table every time we remove something; splitting the array would be bad in like six ways

    M.repair(data)
    store.save(data)

    if c.print_after_change then M.print(true) end
end
-- }}}

M.modify = function()  -- {{{
    local data = store.get()
    -- find target
    local id = util.get_id_by_maybe_title(arg[1], data)
    table.remove(arg, 1)
    -- non interactive, mabye will write interactive ver later
    if arg[1] then
        -- re-process fields, reseting any that have been modified
        fields.process_all(id, true)

        -- mark er as modifyied
        data[id].updated = os.time()

        store.save(data)
    end

    if c.print_after_change then M.print(id) end
end
-- }}}

M.print = function(override_args)  -- {{{
    local data = store.get()
    local queue = {}
    local multifilter, id

    -- override skips all of the argument parsing-for when you want to call it after you do something else
    -- well there's some jank with the 'recurse' setting but TODO fix
    if override_args then
        multifilter = c.filter.default
        if data[override_args] then
            id = override_args
        else
            id = false
        end
    else

        -- filter {{{
        local filters = {}
        for idx, word in ipairs(arg) do
            if string.find(word, "^%w+$") and c.filter[word] then -- only match alpha words, not numbers/symbols
                table.insert(filters, word)
                -- strip arg
                table.remove(arg, idx)
            end
        end

        -- set the default filter if there's none
        if #filters == 0 then filters[1] = "default" end

        -- bake the multifilter function
        multifilter = function (...)
            for _,filter in ipairs(filters) do
                -- eval the current filter
                local filter_result = c.filter[filter](...)
                -- if it's set to blacklist, return false if any filters return false
                -- if whitelisting, do the same backwards
                if c.filter.multifilter_whitelist == filter_result then return filter_result end
            end
            -- if no matches to the filter white/blacklist mode, return the opposite
            return not c.filter.multifilter_whitelist
        end
        -- }}}

        id = util.get_id_by_maybe_title(arg[1], data, true)
    end

    -- fill queue {{{
    -- handle single item prints, notably, these bypass the filter
    if id then
        -- -- if flagged or configs say to recurse
        if arg[2] == 'recurse' or (c.format.single_item_recurse and not arg[2]) then
            output.queue(id, multifilter)
            -- however the item itself might get filtered -_-
            -- just. fix that
            if not output.current_queue[1] or not output.current_queue[1].id == id then
                table.insert(output.current_queue, 1, { id = id, level = 0 })
            end
        else
            -- just print the item and bail
            output.print_item(id, 0)
            return
        end
    else
        -- for printing the whole list, queue it all
        for i in ipairs(data) do
            output.queue(i, multifilter)
        end
    end
    -- }}}

    -- actually print the queue
    if c.format.order_descending then
        -- mom said we have ipairs at home
        for i = #output.current_queue, 1, -1 do
            output.print_item(output.current_queue[i].id, output.current_queue[i].level)
        end
    else
        for _, entry in ipairs(output.current_queue) do
            output.print_item(entry.id, entry.level)
        end
    end
end
-- }}}

M.archive = function() -- {{{
    util.warn"currently may create random relationships if you archive items that have relationships to items not getting archived! @ me if you want me to fix it, ez just low priority"
    local data = store.get()
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

    local archive = store.get(path)
    -- merge and cut
    for i = start_range, end_range do
        -- TODO: handle relationships here
        table.insert(archive, data[i])
        table.remove(data, i)
    end

    store.save(archive, path)
    -- this gotta stay after archive because it is removing data, lowest risk of data loss
    M.repair(data)
    store.save(data)

    if c.print_after_change then M.print(true) end
end
-- }}}

M.repair = function(data) -- {{{
    if not data then data = store.get() end

    -- make a list of the transforms, go through parents/kids/tags and change the ids {{{
    table.sort(data, c.hard_sort)
    -- where it was:where it will be
    local swaps = {}
    for k,item in ipairs(data) do
        swaps[item.id] = k
    end

    -- less repeated code this way... theoretically.
    local id_related_fields = { "parents", "children" }

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

    -- now we can iteratete; handle parents and children {{{
    -- this is gonna get messy ::::/
    local function fix_relationships()  -- my ex shoulda tried that nyeheheh
        local needs_another_pass = false
        for id, item in ipairs(data) do
            -- correct relationships with parents and kids
            -- note, only does one level, so this whole function gets looped until nothing is changed to recurse
            for k, child in ipairs(item.children) do
                -- check if self reference and remove
                if id == child then
                    table.remove(data[id].children, k)
                else

                    -- put the id in the kids parents table and check if it's already there
                    local tbl, updated = util.ensure_present(data[child].parents, id)
                    data[child].parents = tbl


                    -- save if anything was changed so we can run another pass
                    needs_another_pass = updated or needs_another_pass
                end
            end
            for k, parent in ipairs(item.parents) do
                if id == parent then
                    table.remove(data[id].parents, k)
                else

                    local tbl, updated = util.ensure_present(data[parent].children, id)
                    data[parent].children = tbl


                    needs_another_pass = updated or needs_another_pass
                end
            end

            -- util.dump_table_of_arrays(item)
        end
        -- track if modified
        return needs_another_pass
    end
    -- try it until nothings gets changed, since it only does one level and doesn't recurse
    -- it would recurse if i had thought of (a good way to do) that before writing it
    local i = 0
    while fix_relationships() do
        i = i + 1
        if i > 10000 then
            print(require'json'.stringify(data))
            util.err("issue fixing your data! It will not be changed.")
        end
    end -- 'while not fix relationships do end' these jokes write themselves
    -- }}}


    store.save(data)
end
-- }}}

M.help = function()  -- {{{
    -- output help text detailing flags
    c.theme.accent("Options:\n")
    c.theme.auxilary("   -c [path]\n")
    c.theme.primary("       specify path to config\n")
    c.theme.auxilary("   -d [path]\n")
    c.theme.primary("       specify path to datafile\n\n")

    -- output help text detailing actions, symbols, and usage
    c.theme.accent("Usage: ")
    c.theme.auxilary("dote [action]\n\n")

    -- help section for create/modify commands {{{
    c.theme.primary("Command format for ")
    c.theme.auxilary("dote [todo/note/tag]")
    c.theme.primary(" and ")
    c.theme.auxilary("dote modify\n\n")

    c.theme.auxilary("  dote [action] [name/fields] $ [body/fields]\n\n")

    c.theme.auxilary("   [action]")
    c.theme.primary("   one of the following commands, or user defined commands\n")
    c.theme.auxilary("      todo")
    c.theme.primary("          create a new task\n")
    c.theme.auxilary("      note")
    c.theme.primary("          create a new note\n")
    c.theme.auxilary("      tag")
    c.theme.primary("           create a new tag\n")
    c.theme.auxilary("      modify")
    c.theme.primary("        modify an existing entity\n")

    c.theme.auxilary("   [name]")
    c.theme.primary("     Any number of arguments representing 'name' property of entity, concatenated together.\n")
    c.theme.auxilary("   $")
    c.theme.primary("          Literal dollar sign character, surrounded by spaces. Defines boundary between name and body.\n")
    c.theme.auxilary("   [body]")
    c.theme.primary("     Any number of arguments representing 'body' property, concatenated together.\n")
    c.theme.auxilary("   [fields]")
    c.theme.primary("   Any single argument starting with any single symbol operand (see below).\n               Used to specify arbitrary properties of the entity (tags, date, etc).\n               If the property is a string, multiple arguments with the same symbol operand will be concatenated.\n\n")
    c.theme.primary("   List of fields (symbols without definitions are unassigned and do nothing):\n")

    local dateOperand, separatorOperand, tagsOperand, childrenOperand = "[date symbol]", "[separator symbol]", "[tags symbol]", "[children symbol]"

    for i, k in pairs(c.field_lookup) do
        c.theme.auxilary("         "..tostring(i))
        c.theme.primary("    "..tostring(k).."\n")
        if k == "date" then dateOperand = i end
        if k == "separator" then separatorOperand = i end
        if k == "tags" then tagsOperand = i end
        if k == "children" then childrenOperand = i end
    end

    c.theme.primary("\n   Usage example: ")
    c.theme.auxilary("dote todo go to "..dateOperand.."10/27 grocery store "..separatorOperand.." "..tagsOperand.."outside get salad and cheese "..tagsOperand.."chores and "..childrenOperand.."4 dressing\n\n")
    c.theme.primary("   This command would create a new task entity with a due date of 10/27,\n   with tags named 'outside' and 'chores',\n   the name 'go to grocery store',\n   and the body 'get salad and cheese and dressing',\n   that is a child of the entity with id 4.\n\n")
    -- }}}

    -- help section for print commands {{{
    c.theme.primary("Command format for ")
    c.theme.auxilary("dote print\n\n")

    c.theme.auxilary("  dote print [filters] [entity name/id]\n\n")

    c.theme.auxilary("   [filter]")
    c.theme.primary("         Any number of arguments matching filters. Built in filters are `all`, `default`, `direct`, `loose`, `tags`, `todos`, `notes`.\n")
    c.theme.auxilary("   [entity name]")
    c.theme.primary("    The first characters of an entity's `name` field, any amount to match the entity uniquely.\n")
    c.theme.auxilary("   [entity id]")
    c.theme.primary("      The id of an entity you want to match.\n")

    c.theme.primary("\n   Usage example: ")
    c.theme.auxilary("dote print todos tags outside\n\n")
    c.theme.primary("   This command would output entities that are children of the entity named `outside`,\n   that pass the filters `todos` and `tags` (as well as `outside` itself).\n\n")
    -- }}}

    -- help section for delete/done commands {{{
    c.theme.primary("Command format for ")
    c.theme.auxilary("dote [delete/done]\n\n")

    c.theme.auxilary("  dote [action] [entity name/entity id]\n\n")

    c.theme.auxilary("   [action]")
    c.theme.primary("        one of the following commands, or user defined commands\n")
    c.theme.auxilary("      delete")
    c.theme.primary("          delete the specified entity\n")
    c.theme.auxilary("      done")
    c.theme.primary("            mark the specified entity as complete\n")
    c.theme.auxilary("   [entity name]")
    c.theme.primary("   The first characters of an entity's `name` field, any amount to match the entity uniquely.\n")
    c.theme.auxilary("   [entity id]")
    c.theme.primary("     The id of an entity you want to match.\n")

    c.theme.primary("\n   Usage example: ")
    c.theme.auxilary("dote delete go to grocery\n\n")
    c.theme.primary("   This command would delete a single entity whose name begins with 'go to grocery'.\n\n")
    -- }}}
end -- }}}

return M

-- vim:foldmethod=marker
