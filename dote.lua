#!/usr/bin/env lua

io.write("basic echo, will say whatever back in red\n")
local input = io.read("*line")
io.write('\27[31m' .. input ..'\n')
