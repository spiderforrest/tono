
-- Contains options related to formatting output

local M = {}
-- the escape sequence for setting colors
M.term_escape_seq = "\27["

-- for printing the tree, how much whitespace
M.indentation = 4
M.left_align_id = true

-- when you show a single item does it recurse by default
M.single_item_recurse = true

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
    '╔', -- first item
    '╠', -- middle items
    '╚', -- last item
    "> ", -- separator between field key/content
    " | ", -- separator between fields
}
M.line_split_fields = true
-- M.line_split_fields = false

-- blacklist fields
M.blacklist = {
    children = true,
    parents = true,
    type = true,
    created = true,
}

-- list of fields with special types that need to be rendered in different formats etc
M.field_type = {
    created = "date",
    updated = "date",
    target = "date",
    deadline = "date",
    done = "bool"
}

return M
