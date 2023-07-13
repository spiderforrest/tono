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

package.path = package.path .. ";./lib/?.lua;"
local core = require("core")
local actions = require("actions")

local args, config, action
-- config, args = core.load_config(arg)
config, args = core.load_config(arg, "./config.lua") -- for dev

action, args = core.get_action(args, config)

-- run the action, the rest of flow is handled from those functions.
actions[action](args, config)

-- vim:foldmethod=marker
