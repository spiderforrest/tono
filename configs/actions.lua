 local M = {}

M.compact = function(c, lib)

    c.format.line_split_fields = false
    c.modify(c)
    lib.actions.output()
end

 return M
 -- vim:foldmethod=marker
