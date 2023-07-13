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
local output = require("output")

-- {{{ action functions

M.handle_action = function (context) --{{{
    -- do the lookup
    local action_actual = context.config.action_lookup[context.args[1]]
    -- check if the looked up action is valid
    if M.action[action_actual] then
        table.remove(context.args, 1) -- strip the action
        context.action = action_actual
    else
        context.action = context.config.default_action
    end
    -- launch the action
    M.action[context.action](context)
end
-- }}}

-- {{{ indvidial action handlers
M.action = {}
local function create (type, context) -- {{{
    context.target_item = {} -- create new item
    context.target_item.type = type

    M.handle_fields(context) -- hand it off to get it populated

    utils.data.add(context) -- add to the tree
end
-- }}}

M.action.create_todo = function (context) -- {{{
    create('todo', context)
end
-- }}}

M.action.create_note = function (context) -- {{{
    create('note', context)
end
-- }}}

M.action.create_tag = function (context) -- {{{
    create('tag', context)
end
-- }}}

M.action.done = function () -- {{{
    print("done")
end
-- }}}

M.action.delete = function () -- {{{
    print("delete")
end
-- }}}

M.action.modify = function () -- {{{
    print("modify")
end
-- }}}

M.action.output = function (context) -- {{{
    output.print_all(utils.data.get(context))
end
-- }}}

-- }}} individal action handlers

-- }}} action functions

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
        if M.field[key_actual] then
            M.field[key_actual](body, context)

        -- field is defined but not builtin
        elseif key_actual and not key_actual == '' then
            add_to_field(key_actual, body, context)

        -- otherwise treat as plaintext
        else
            if sym and context.config.warn.unmatched_sym then
                utils.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
            end
            M.field.plain(word, context)
        end
    end
end
-- }}}

-- {{{ individual field actions
M.field = {}

M.field.plain = function (word, context) -- {{{
    if context.past_separator then
        -- add this word to the body
        add_to_field("body", word, context)
    else
        add_to_field("title", word, context)
    end
end
-- }}}

M.field.tag = function (word, context) -- {{{
    add_to_field("tag", word, context)
end
-- }}}

M.field.target = function (word, context) -- {{{
    add_to_field("target", word, context)
end
-- }}}

M.field.date = function (word) print("date: " .. word) end

M.field.parent = function (word, context) -- {{{
    add_to_field("parent", word, context)
end
-- }}}

M.field.child = function (word, context) -- {{{
    add_to_field("child", word, context)
end
-- }}}

M.field.aux_parent = function (word, context) -- {{{
    add_to_field("aux_parent", word, context)
end
-- }}}

M.field.aux_child = function (word, context) -- {{{
    add_to_field("aux_child", word, context)
end
-- }}}

M.field.separator = function (_, context) -- {{{
    context.past_separator = true
end -- }}}

-- }}} individal field actions

-- }}} field functions

return M

-- vim:foldmethod=marker
