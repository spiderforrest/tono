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

local utils = require('utils')
local output = require("output")

local M = {}
local function create (type, context) -- {{{
    context.target_item = {} -- create new item
    context.target_item.type = type

    M.handle_fields(context) -- hand it off to get it populated

    utils.data.add(context) -- add to the tree
end
-- }}}

M.create_todo = function (context) -- {{{
    create('todo', context)
end
-- }}}

M.create_note = function (context) -- {{{
    create('note', context)
end
-- }}}

M.create_tag = function (context) -- {{{
    create('tag', context)
end
-- }}}

M.done = function () -- {{{
    print("done")
end
-- }}}

M.delete = function () -- {{{
    print("delete")
end
-- }}}

M.modify = function () -- {{{
    print("modify")
end
-- }}}

M.output = function (context) -- {{{
    output.print_all(utils.data.get(context))
end
-- }}}


return M

-- vim:foldmethod=marker
