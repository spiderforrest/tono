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

local actions = require("actions")
local output = require("output")

M.load_config = function (args, config_path) -- {{{
    local config
    local config_location = config_path or os.getenv("HOME") .. "/.config/dote/config.lua"
    -- iterate thru argss and check ifthe config location is specified
    for i, v in ipairs(args) do
        if v == "-c" then
            if args[i+1] == nil then -- if -c flag passed by itself
                output.err("The flag -c requires a path")
            end
            config_location = args[i + 1]
            table.remove(args,i)
            table.remove(args,i) -- removing both "-c" and the path specified after it so we remove twice
        end
    end

    -- load config, error out if no config file found
    if not pcall(function () config = dofile(config_location) end) then
        output.err("Config file not found! Default location is ~/.config/dote/config.lua")
    end

    return config, args
end
-- }}}

M.get_action = function (args, config) --{{{
    local action
    -- do the lookup
    local action_actual = config.action_lookup[args[1]]
    -- check if the looked up action is valid
    if actions[action_actual] then
        table.remove(args, 1) -- strip the action
        action = action_actual
    else
        action = config.default_action
    end

    return action, args
end
-- }}}



return M

-- vim:foldmethod=marker
