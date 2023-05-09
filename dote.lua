#!/usr/bin/env lua

 -- Copyright (C) 2023 Spider Forrest
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

local tbl = { key = "value", 2 }


io.write("basic echo, will say whatever back in red\n")
local input = io.read("*line")
io.write('\27[31m' .. json.stringify(tbl) ..'\n')
io.write('\27[31m' .. input ..'\n')
io.write('\27[31m' .. arg[1] ..'\n')


