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

local json = require("json") -- import json lib

local M = {}

M.load_config = function (args, config_path) -- {{{
    local config
    -- local config_location = config_path or .getenv("HOME") .. "/.config/dote/config.lua"
    local config_location = config_path or "./config.lua"
    -- iterate thru argss and check ifthe config location is specified
    for i, v in ipairs(args) do
        if v == "-c" then
            if args[i+1] == nil then -- if -c flag passed by itself
                M.err("The flag -c requires a path")
            end
            config_location = args[i + 1]
            table.remove(args,i)
            table.remove(args,i) -- removing both "-c" and the path specified after it so we remove twice
        end
    end

    -- load config, error out if no config file found
    if not pcall(function () config = dofile(config_location) end) then
        M.err("Config file not found! Default location is ~/.config/dote/config.lua")
    end

    return config, args
end
-- }}}


M.data = {} -- {{{

M.data.load = function (datafile_path) --{{{
    local data, datafile
    -- try to open
    if not pcall( function () datafile = io.open(datafile_path, "r+") end)
        then
        M.err(datafile_path)
        M.err("Datafile not found")
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
        M.warn("Data file empty!")
        data = {}

    end
    return datafile, data
end -- }}}

M.data.save = function (data, datafile) -- {{{
    local jsonified = json.stringify(data)
    datafile:write(jsonified)
end
-- }}}
--
-- }}} M.data


M.dump_table_of_arrays = function (tbl) -- {{{
    for k,v in pairs(tbl) do
        if type(v) == 'table' then
            print(k .. ": " .. table.concat(v, " "))
        elseif type(v) == 'string' then
            print(k .. ": " .. v)
        end
    end
end
-- }}}

M.color = {} -- {{{
M.color.red = function () io.write("\27[31m") end
M.color.orange = function () io.write("\27[33m") end
M.color.reset = function () io.write("\27[0m") end
-- }}}


M.warn = function (body)
    M.color.orange()
    io.write(body .. '\n')
    M.color.reset()
end

--}}}

M.err = function (body)
    M.color.red()
    io.write(body .. '\n')
    M.color.reset()
    os.exit()
end

return M

-- vim:foldmethod=marker
