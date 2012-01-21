local T, C, L = unpack(Tukui)

local function DisableTukRaids()
	if IsAddOnLoaded("Tukui_Raid") then
		DisableAddOn("Tukui_Raid")
	end
	if IsAddOnLoaded("Tukui_Raid_Healing") then
		DisableAddOn("Tukui_Raid_Healing")
	end
end

StaticPopupDialogs["TUKUIDISABLE_RAID"] = {
	text = "EpicUI no longer uses Tukui's raidframes. Click Disable to turn them off.",
	button1 = "Disable",
	button2 = "Cancel",
	OnAccept = function() 
		DisableTukRaids()
		ReloadUI()
	end,
	OnCancel = function() return end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}

StaticPopupDialogs["EPICUIDISABLE_RAID"] = {
	text = L.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableTukRaids() DisableAddOn("EpicUI_Raid_Healing") EnableAddOn("EpicUI_Raid") ReloadUI() end,
	OnCancel = function() DisableTukRaids() EnableAddOn("EpicUI_Raid_Healing") DisableAddOn("EpicUI_Raid") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}

local EpicUIOnLogon = CreateFrame("Frame")
EpicUIOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
EpicUIOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	if (IsAddOnLoaded("EpicUI_Raid") and IsAddOnLoaded("EpicUI_Raid_Healing")) then
		StaticPopup_Show("EPICUIDISABLE_RAID")	
	elseif (IsAddOnLoaded("Tukui_Raid") or IsAddOnLoaded("Tukui_Raid_Healing")) then
		StaticPopup_Show("TUKUIDISABLE_RAID")
	end
end)