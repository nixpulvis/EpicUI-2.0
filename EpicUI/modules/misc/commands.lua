local T, C, L = unpack(Tukui)

-- switch to heal layout via a command
SLASH_TUKUIHEAL1 = "/heal"
SlashCmdList.TUKUIHEAL = function()
	DisableAddOn("EpicUI_Raid")
	EnableAddOn("EpicUI_Raid_Healing")
	ReloadUI()
end

-- switch to dps layout via a command
SLASH_TUKUIDPS1 = "/dps"
SlashCmdList.TUKUIDPS = function()
	DisableAddOn("EpicUI_Raid_Healing")
	EnableAddOn("EpicUI_Raid")
	ReloadUI()
end