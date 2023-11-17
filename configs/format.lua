
-- Contains options related to formatting output

local M = {}
-- the escape sequence for setting colors
M.term_escape_seq = "\27["

-- for printing the tree, how much whitespace
M.indentation = 4
M.left_align_id = true

-- when you show a single item does it recurse by default
M.single_item_recurse = true

-- print items decending vs ascending
M.order_decending = true

-- how do you want the fields to show
M.field_order = {
    'done',
    'title',
    'body',
    'tag',
    'date',
    'type',
    'created',
}

-- date strng, pretty much same as unix `date` but see https://www.lua.org/pil/22.1.html
M.date = "%b %d, %H:%M"
-- M.true_string = "✔"
M.true_string = "✓"
M.false_string = "X"

M.ascii_diagram = {
    -- these three apply with split fields
    first_line = '╔', -- first item
    middle_line = '╠', -- middle items
    last_line = '╚', -- last item
    only_line = '═', -- for if there's only one item on a line
    field_key_val = "> ", -- separator between field key/content
    inline = " | ", -- separator between fields when it's not split by lines
    after_id = ": ", -- idk how to name this bc a colon is the only thing that makes sense to me
    list_sep = ", ", -- for inline lists; see deref
}
M.line_split_fields = true
-- M.line_split_fields = false

-- blacklist fields
M.blacklist = {
    children = true,
    parents = true,
    type = true,
    created = true,
    id = true,
}

-- list of fields with special types that need to be rendered in different formats etc
M.field_type = {
    created = "date",
    updated = "date",
    target = "date",
    deadline = "date",
    done = "bool",
    hidden = "bool",
    id = "int",
    tags = "deref", -- for lists of ids
    children = "deref",
    parents = "deref",
}

M.deref_show_id = false

return M
