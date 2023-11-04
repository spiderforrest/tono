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

-- explaination of this before I forget
-- lua caches stuff when you run require so it doesn't need to re-process the file when you
-- use require again. That makes it possible to run a setup once and store data. That data is
-- even mutable, and `config` is the module itself. It's the configs stored during runtime
-- and then discarded at the end. This means the configs can be more than just static tables, and
-- I'm primarily using it for two things: one; transforming all the theme colors into functions for
-- convience, and two; allowing the configs to be modified at any point and then when other files
-- require this file, it will give the modified configs. So this will have everything from the
-- configs, and `.reset()` as well as `.modify()` added.
-- in total, this file:
-- makes a table
-- craetes .reset and .modify
-- calls .reset, which is basically just an init function that can be rerun
-- pulls in the default and user configs and merges them
-- sets the config data to the module itself
-- does some stuff with themes
-- caches that data
-- subsequent requires just give the data

--probably didn't need to write all that out but the naming here is bad so it can be pretty
--elsewhere


-- we cache the config so that it can be modified on the fly
local config = {}

if #config == 0 then
    -- bc this file is a module we're gonna just use active_config like M
    -- and while this is a setup function it's exposed so that's why it's named reset
    config.reset = function()  -- {{{
        local user_config
        -- get default configs
        local default_config = require("configs")
        local config_location = util.get_flag("-c") or default_config.config_file_location -- lol

        -- load config, warn if no config file found and skip clobber code
        if not pcall(function() user_config = dofile(config_location) end) then
            util.warn("Config file not found! Default location is ~/.config/dote/config.lua")
            user_config = {}
        end

        -- clobber tables together
        default_config = util.merge_tbl_recurse(default_config, user_config)
        config = util.merge_tbl_recurse(config, default_config)

        -- bake and replace theme:
        config.theme = util.bake_theme(default_config.theme, default_config.term_escape_seq)

        return config
    end
    -- }}}

    -- this file is a module, that sets its own contents to the data inside the config
    config = config.reset()

    -- lets you change configs to like, switch formatting rules etc
    config.modify = function(altered_config)
        config = altered_config
    end
end

return config

-- vim:foldmethod=marker
