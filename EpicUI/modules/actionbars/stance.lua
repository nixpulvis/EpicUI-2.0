local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

TukuiShiftBar:ClearAllPoints()
TukuiShiftBar:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "BOTTOMRIGHT", 3, 0)

TukuiShapeShift:RegisterEvent("PLAYER_LOGIN")
TukuiShapeShift:HookScript("OnEvent", function(self, event, ...)
	if event ~= "PLAYER_LOGIN" then return end
	_G["ShapeshiftButton1"]:ClearAllPoints()
	_G["ShapeshiftButton1"]:Point("BOTTOMLEFT", TukuiShiftBar, 2, 0)
end)

-- Totem Bar
if T.myclass == "SHAMAN" then
	if MultiCastActionBarFrame then
		local dummy = CreateFrame("FRAME")
		MultiCastActionBarFrame.SetPoint = dummy.SetPoint
		MultiCastRecallSpellButton.SetPoint = dummy.SetPoint
		
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:Point("BOTTOMLEFT", TukuiShiftBar, "BOTTOMLEFT", 0, -3)
	end
end 