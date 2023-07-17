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

local function create(type)  -- {{{
    local item = {}          -- create new item
    item.type = type

    fields.process_all(item)       -- hand it off to get it populated

    store.save_item(item) -- add to the tree
end
-- }}}

M.create_todo = function()  -- {{{
    create('todo')
end
-- }}}

M.create_note = function()  -- {{{
    create('note')
end
-- }}}

M.create_tag = function()  -- {{{
    create('tag')
end
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

M.output = function()  -- {{{
    local data = store.load()
    output.print_all(data)
end
-- }}}

M.repair_tree = function()  -- {{{
    local data = store.load(c.datafile_path)
    -- go through the items and pair all parents to chidren and children to parents etc
    for id, item in ipairs(data) do
        for child in ipairs(item.children) do
            table.insert(data[child].parents, id)
        end
        for parent in ipairs(item.children) do
            table.insert(data[parent].children, id)
        end
    end
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
    -- this gotta stay after archive because it is removing data
    store.save(data)

end
-- }}}

return M

-- vim:foldmethod=marker
