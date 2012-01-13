local T, C, L = unpack(Tukui)

-- MOVEING THE MINIMAP STATS
local minileft = TukuiMinimapStatsLeft
local miniright = TukuiMinimapStatsRight

minileft:SetParent(UIParent)
minileft:ClearAllPoints()
minileft:Point("RIGHT", RaidBuffReminder, "LEFT", -3, 0)
minileft:Width(72)

miniright:SetParent(UIParent)
miniright:ClearAllPoints()
miniright:Point("LEFT", RaidBuffReminder, "RIGHT", 3, 0)
miniright:Width(72)

-- bye bye
TukuiLineToABLeft:Kill()
TukuiLineToABLeftAlt:Kill()
TukuiLineToABRight:Kill()
TukuiLineToABRightAlt:Kill()