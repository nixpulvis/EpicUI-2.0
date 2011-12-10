local T, C, L = unpack(Tukui)

local buffs = TukuiAurasPlayerBuffs
local debuffs = TukuiAurasPlayerDebuffs

buffs:ClearAllPoints()
debuffs:ClearAllPoints()
buffs:Point("TOPLEFT", UIParent, 22, -22)
debuffs:Point("TOP", buffs, "BOTTOM", 0, -84)