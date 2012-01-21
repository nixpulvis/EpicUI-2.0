local T, C, L = unpack(Tukui)

if TukuiBar3:IsShown() then
	TukuiTooltipAnchor:SetPoint("BOTTOMRIGHT", TukuiBar3, "BOTTOMRIGHT", 0, 10)
elseif C.chat.background and TukuiChatBackgroundRight then
	TukuiTooltipAnchor:SetPoint("BOTTOMRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", 0, -TukuiInfoRight:GetHeight())
else
	TukuiTooltipAnchor:SetPoint("BOTTOMRIGHT", TukuiInfoRight)
end