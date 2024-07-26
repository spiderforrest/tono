
-- contains color options

local M = {}

-- format should be in { r, g, b, bg={r,g,b} }
-- any unspecified values will be treated as zero

-- M.primary = { g=255, bg={} } -- hacker green on black
M.primary = { r=160, g=20, b=140 } -- something tolerable
M.auxilary = { r=90, g=180, b=110 }
M.ternary = { r=90, g=90, b=90 }
M.accent = { r=255 }
return M
