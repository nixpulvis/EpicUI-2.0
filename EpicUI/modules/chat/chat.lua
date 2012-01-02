local T, C, L = unpack(Tukui)
--[[
for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	local chatFrameId = frame:GetID()
	
	-- set the size of chat frames
	frame:Size(T.InfoLeftRightWidth + 1, T.Scale(500))
	-- tell wow that we are using new size
	SetChatWindowSavedDimensions(chatFrameId, T.Scale(T.InfoLeftRightWidth + 1), T.Scale(500))
	-- save new default position and dimension
	FCF_SavePositionAndDimensions(frame)
		print("Setting Up")
end]]

-- Addons Background (same size as right chat background)
local bg = CreateFrame("Frame", "AddonBGPanel", UIParent)
bg:CreatePanel("Transparent", 1, 1, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4)
bg:SetAllPoints(TukuiChatBackgroundRight)

-- toggle in-/outfight
bg:RegisterEvent("PLAYER_ENTERING_WORLD")
bg:RegisterEvent("PLAYER_LOGIN")
bg:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- Hide
		bg:Hide()
		if IsAddOnLoaded("Recount") then Recount_MainWindow:Hide() end
		if IsAddOnLoaded("Omen") then OmenAnchor:Hide() end
		if IsAddOnLoaded("Skada") then Skada:SetActive(false) end
		if IsAddOnLoaded("Numeration") then NumerationFrame:Hide() end
		if TukuiChatBackgroundRight then TukuiChatBackgroundRight:Show() end
		_G["ChatFrame4"]:Show()
		_G["ChatFrame4".."Tab"]:Show()
	elseif event == "PLAYER_ENTERING_WORLD" then
		ChatFrame_AddChannel(_G["ChatFrame4"], L.chat_trade)
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "LOOT")
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "MONEY")
		ChatFrame_AddMessageGroup(_G["ChatFrame4"], "SKILL")
	end
end)

local toggle = CreateFrame("Frame", nil, UIParent)
toggle:CreatePanel("Default", 20, 20, "BOTTOMLEFT", TukuiBar1, "BOTTOMRIGHT", 3, 0)
toggle.t = toggle:CreateFontString(toggle, "OVERLAY")
toggle.t:SetPoint("CENTER")
toggle.t:SetFont(C.media.font, C.datatext.fontsize)
toggle.t:SetText("T")

toggle:SetScript("OnMouseDown", function(self)
			if TukuiChatBackgroundRight:IsShown() then
				TukuiChatBackgroundRight:Hide()
				TukuiTabsRightBackground:Hide()
				_G["ChatFrame4"]:Hide()
				_G["ChatFrame4Tab"]:Hide()
				AddonBGPanel:Show()
				if IsAddOnLoaded("Recount") then _G.Recount.MainWindow:Show() end
				if IsAddOnLoaded("Omen") then OmenAnchor:Show() end
				if IsAddOnLoaded("Skada") then Skada:SetActive(true) end
				if IsAddOnLoaded("Numeration") then NumerationFrame:Show() end
			else
				TukuiChatBackgroundRight:Show() 
				TukuiTabsRightBackground:Show() 
				_G["ChatFrame4"]:Show()
				_G["ChatFrame4Tab"]:Show()
				AddonBGPanel:Hide()
				if IsAddOnLoaded("Recount") then Recount_MainWindow:Hide() end
				if IsAddOnLoaded("Omen") then OmenAnchor:Hide() end
				if IsAddOnLoaded("Skada") then Skada:SetActive(false) end
				if IsAddOnLoaded("Numeration") then NumerationFrame:Hide() end
			end 
		end)