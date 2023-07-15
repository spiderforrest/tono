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

local util = require("util")

local initialize = function()  -- {{{
    local config
    -- local config_location = os.getenv("HOME") .. "/.config/dote/config.lua"
    local config_location = "./default_config.lua"
    -- iterate thru argss and check ifthe config location is specified
    for i, v in ipairs(arg) do
        if v == "-c" then
            if arg[i + 1] == nil then -- if -c flag passed by itself
                util.err("The flag -c requires a path")
            end
            config_location = arg[i + 1]
            table.remove(arg, i)
            table.remove(arg, i) -- removing both "-c" and the path specified after it so we remove twice
        end
    end

    -- load config, error out if no config file found
    if not pcall(function() config = dofile(config_location) end) then
        util.err("Config file not found! Default location is ~/.config/dote/config.lua")
    end

    return config
end
-- }}}

-- this file is a module, that sets its own contents to the functions inside the config

return initialize()



-- vim:foldmethod=marker
