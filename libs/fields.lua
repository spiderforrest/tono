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
local c = require("config")
local store = require("store")

local M = {}

-- this one goes through the input text, parses it, and calls all the field handlers appropriately
M.process_all = function(id)  --{{{
    local data = store.get()
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
            M[key_actual](body, id)
            goto continue
        end

        -- if field is defined but doesn't have a handler just add it
        if key_actual and not key_actual == '' then
            M.add_to_field(key_actual, body, id)
            goto continue
        end

        -- otherwise treat as plaintext
        if sym and c.warn.unmatched_sym then
            util.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
        end
        M.add_to_field(separator_status, word, id)

        ::continue::
    end
    return data[id]
end
-- }}}

M.add_to_field = function(field, word, id) -- {{{
    local data = store.get()

    -- create field if needed
    if not data[id][field] then
        data[id][field] = {}
    end

    -- ids should not be duplicated, so use ensure_present for them
    if data[tonumber(word)] then
        util.ensure_present(data[id][field], word)
    else
        table.insert(data[id][field], word)
    end

end
--  }}}

M.tag = function(word, id)  -- {{{
    local data = store.get()
    local filter = function (item)
        if item.type == 'tag' then return true end
        return false
    end

    -- if user puts the tag name in because duh that's how it works in your brain
    -- i thought there was a bug where somehow the tag name was getting inserted where id's should be
    -- lol no that was just me PEBKAC
    local tag = util.get_id_by_maybe_title(word, data, filter)

    -- the LAST arg is the id of the item you want to modify
    M.add_to_field("children", id, tag) -- so the tag gets it's children field messed with
    M.add_to_field("tags", tag, id) -- and the target item gets it's tags field messed with
    -- you don't wanna know how many times i screwed that up, easy as it is now
end
-- }}}

M.target = function(word, id)  -- {{{
    M.add_to_field("target", word, id)
end
-- }}}

M.parent = function(word, id)  -- {{{
    local data = store.get()
    local parent_id = util.get_id_by_maybe_title(word, data)

    M.add_to_field("children", id, parent_id)
    M.add_to_field("parents", parent_id, id)
end
-- }}}

M.child = function(word, id)  -- {{{
    local data = store.get()
    local child_id = util.get_id_by_maybe_title(word, data)

    M.add_to_field("parents", id, child_id)
    M.add_to_field("children", child_id, id)
end
-- }}}


return M

-- vim:foldmethod=marker
