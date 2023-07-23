
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
    'title',
    'body',
    'tag',
    'date',
}

M.ascii_diagram = {
    '╔', -- first item
    '╠', -- middle items
    '╚', -- last item
    "> ", -- separator between field key/content
    " | ", -- separator between fields
}
M.line_split_fields = true

M.ascii_diagram = {
    '', -- first item
    '', -- middle items
    '', -- last item
    "> ", -- separator between field key/content
    " | ", -- separator between fields
}
M.line_split_fields = false

-- blacklist fields
M.field_blacklist = {
    children = true,
    parents = true,
    type = true,
    created = true,
}
return M
