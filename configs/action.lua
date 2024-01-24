 local M = {}

 -- You can write your own commands! They get passed your whole configs (recursion workaround) and
 -- the dote libs, TODO:write docmentation-but they're pretty well commented.

 -- You need to set config.action_lookup!!
 -- there has to be a key:value pair in there for every function here, otherwise these don't get called

 -- this just changes a formatting option and calls the stock print function
M.compact = function(c, lib)
    c.format.line_split_fields = false
    c.modify(c)
    lib.actions.print()
end

M.debug = function (c, lib)
  c.format.deref_show_id = true
  c.format.blacklist = {
      title = false,
      children = false,
      parents = false,
      type = false,
      created = false,
      id = false,
  }
  arg[1] = "all"
  c.modify(c)
  lib.actions.print()
end


 return M
 -- vim:foldmethod=marker
