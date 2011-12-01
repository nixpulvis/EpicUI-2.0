local T, C, L = unpack(Tukui)

-- Control Panel
local control = CreateFrame("Frame", "TukuiControl", UIParent)
control:Height(38)
control:Point("BOTTOMLEFT", TukuiBar4, "TOPLEFT", -1, -3)
control:Point("BOTTOMRIGHT", TukuiBar4, "TOPRIGHT", 1, -3)
control:SetFrameStrata("Background")

control:SetBackdrop({
  bgFile = C.media.blank,  
  tile = false, tileSize = 0, edgeSize = T.mult, 
  insets = { left = 0, right = 0, top = 0, bottom = 0}
})
control:SetBackdropColor(unpack(C["media"].backdropcolor))
control:SetFrameStrata("BACKGROUND")
control:SetFrameLevel(1)
control:SetAlpha(.75)

local control_border = CreateFrame("Frame", nil, UIParent)
control_border:SetAllPoints(control)
control_border:SetFrameStrata("Background")
control_border:SetBackdrop({
	edgeFile = C["media"].blank, 
	edgeSize = T.mult, 
	insets = { left = T.mult, right = T.mult, top = T.mult, bottom = T.mult }
})
control_border:SetBackdropBorderColor(unpack(C["media"].backdropcolor))

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