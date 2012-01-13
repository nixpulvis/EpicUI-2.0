local T, C, L = unpack(Tukui)

local buffs = TukuiAurasPlayerBuffs
local debuffs = TukuiAurasPlayerDebuffs

buffs:ClearAllPoints()
debuffs:ClearAllPoints()
buffs:Point("TOPLEFT", UIParent, "TOPLEFT", 24, -22)
debuffs:Point("TOP", buffs, "BOTTOM", 0, -84)
