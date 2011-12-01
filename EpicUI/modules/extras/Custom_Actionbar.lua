local T, C, L = unpack(Tukui)

--silly bug fix
if not C.customactionbar then
	C.customactionbar.CABprimary = {}
	C.customactionbar.CABsecondary = {}
end

local bsize = C.actionbar.buttonsize + 6
local TimeSinceLastUpdate = 0
local custombar = CreateFrame("Frame", "CustomTukuiActionBar", TukuiPlayer, "SecureHandlerStateTemplate")
custombar:CreatePanel("Default", 1, bsize , "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -1, -8)
local totalprimary = table.getn(C.customactionbar.CABprimary)
local totalsecondary = table.getn(C.customactionbar.CABsecondary)
if (totalprimary ~= 0 or totalsecondary ~= 0) then
	custombarline1 = CreateFrame("Frame", nil, custombar)
	custombarline1:CreatePanel("Default", 2, 18, "BOTTOMRIGHT", custombar, "TOPRIGHT", -15, 0)
	custombarline1:SetFrameStrata("BACKGROUND")
	custombarline2 = CreateFrame("Frame", nil, custombar)
	custombarline2:CreatePanel("Default", 2, 18, "BOTTOMLEFT", custombar, "TOPLEFT", 15, 0)
	custombarline2:SetFrameStrata("BACKGROUND")
else
	custombar:Hide()
end

local function MakePrimaryButtons()
	local custombutton = {}
	local custombuttondiv = {}
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	custombar:SetWidth((totalprimary)*bsize - (totalprimary-1))
	
	-- spell stuffz
	for i, v in ipairs(C.customactionbar.CABprimary) do
		--button stuffz
		custombutton[i] = CreateFrame("Button", "primarycustombutton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:Size(bsize, bsize)
		custombutton[i]:Point("TOPLEFT", custombar, "TOPLEFT", 0, 0)
		
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", -1, 0)
			-- dividers
			custombuttondiv[i] = CreateFrame("Frame", "primarycustomline"..i, custombar)
			custombuttondiv[i]:CreatePanel("Default", 1, bsize, "TOPRIGHT", custombutton[i], "TOPLEFT", 1, 0)
		end
		-- texture settup
		custombutton[i].texture = custombutton[i]:CreateTexture(nil, "BORDER")
		custombutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		custombutton[i].texture:Point("TOPLEFT", custombutton[i] ,"TOPLEFT", 2, -2)
		custombutton[i].texture:Point("BOTTOMRIGHT", custombutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		custombutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", custombutton[i], "CooldownFrameTemplate")
		custombutton[i].cooldown:SetAllPoints(custombutton[i].texture)				
		-- text settup
		custombutton[i].value = custombutton[i]:CreateFontString(nil, "ARTWORK")
		custombutton[i].value:SetFont(C.media.font, 8, "MONOCHROMEOUTLINE")
		custombutton[i].value:SetText("ERROR")
		custombutton[i].value:SetTextColor(1, 0, 0)
		custombutton[i].value:Hide()
		custombutton[i].value:Point("CENTER", custombutton[i], "CENTER")
		-- hoverover stuffz
		custombutton[i]:StyleButton()
		-- cooldown stuffz
		local function OnUpdate(self, elapsed)
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
			if(TimeSinceLastUpdate > .25) then
				local name = GetItemInfo(v)
				if IsEquippedItem(name) == 1 then
					custombutton[i].value:Hide()
					local trinket1id = GetInventoryItemID("player", 13)
					local trinket2id = GetInventoryItemID("player", 14)
					local var = 0
					if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
					custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
					local start, duration, enabled = GetItemCooldown(v)
					custombutton[i].startval = start
					custombutton[i]:SetAttribute("type", "item");
					custombutton[i]:SetAttribute("item", var)
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				elseif GetSpellInfo(v) == v then
					custombutton[i].value:Hide()
					custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
					local start, duration, enabled = GetSpellCooldown(v)
					custombutton[i].startval = start
					custombutton[i]:SetAttribute("type", "spell");
					custombutton[i]:SetAttribute("spell", v)
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				elseif IsEquippableItem(name) == nil then
					if type(v) == "number" then
						custombutton[i].value:Hide()
						custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
						local start, duration, enabled = GetItemCooldown(v)
						custombutton[i].startval = start
						custombutton[i]:SetAttribute("type", "item");
						custombutton[i]:SetAttribute("item", GetItemInfo(v))
						if enabled ~= 0 then
							custombutton[i].texture:SetVertexColor(1,1,1)
							custombutton[i].cooldown:SetCooldown(start, duration)
						else
							custombutton[i].texture:SetVertexColor(.35, .35, .35)
						end
					end
				else
					custombutton[i].value:Show()
				end
			
				if custombutton[i].startval == 0 then
					custombutton[i].cooldown:SetAlpha(0)
				else
					custombutton[i].cooldown:SetAlpha(1)
				end
				TimeSinceLastUpdate = 0
			end
		end
		custombutton[i]:SetScript("OnUpdate", OnUpdate)
	end
end

local function MakeSecondaryButtons()
	local custombutton = {}
	local custombuttondiv = {}
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	custombar:SetWidth((totalsecondary)*bsize - (totalsecondary-1))
	
	-- spell stuffz
	for i, v in ipairs(C.customactionbar.CABsecondary) do	
		--button stuffz
		custombutton[i] = CreateFrame("Button", "secondarycustombutton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:Size(bsize, bsize)
		custombutton[i]:Point("TOPLEFT", custombar, "TOPLEFT", 0, 0)
		
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", -1, 0)
			-- dividers
			custombuttondiv[i] = CreateFrame("Frame", "secondarycustomline"..i, custombar)
			custombuttondiv[i]:CreatePanel("Default", 1, bsize, "TOPRIGHT", custombutton[i], "TOPLEFT", 1, 0)
		end
		-- texture settup
		custombutton[i].texture = custombutton[i]:CreateTexture(nil, "BORDER")
		custombutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		custombutton[i].texture:Point("TOPLEFT", custombutton[i] ,"TOPLEFT", 2, -2)
		custombutton[i].texture:Point("BOTTOMRIGHT", custombutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		custombutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", custombutton[i], "CooldownFrameTemplate")
		custombutton[i].cooldown:SetAllPoints(custombutton[i].texture)	
		-- text settup
		custombutton[i].value = custombutton[i]:CreateFontString(nil, "ARTWORK")
		custombutton[i].value:SetFont(C.media.font, 8, "MONOCHROMEOUTLINE")
		custombutton[i].value:SetText("ERROR")
		custombutton[i].value:SetTextColor(1, 0, 0)
		custombutton[i].value:Hide()
		custombutton[i].value:Point("CENTER", custombutton[i], "CENTER")
		-- hoverover stuffz
		custombutton[i]:StyleButton()
		-- cooldown stuffz
		local function OnUpdate(self, elapsed)
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
			if(TimeSinceLastUpdate > .5) then
				local name = GetItemInfo(v)
				if IsEquippedItem(name) == 1 then
					custombutton[i].value:Hide()
					local trinket1id = GetInventoryItemID("player", 13)
					local trinket2id = GetInventoryItemID("player", 14)
					local var = 0
					if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
					custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
					local start, duration, enabled = GetItemCooldown(v)
					custombutton[i].startval = start
					custombutton[i]:SetAttribute("type", "item");
					custombutton[i]:SetAttribute("item", var)
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				elseif GetSpellInfo(v) == v then
					custombutton[i].value:Hide()
					custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
					local start, duration, enabled = GetSpellCooldown(v)
					custombutton[i].startval = start
					custombutton[i]:SetAttribute("type", "spell");
					custombutton[i]:SetAttribute("spell", v)
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				elseif IsEquippableItem(name) == nil then
					if type(v) == "number" then
						custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
						local start, duration, enabled = GetItemCooldown(v)
						custombutton[i].startval = start
						custombutton[i]:SetAttribute("type", "item");
						custombutton[i]:SetAttribute("item", GetItemInfo(v))
						if enabled ~= 0 then
							custombutton[i].texture:SetVertexColor(1,1,1)
							custombutton[i].cooldown:SetCooldown(start, duration)
						else
							custombutton[i].texture:SetVertexColor(.35, .35, .35)
						end
					end
				else
					custombutton[i].value:Show()
				end

				if custombutton[i].startval == 0 then
					custombutton[i].cooldown:SetAlpha(0)
				else
					custombutton[i].cooldown:SetAlpha(1)
				end
				TimeSinceLastUpdate = 0
			end
		end
		custombutton[i]:SetScript("OnUpdate", OnUpdate)
	end
end

local function Kill()
		for i = 1, totalprimary do
			if _G["primarycustombutton"..i] then
				_G["primarycustombutton"..i]:Kill()
				_G["primarycustombutton"..i] = nil
				_G["primarycustombutton"..i.."CD"]:Kill()
			end
			if _G["primarycustomline"..i] then
				_G["primarycustomline"..i]:Kill()
				_G["primarycustomline"..i] = nil
			end
		end

		for i = 1, totalsecondary do
			if _G["secondarycustombutton"..i] then
				_G["secondarycustombutton"..i]:Kill()
				_G["secondarycustombutton"..i] = nil
				_G["secondarycustombutton"..i.."CD"]:Kill()
			end
			if _G["secondarycustomline"..i] then
				_G["secondarycustomline"..i]:Kill()
				_G["secondarycustomline"..i] = nil
			end
		end	
end

local function OnEvent(self, event)
	Kill()
	if GetActiveTalentGroup() == 1 then
		MakePrimaryButtons()
	else
		MakeSecondaryButtons()
	end
end

local tslu = 0
local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:SetScript("OnEvent", OnEvent)