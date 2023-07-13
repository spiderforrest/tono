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

-- setup
M.load_config = function (args, config_path) -- {{{
    local configs
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
    if not pcall(function () configs = dofile(config_location) end) then
        M.err("Config file not found! Default location is ~/.config/dote/config.lua")
    end

    return args, configs
end
-- }}}


M.data = {} -- {{{

M.data.load = function (context) --{{{
    -- try to open
    if not pcall( function () context.datafile = io.open(context.config.data_file_location, "r+") end)
        then
        M.err(context.config.data_file_location)
        M.err("Datafile not found")
        -- M.warn("Data file not found! Creating at: " .. context.config.data_file_location)
        -- -- try to create
        -- if not pcall( function () context.datafile = io.open(context.config.data_file_location, "a+") end)
        --     then
        --     M.err("Could not create file!")
        -- end
    end
    -- try to read
    if not pcall( function () context.data = json.parse(context.datafile:read("*all")) end)
        then
        M.warn("Data file empty!")
        context.data = {}

    end
    M.dump_table_of_arrays(context.data)
    return context.data
end -- }}}

M.data.get = function (context)
    if context.data then return context.data end
    return M.data.load(context)
end

M.data.add = function (context) -- {{{
    if not context.data then
        M.data.load(context)
    end

    if not context.target_item then
        M.err("Internal error! Trying to save nonexistent context.target_item.")
    end

    -- slap 'er in the middle if needed
    table.insert(context.data, context.target_item)
    -- flag to save at the end of the transaction, don't save now to prevent multiple saves
    context.modified_tree = true
end
-- }}}

M.data.save = function (context) -- {{{
    if not context.data and not context.datafile then
        M.err("Internal error! Tried to save with missing data or datafile")
    end
    local jsonified = json.stringify(context.data)
    context.datafile:write(jsonified)
end
-- }}}
--
-- }}} M.data

-- }}} setup

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
