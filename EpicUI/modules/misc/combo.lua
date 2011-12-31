local T, C, L = unpack(Tukui)

if not C.unitframes.enable or C.unitframes.classiccombo then return end

TukuiCombo:ClearAllPoints()
TukuiCombo:SetParent(TukuiPlayer.Health)
TukuiCombo:Point("TOPLEFT", 2, -2)
TukuiCombo:Point("TOPRIGHT", -2, -2)
TukuiCombo:SetHeight(4)

-- resize combos
for i = 1, 5 do
	local bar = _G["TukuiComboBar"..i]
	bar:Height(4)
	
	if i == 1 or i == 2 then
		bar:Width(TukuiCombo:GetWidth() / 5 - 1)
	else
		bar:Width(TukuiCombo:GetWidth() / 5)
	end
end