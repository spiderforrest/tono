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
local fields = require("fields")
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

M.handle_fields = function (args, config, item) --{{{
    local separator_status = "title"
    for _, word in ipairs(args) do
        -- match the largest non-letter chain at the start of the arg
        local _, _, sym, body = string.find(word, "^(%A+)(.*)")

        -- do the lookup or default
        local key_actual = config.field_lookup[sym]

        -- swap adding to title and body
        if key_actual == "separator" then
            separator_status = "body"
            goto continue -- gotta save all of like. 16 instructions by skipping eval
        end

        -- if field has handler
        if fields[key_actual] then
            item = fields[key_actual](body, item, args)
            goto continue
        end

        -- if field is defined but doesn't have a handler just add it
        if key_actual and not key_actual == '' then
            item = fields.add_to_field(separator_status, body, item)
            goto continue
        end

        -- otherwise treat as plaintext
        if sym and config.warn.unmatched_sym then
            M.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
        end
        item = fields.plain(word, item)

        ::continue::
    end
    return item
end
-- }}}


return M

-- vim:foldmethod=marker
