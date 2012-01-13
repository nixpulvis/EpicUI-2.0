local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
-- killing raid frames

local Kill = CreateFrame("Frame")
Kill:RegisterEvent("ADDON_LOADED")
Kill:SetScript("OnEvent", function(self, event, addon)
	
	-- disable Blizzard party & raid frame if our Raid Frames are loaded
	if addon == "EpicUI_Raid" or addon == "EpicUI_Raid_Healing" then   
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)

		local function KillRaidFrame()
			CompactRaidFrameManager:UnregisterAllEvents()
			if not InCombatLockdown() then CompactRaidFrameManager:Hide() end

			local shown = CompactRaidFrameManager_GetSetting("IsShown")
			if shown and shown ~= "0" then
				CompactRaidFrameManager_SetSetting("IsShown", "0")
			end
		end

		hooksecurefunc("CompactRaidFrameManager_UpdateShown", function()
			KillRaidFrame()
		end)

		KillRaidFrame()

		-- kill party 1 to 5
		local function KillPartyFrame()
			CompactPartyFrame:Kill()

			for i=1, MEMBERS_PER_RAID_GROUP do
				local name = "CompactPartyFrameMember" .. i
				local frame = _G[name]
				frame:UnregisterAllEvents()
			end			
		end
			
		for i=1, MAX_PARTY_MEMBERS do
			local name = "PartyMemberFrame" .. i
			local frame = _G[name]

			frame:Kill()

			_G[name .. "HealthBar"]:UnregisterAllEvents()
			_G[name .. "ManaBar"]:UnregisterAllEvents()
		end
		
		if CompactPartyFrame then
			KillPartyFrame()
		elseif CompactPartyFrame_Generate then -- 4.1
			hooksecurefunc("CompactPartyFrame_Generate", KillPartyFrame)
		end		
	end
end)