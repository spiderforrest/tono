
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

local M = {}
local output = require("output")
local json = require("json")

M.load = function (datafile_path) --{{{
    local data, datafile
    -- try to open
    if not pcall( function () datafile = assert(io.open(datafile_path, "r")) end)
        then
        output.err("Datafile not found-please create it or check the path!")
    end
    -- try to read
    if not pcall( function () data = json.parse(datafile:read("*all")) end)
        then
        output.warn("Data file empty!")
        data = {}
    end

    datafile:close()
    return data
end -- }}}

M.save = function (data, datafile_path) -- {{{
    local datafile, jsonified, safety
    -- read the file again and store it raw-crash damn program if it can't, do NOT try to write
    safety = assert(io.open(datafile_path, "r"):read("*all"))

    jsonified = json.stringify(data)

    if not pcall( function ()
        datafile = assert(io.open(datafile_path, "w+"))
        datafile:write(jsonified)
        end)
            then
            io.write(safety)
            io.write("\n\n")
            output.err("ERROR WRITING FILE! Last saved contents dumped above, please manually make sure it wasn't overwritten.")
    end
    datafile:close()
end -- }}}

M.save_item = function (item, datafile_path) -- {{{
    local data = M.load(datafile_path)
    table.insert(data, item)
    M.save(data, datafile_path)
    return data
end
-- }}}

return M

-- vim:foldmethod=marker
