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

local output = require("output")
local c = require("config")

local M = {}

-- this one goes through the input text, parses it, and calls all the field handlers appropriately
M.process_all = function(item)  --{{{
    local separator_status = "title"
    for _, word in ipairs(arg) do
        -- match the largest non-letter chain at the start of the arg
        local _, _, sym, body = string.find(word, "^(%W+)(.*)")

        -- do the lookup or default
        local key_actual = c.field_lookup[sym]

        -- swap adding to title or body
        if key_actual == "separator" then
            separator_status = "body"
            goto continue -- gotta save all of like. 16 instructions by skipping eval
        end

        -- if field has handler
        if M[key_actual] then
            M[key_actual](body, item)
            goto continue
        end

        -- if field is defined but doesn't have a handler just add it
        if key_actual and not key_actual == '' then
            M.add_to_field(key_actual, body, item)
            goto continue
        end

        -- otherwise treat as plaintext
        if sym and c.warn.unmatched_sym then
            output.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
        end
        M.add_to_field(separator_status, word, item)

        ::continue::
    end
    return item
end
-- }}}

M.add_to_field = function(field, word, item) -- {{{
    -- create field if needed
    if not item[field] then
        item[field] = {}
    end
    table.insert(item[field], word)
    return item
end                           --  }}}

M.tag = function(word, item)  -- {{{
    return M.add_to_field("tag", word, item)
end
-- }}}

M.target = function(word, item)  -- {{{
    return M.add_to_field("target", word, item)
end
-- }}}

M.date = function(word, item) -- {{{
end
-- }}}

M.parent = function(word, item)  -- {{{
    return M.add_to_field("parent", word, item)
end
-- }}}

M.child = function(word, item)  -- {{{
    return M.add_to_field("children", word, item)
end
-- }}}

M.aux_parent = function(word, item)  -- {{{
    M.add_to_field("aux_parent", word, item)
end
-- }}}

M.aux_child = function(word, item)  -- {{{
    M.add_to_field("aux_child", word, item)
end
-- }}}


return M

-- vim:foldmethod=marker
