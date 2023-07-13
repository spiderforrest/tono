
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

M.load_data = function (datafile_path) --{{{
    local data, datafile
    -- try to open
    if not pcall( function () datafile = io.open(datafile_path, "r+") end)
        then
        output.err(datafile_path)
        output.err("Datafile not found")
        -- M.warn("Data file not found! Creating at: " .. datafile_path)
        -- -- try to create
        -- if not pcall( function () datafile = io.open(datafile_path, "a+") end)
        --     then
        --     M.err("Could not create file!")
        -- end
    end
    -- try to read
    if not pcall( function () data.tree = json.parse(datafile:read("*all")) end)
        then
        output.warn("Data file empty!")
        data = {}

    end
    return data, datafile
end -- }}}

M.save_data = function (data, datafile) -- {{{
    local jsonified = json.stringify(data)
    datafile:write(jsonified)
end -- }}}

M.save_item = function (item) -- {{{
    local data, datafile = M.load_data()
    table.insert(data, item)
    M.save_data(data, datafile)
    return data
end
-- }}}

return M

-- vim:foldmethod=marker
