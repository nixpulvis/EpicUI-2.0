local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

TukuiShiftBar:ClearAllPoints()
TukuiShiftBar:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "BOTTOMRIGHT", 3, 0)

local function PositionButtons()
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		local button = _G["ShapeshiftButton"..i]
		button:ClearAllPoints() 	
		if i == 1 then
			button:Point("BOTTOMLEFT", TukuiShiftBar, 0, 0)
		else
			local previous = _G["ShapeshiftButton"..i-1]
			button:Point("BOTTOM", previous, "TOP", 0, T.buttonspacing)
		end
	end
end

TukuiShapeShift:HookScript("OnEvent", PositionButtons)