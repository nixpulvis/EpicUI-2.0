local T, C, L = unpack(Tukui)

local buffs = TukuiAurasPlayerBuffs
local debuffs = TukuiAurasPlayerDebuffs

local function MoveBuffs(anchor)
	buffs:ClearAllPoints()
	debuffs:ClearAllPoints()
	buffs:Point("TOPRIGHT", anchor, "TOPLEFT", -35, 0)
	debuffs:Point("TOP", buffs, "BOTTOM", 0, -84)
end

if TukuiDataPerChar.hidedatabars == true then
	MoveBuffs("TukuiMinimap")
else
	MoveBuffs("TukuiDataBarBG")
end

TukuiDataBarToggle:HookScript("OnMouseDown", function(self) 
	if T.databars[1]:IsShown() then
		MoveBuffs("TukuiDataBarBG")
	else
		MoveBuffs("TukuiMinimap")
	end
end)