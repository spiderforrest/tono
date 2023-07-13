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

local utils = require("utils")
local actions = require("actions")
local fields = require("fields")

M.get_action = function (args, config) --{{{
    local action
    -- do the lookup
    local action_actual = config.action_lookup[args[1]]
    -- check if the looked up action is valid
    if M.action[action_actual] then
        table.remove(args, 1) -- strip the action
        action = action_actual
    else
        action = config.default_action
    end

    actions[action]()
    return action, args
end
-- }}}

-- {{{ field functions

local function add_to_field(field, word, context) -- {{{
    local target = context.target_item[field]
    -- create field if needed cause yea
    if not target then
        context.target_item[field] = {}
        target = context.target_item[field]
    end
    target[#target + 1] = word
end
-- }}}

M.handle_fields = function (context) --{{{
    for _, word in ipairs(context.args) do
        -- match the largest non-letter chain at the start of the arg
        local _, _, sym, body = string.find(word, "^(%A+)(.*)")

        -- do the lookup or default
        local key_actual = context.config.key_lookup[sym]

        -- field has dedicated func
        if fields[key_actual] then
            fields[key_actual](body, context)

        -- field is defined but not builtin
        elseif key_actual and not key_actual == '' then
            add_to_field(key_actual, body, context)

        -- otherwise treat as plaintext
        else
            if sym and context.config.warn.unmatched_sym then
                utils.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
            end
            fields.plain(word, context)
        end
    end
end
-- }}}

-- {{{ individual field actions
-- }}} individal field actions

-- }}} field functions

return M

-- vim:foldmethod=marker
