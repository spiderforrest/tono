local M = {}

-- You can write your own commands! They get passed your whole configs (recursion workaround) and
-- the dote libs, TODO:write docmentation-but they're pretty well commented.

-- You need to set config.action_lookup for every action you add!!
-- there has to be a key:value pair in there for every function here, otherwise these don't get called
-- there's no 'default look for action with matching name'

-- this just changes a formatting option and calls the stock print function
M.compact = function(c, lib)
    c.format.line_split_fields = false
    c.modify(c)
    lib.actions.print()
end

-- this prints with EVERY field shown
M.debug = function (c, lib)
    c.format.deref_show_id = true
    for k in c.format.blacklist do
        c.format.blacklist[k] = false
    end

    c.modify(c)
    lib.actions.print()
end


return M
-- vim:foldmethod=marker
