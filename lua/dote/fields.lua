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
local c = require'dote.config'
local store = require'dote.store'

local M = {}

-- this one goes through the input text, parses it, and calls all the field handlers appropriately
M.process_all = function(id, reset)  --{{{
    local data = store.get()
    local separator_status = "title"
    for _, word in ipairs(arg) do
        -- match the largest non-alphanumeric chain at the start of the arg
        local _, _, sym, body = string.find(word, "^(%W+)(.*)")

        -- do the lookup or default
        local key_actual = c.field_lookup[sym]

        -- swap adding to title or body
        if key_actual == "separator" then
            separator_status = "body"

            -- if field has handler
        elseif M[key_actual] then
            if reset then M.reset_field(key_actual, id) end -- if modifying, we blank the field
            M[key_actual](body, id)

            -- if field is defined but doesn't have a handler just add it
        elseif key_actual and key_actual ~= '' then
            if reset then M.reset_field(key_actual, id) end
            M.add_to_field(key_actual, body, id)

            -- otherwise treat as plaintext, with the symbol as part of the text
        else
            if sym and c.warn.unmatched_sym then
                util.warn("No defined field for '" .. sym .. "'! Treating as plaintext.")
            end
            if reset then M.reset_field(separator_status, id) end
            M.add_to_field(separator_status, word, id)
        end
    end
    return data[id]
end
-- }}}

local reset_tracker = {} -- if we reset we only want to the first time we change the field
M.reset_field = function (field, id) -- {{{
    -- cancel if we've already reset the field so we don't repeatedly blank it on the same action
    if reset_tracker[field] then return end
    -- log that we're changing it
    reset_tracker[field] = true

    local data = store.get()
    if c.format.field_type[field] == 'deref' then
        -- util.err"....sorry, can't modify relationships at the moment, the code exists but isn't here"

        -- check whompst
        local inverse_target
        if field == "tags" then field = "parents" end -- there are no tags in Ba Sing Se
        if field == "parents" then inverse_target = "children"
        elseif field == "children" then inverse_target = "parents"
        else util.err("cannot modify unknown relationship field " .. field)
        end

        -- iterate through who's there and fix the inverse
        for _,v in ipairs(data[id][field]) do
            -- search for the current id in the opposite
            for k in ipairs(data[v][inverse_target]) do
                -- remove
                table.remove(data[v][inverse_target], k)
            end
        end

        -- then you can reset the field
        data[id][field] = {}

    elseif c.format.field_type[field] == 'date' then
        -- this one doesn't really do anything, but if something's weird it'll be obvious?
        data[id][field] = 0
    else -- then string
        data[id][field] = ''
    end
end --}}}

M.add_to_field = function(field, word, id) -- {{{
    local data = store.get()

    -- create field if needed
    if not data[id][field] then
        if c.format.field_type[field] == 'deref' then
            data[id][field] = {}
        else
            data[id][field] = ''
        end
    end

    -- ids should not be duplicated, so use ensure_present for them
    if c.format.field_type[field] == 'deref' then
        util.ensure_present(data[id][field], util.get_id_by_maybe_title(word, data))

    elseif c.format.field_type[field] == 'date' then
        -- todo: convert input from human readable date (alternatively, git gud & mentally keep time by nix stamp)
        data[id][field] = tonumber(word)
    elseif c.format.field_type[field] == 'bool' then
        if word == "false" or word == 'done' then word = false end
        data[id][field] = not not word -- lol

    elseif type(data[id][field]) == 'string' then
        -- no annoying first space or extra spaces
        if #data[id][field] > 0 and not string.find(data[id][field], "%s$") then
            data[id][field] = data[id][field] .. ' '
        end

        data[id][field] = data[id][field] .. word
    else
        util.err("Something weird is going on with the field '" .. field .. " of item " .. id .. " (with word " .. word .. ")")
    end
end
--  }}}

M.target = function(word, id)  -- {{{
    M.add_to_field("target", word, id)
end
-- }}}

M.children = function(word, id)  -- {{{
    local data = store.get()
    local child_id = util.get_id_by_maybe_title(word, data)

    M.add_to_field("parents", id, child_id)
    M.add_to_field("children", child_id, id)
end
-- }}}

M.parents = function(word, id)  -- {{{
    local data = store.get()
    -- if user puts the parent name in because duh that's how it works in your brain
    -- i thought there was a bug where somehow the parent name was getting inserted where id's should be
    -- lol no that was just me PEBKAC
    local parent = util.get_id_by_maybe_title(word, data)

    -- the LAST arg is the id of the item you want to modify
    M.add_to_field("children", id, parent) -- so the tag gets it's children field messed with
    M.add_to_field("parents", parent, id) -- and the target item gets it's parents field messed with
    -- you don't wanna know how many times i screwed that up, easy as it is now
end
-- }}}

M.tags = function(word, id)  -- {{{
    -- tags r just parents
    return M.parents(word, id)
end
-- }}}

return M

-- vim:foldmethod=marker
