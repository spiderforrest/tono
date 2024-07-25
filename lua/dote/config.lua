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

local util = require("dote.util")

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
local Config = {}

if #Config == 0 then
    -- bc this file is a module we're gonna just use active_config like M
    -- and while this is a setup function it's exposed so that's why it's named reset
    Config.reset = function()  -- {{{
        local user_config
        -- get default configs
        local default_config = require("dote.configs")
        local config_location = util.get_flag("-c") or default_config.config_file_location -- lol

        -- load config, warn if no config file found and skip clobber code
        if not pcall(function() user_config = dofile(config_location) end) then
            util.warn("Config file not found or erroring! Default location is ~/.config/dote/config.lua")
            user_config = {}
        end

        -- clobber tables together
        default_config = util.merge_tbl_recurse(user_config, default_config)
        Config = util.merge_tbl_recurse(Config, default_config)

        -- bake and replace theme:
        Config.theme = util.bake_theme(Config.theme, Config.term_escape_seq)

        -- get flag arguments (importantly, stripping them from arg[])
        Config.data_file_location = util.get_flag("-d") or Config.data_file_location

        return Config
    end
    -- }}}

    -- this file is a module, that sets its own contents to the data inside the config
    Config = Config.reset()

    -- lets you change configs to like, switch formatting rules etc
    Config.modify = function(altered_config)
        Config = altered_config
    end

    -- set any flagged args, will probably just pile as i run into things i want to mess with
    if util.get_flag("--no-recurse", true) then Config.format.single_item_recurse = false end

end

return Config

-- vim:foldmethod=marker
