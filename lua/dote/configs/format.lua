
-- Contains options related to formatting output

local M = {}
-- the escape sequence for setting colors
M.term_escape_seq = "\27["

-- for printing the tree, how much whitespace
M.indent = 4
M.left_align_id = true

-- when you show a single item does it recurse by default
M.single_item_recurse = true

-- print items decending vs ascending
M.order_descending = true

-- prevent it from ever rendering the same item twice
M.never_duplicate = false

-- what order do you want the fields to show in
M.field_order = {
    'done',
    'title',
    'body',
    'tags',
    'date',
    'type',
    'created',
}


-- various symbols for rendering
M.true_string = "✓" -- for showing bools
M.false_string = "X"
M.date = "%b %d, %H:%M" -- date strng, pretty much same as unix `date` but see https://www.lua.org/pil/22.1.html
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

-- do you want to render items as one line or a line for each field
M.line_split_fields = true

-- blacklist fields to not render
M.blacklist = {
    children = true,
    parents = true,
    type = true,
    created = true,
    id = true,
    hide = true,
}

-- list of fields with special types that need to be rendered in different formats etc
-- other fields are just strings
M.field_type = {
    created = "date",
    updated = "date",
    target = "date",
    deadline = "date",
    done = "bool",
    hidden = "bool",
    id = "id",
    children = "deref", -- for lists of ids
    parents = "deref",
    tags = "deref", -- this field isn't real, but the renderer thinks it is
}

-- when listing parents, tags, children ('deref' fields), show the item id/title?
-- probably don't turn them both off...
M.deref_show_id = true
M.deref_show_title = true

return M
