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
local c = require("config")

local M = {}

M.create = function (type)  -- {{{
    local item = {} -- create new item
    item.type = type
    item.created = os.time()

    -- pull the data
    local data = store.load()

    -- append the item, get its id
    data[#data + 1] = item

    fields.process_all(data, #data) -- hand it off to get it populated

    store.save(data) -- add to the tree
end

-- lazily dispatch these
M.create_todo = function() M.create('todo') end
M.create_note = function() M.create('note') end
M.create_tag = function() M.create('tag') end
-- }}}

M.done = function()  -- {{{
    print("done")
end
-- }}}

M.delete = function()  -- {{{
    print("delete")
end
-- }}}

M.modify = function()  -- {{{
    print("modify")
end
-- }}}

M.compact = function()
    c.format.line_split_fields = false
    c.modify(c)
    M.output()
end

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
    store.save(data)

end
-- }}}

return M

-- vim:foldmethod=marker
