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

local util = require'dote.util'

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
        local default_config = require'dote.configs'
        local config_location = util.get_flag"-c" or default_config.config_file_location -- lol

        -- load config, warn if no config file found and skip clobber code
        if not pcall(function() user_config = dofile(config_location) end) then
            util.warn("Config file not found or erroring! Default location is " .. default_config.config_file_location)
            user_config = {}
        end

        -- clobber tables together
        default_config = util.merge_tbl_recurse(user_config, default_config)
        Config = util.merge_tbl_recurse(Config, default_config)

        -- {{{ read arguments to dynamically set configs by doing `--some-config-thing value`
        for i, v in ipairs(arg) do
            -- match the symbols '--' to find an arg to act on, 'body' will be `-some-config-thing`
            local _, _, body = string.find(v, "^%-(%-.*)") -- match substr after - starting with another - (two - in a row, but keep the second - in body)
            if body then
                -- for bools, instead of doing writing true/false you after do --no-some-config-thing or --some-config-thing for false/true
                -- check for that and cut the -no from body
                local _,_, rest = string.find(body, "^%-no(.+)") -- match substr after -no
                if rest then body = rest end

                -- tables copy by reference in Lua, so copying one creates an independent pointer
                -- we'll move that along the Config table to find the target setting to change
                local ptr = Config
                -- we can't actually move the pointer all the way to point directly at the setting-
                -- if we do, it turns into an independent variable and copies the value of the setting
                -- so we'll store the final part ('thing' in --some-config-thing) as a string here and
                -- do ptr[key] to actually access the real Config.some.config.thing
                local key

                -- go through the string and step the pointer down a layer for each match
                for layer in string.gmatch(body, "[%-%.]([^%-%.]+)") do -- match substr after - or . and go til next - or .
                    if ptr[layer] ~= nil then
                        -- if it's a table, we need to keep going, we can't set those
                        if type(ptr[layer]) == "table" then
                            ptr = ptr[layer]
                        else
                            -- if we've found the value, set key instead
                            key = layer
                        end
                    else -- bail if not valid
                        util.err("entered an invalid config modifying flag at: '" .. v .."'")
                    end
                end

                -- check if it's valid and what its type is
                if type(ptr[key]) == 'string' then
                    if arg[i+1] then
                        -- set and strip the argument away
                        ptr[key] = arg[i+1]
                        arg[i] = nil -- we will repair the arg table at the end
                        arg[i+1] = nil
                    else
                        util.err("The flag '" .. v .. "' requires a value")
                    end

                elseif type(ptr[key]) == 'number' then
                    if arg[i+1] and tonumber(arg[i+1]) then
                        ptr[key] = tonumber(arg[i+1])
                        arg[i] = nil
                        arg[i+1] = nil
                    else
                        util.err("The flag '" .. v .. "' requires a number value")
                    end

                elseif type(ptr[key]) == 'boolean' then
                    if rest then -- rest is truthy if --no is found, so inverted here
                        ptr[key] = false
                    else
                        ptr[key] = true
                    end
                    arg[i] = nil
                end
            end
        end

        -- we absolutely mess up the arg table to keep the iterator in sync above, so fix that now
        -- (we replaced 'used' values with nil, to mark them as used, but we want arg continuous)
        for i,v in pairs(arg) do
            if v and i ~= -1 and i ~= 0 then -- don't fuck with the defaults
                arg[i] = nil -- delete it from where it is
                table.insert(arg, v) -- put it where it should be
            end
        end
        -- }}}

        -- bake and replace theme:
        Config.theme = util.bake_theme(Config.theme, Config.term_escape_seq)

        -- get flag arguments (importantly, stripping them from arg[])
        Config.data_file_location = util.get_flag"-d" or Config.data_file_location

        return Config
    end
    -- }}}

    -- this file is a module, that sets its own contents to the data inside the config
    Config = Config.setup()

    -- lets you change configs to like, switch formatting rules etc
    Config.modify = function(altered_config)
        Config = altered_config
    end

end

return Config

-- vim:foldmethod=marker
