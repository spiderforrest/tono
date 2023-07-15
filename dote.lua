#!/usr/bin/env lua

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

package.path = package.path .. ";./lib/?.src;"

-- calling this actively loads the configs (and cuts -c from arg)
local config = require("config")

-- this contains functions for each command
local actions = require("actions")


-- lookup the user's aliases
local action = config.action_lookup[arg[1]]

-- check if the looked up action is valid
if actions[action] then
    table.remove(arg, 1) -- strip the action
else
    action = config.default_action -- or default
end

-- then run the action, the rest of flow is handled from those functions.
actions[action]()

-- vim:foldmethod=marker
