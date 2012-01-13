local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

TukuiShiftBar:ClearAllPoints()
TukuiShiftBar:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "BOTTOMRIGHT", 3, 0)

-- Totem Bar
if T.myclass == "SHAMAN" then
	if MultiCastActionBarFrame then
		-- MultiCastActionBarFrame:ClearAllPoints()
		-- MultiCastActionBarFrame:Point("TOPLEFT", TukuiShiftBar, "BOTTOMLEFT", -3, 3)
	end
end 