 local M = {}

M.dump_table_of_arrays = function(tbl) -- {{{
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(k .. ": " .. table.concat(v, " "))
        elseif type(v) == 'string' then
            print(k .. ": " .. v)
        end
    end
end
-- }}}
M.compact = function(c, lib)

     M.dump_table_of_arrays(lib.actions)
    c.format.line_split_fields = false
    c.modify(c)
    lib.actions.output()
end

 return M
 -- vim:foldmethod=marker
