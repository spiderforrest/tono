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
local util = require("util")
local json = require("json")
local c = require("config")

-- hold the datafile in this module's scope, prevent reperated re openings
local data_cache = nil

M.get = function(path) --{{{

    if not path then
        -- quickly return the data on subsequent actions
        if data_cache then
            return data_cache
        end
        path = c.data_file_location
    end

    local data, file
    -- try to open
    if not pcall(function() file = assert(io.open(path, "r")) end)
    then
        util.err("File " .. tostring(path) .. " not found!")
    end
    -- try to read
    if not pcall(function() data = json.parse(file:read("*all")) end)
    then
        util.warn("File " .. tostring(path) .. " empty or malformatted!")
        data = {}
    end
    file:close()

    -- save the data for later if it's the standard data file
    if path == c.data_file_location then
        data_cache = data
    end

    return data
end
-- }}}

M.save = function(data, path) -- {{{
    local datafile, jsonified, safety
    path = path or c.data_file_location
    -- read the file again and store it raw-crash damn program if it can't, do NOT try to write
    safety = assert(io.open(path, "r"):read("*all"))

    jsonified = json.stringify(data)

    if not pcall(function()
        datafile = assert(io.open(path, "w+"))
        datafile:write(jsonified)
    end)
    then
        -- dump and crash
        c.theme.ternary("/// Old file contents: ///")
        io.write(safety .. "\n\n")
        c.theme.ternary("/// Cache contents: ///")
        io.write(json.stringify(data_cache) .. "\n\n")
        util.err(
            "ERROR WRITING FILE! Data dumped above, please manually verify your stored data before running dote again."
        )
    end
    datafile:close()

    -- update the cache
    if not path then
        data_cache = data
    end
end                                         -- }}}

return M

-- vim:foldmethod=marker
