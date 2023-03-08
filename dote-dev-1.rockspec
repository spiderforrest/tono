package = "dote"
version = "dev-1"
source = {
   url = "git+https://github.com/spiderforrest/dote"
}
description = {
   summary = "A to-do and note-taking system centered around dependencies and priorities.",
   detailed = [[
A to-do and note-taking system centered around dependencies and priorities.
Inspiration taken from [paradigm/chore](https://github.com/paradigm/chore).]],
   homepage = "https://github.com/spiderforrest/dote",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      dote = "dote.lua"
   }
}
