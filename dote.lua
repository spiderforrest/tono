#!/usr/bin/env lua

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

local json = require("json")

local function demo()
    local tbl = { key = "value", 2 }
    io.write("basic echo, will say whatever back in red\n")
    local input = io.read("*line")
    io.write('\27[31m' .. json.stringify(tbl) ..'\n')
    io.write('\27[31m' .. input ..'\n')
    io.write('\27[31m' .. arg[1] ..'\n')
end
--[[
dote [action] [target...] [data...]

actions:
create
done
delete
modify

target:
(for modify:) entity field

data:
<field char>data
: for body?
-- ]]

-- special arg check for -c (to change config dir)
-- load configs (lua obvs)
-- parse args
-- load datafile(check with user if none)
-- do the action
-- save/output

-- {{{ find/load config
-- set default config location
local config_location = os.getenv("HOME") .. "/.config/dote/init.lua"
-- iterate thru args and check if the config location is specified
for i, v in ipairs(arg) do
    if v == "-c" then
        print("arg match")
        config_location = arg[i + 1]
    end
end


-- load configs, error out if no config file found
if not pcall(function () dofile(config_location) end) then
    print("Config file not found! Default location is ~/.config/dote/init.lua")
    os.exit()
end
-- }}}

-- vim:foldmethod=marker
