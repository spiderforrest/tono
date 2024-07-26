package = "dote"
version = "1.0-1"
source = {
   url = "git://github.com/spiderforrest/dote.git",
}
description = {
   summary = "A cli to-do and note-taking system built on graph theory",
   detailed = [[
      A to-do and note-taking system centered around dependencies and priorities inside a directed graph.
      Dote is a collection of different programs that are all intended to access the same central data storage scheme, of human readable JSON.
      This is a command line Lua application for using dote.
   ]],
   homepage = "http://github.com/spiderforrest/dote",
   license = "AGPL-3.0"
}
dependencies = {
   "lua >= 5.3"
}
build = {
   type = "builtin",
   modules = {
   },
   install = {
      bin = { "bin/dote" }
   }
}
