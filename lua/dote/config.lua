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

-- {{{ long-winded explaination of this before I forget
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
-- }}}


-- we cache the config so that it can be modified on the fly
local Config = {}

if #Config == 0 then
    -- bc this file is a module we're gonna just use Config like M
    Config.setup = function()  -- {{{
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

        -- commentt better latrrrrrrrrr this bad shoulda taken my meds
        -- alllllllso it doesnt work if you re-call config.reset buttt you shouldn't ever do that
        -- i should just name it setup
        -- okay now it's named setup
        -- {{{ read arguments to dynamically set configs by doing `--some-config-thing value`
        for i, v in ipairs(arg) do
            -- match the symbols '--' to find an arg to act on, 'body' will be `-some-config-thing`
            local _, _, body = string.find(v, "^%-(%-.*)") -- match substr after - starting with another - (two - in a row, but keep the second -)
            if body then
                -- check if it's an antibool thingy
                local _,_, rest = string.find(body, "^%-no(.+)") -- match substr after -no
                if rest then body = rest end -- save theaaat and rest will be truthy now yipee

                -- save the key thingyky whatever because if you keep moving the pointer to the acual value
                -- lua goes and switches to it being an unhhhh 'by value' and makes the pointer not a pointer but a regular
                -- variable yeas which is baaad bc we wanna modify the original from Config with . or [] syntax not like
                -- the local ptr
                -- yea
                local key

                local ptr = Config -- hehe it's likea a c mama mia it works likea youa think it do
                for sub_thingyy in string.gmatch(body, "[%-%.]([^%-%.]+)") do -- match substr after - or . and go til next - or .
                    if ptr[sub_thingyy] then
                        if type(ptr[sub_thingyy]) == "table" then -- keep going if it's a table
                            ptr = ptr[sub_thingyy] -- move the pointer down the table tree thingymajob
                            -- hey wait tables are graphs not trees suck it js
                        else
                            key = sub_thingyy
                        end
                    else
                        util.err("entered an invalid config modifying flag at: '" .. v .."'")
                    end
                end

                -- check if it's valid and what it's type is
                if type(ptr[key]) == 'string' then
                    if arg[i+1] then
                        -- set it and strip the flag thingy and the value
                        ptr[key] = arg[i+1]
                        table.remove(arg, i)
                        table.remove(arg, i)
                    else
                        util.err("The flag '" .. v .. "' requires a value")
                    end
                elseif type(ptr[key]) == 'number' then
                    -- print'haiiii'
                    if arg[i+1] and tonumber(arg[i+1]) then
                        -- set it and strip the flag thingy and the value
                        ptr[key] = tonumber(arg[i+1])
                        table.remove(arg, i)
                        table.remove(arg, i)
                    else
                        util.err("The flag '" .. v .. "' requires a number value")
                    end
                elseif type(ptr[key]) == 'boolean' then
                    if rest then -- loll if this is true its cos --no was there so acktually it should be false
                        ptr[key] = false
                    else
                        ptr[key] = true
                    end
                    -- jus the one this time cos no value
                    table.remove(arg, i)
                end
                -- holy shit this shit worked like basically first try
            end
        end
        -- }}}

        -- bake and replace theme:
        Config.theme = util.bake_theme(Config.theme, Config.term_escape_seq)

        -- get flag arguments (importantly, stripping them from arg[])
        Config.data_file_location = util.get_flag("-d") or Config.data_file_location

        return Config
    end
    -- }}}

    -- this file is a module, that sets its own contents to the data inside the config
    Config = Config.setup()

    -- lets you change configs to like, switch formatting rules etc
    Config.modify = function(altered_config)
        Config = altered_config
    end

    -- set any flagged args, will probably just pile as i run into things i want to mess with
    if util.get_flag("--no-recurse", true) then Config.format.single_item_recurse = false end

end

return Config

-- vim:foldmethod=marker
