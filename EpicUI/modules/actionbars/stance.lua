local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

TukuiShiftBar:ClearAllPoints()
TukuiShiftBar:Point("TOPLEFT", TukuiChatBackgroundLeft, "TOPLEFT", 0, 0)

-- Border for the shapeshift buttons
local ssBG = CreateFrame("Frame", nil, TukuiShiftBar)
ssBG:Point("BOTTOMLEFT", TukuiShiftBar, "TOPLEFT", 0, 0)
ssBG:SetFrameStrata("BACKGROUND")
ssBG:SetFrameLevel(0)
ssBG:Height(T.petbuttonsize + (T.buttonspacing * 2))
ssBG:SetTemplate("Transparent")

TukuiShapeShift:HookScript("OnEvent", function(self, event, ...)
	if T.myclass == "SHAMAN" then return end
	if event == "PLAYER_LOGIN" or event == "UPDATE_SHAPESHIFT_FORMS" then
		if InCombatLockdown() then return end
		ssBG:Width((T.petbuttonsize * GetNumShapeshiftForms()) + (T.buttonspacing * (GetNumShapeshiftForms() + 1)))
	end
	
	local button
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ShapeshiftButton"..i]
		button:SetParent(ssBG)
		if i == 1 then
			button:ClearAllPoints()
			button:Point("BOTTOMLEFT", ssBG, "BOTTOMLEFT", T.buttonspacing, T.buttonspacing)
		end
	end
end)

if T.myclass == "SHAMAN" then
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:Point("BOTTOMLEFT", ssBG, "BOTTOMLEFT", T.buttonspacing, T.buttonspacing)
	ssBG:Width((T.petbuttonsize * 6) + (T.buttonspacing * 7))
end