local T, C, L = unpack(Tukui)

local bsize = C.actionbar.buttonsize + 6
local TimeSinceLastUpdate = 0
local custombar = CreateFrame("Frame", "CustomTukuiActionBar", TukuiPlayer, "SecureHandlerStateTemplate")
custombar:CreatePanel("Default", bsize, bsize , "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -1, -8)

local function replaceadd(t, original, new)
	if #t == 0 then
		tinsert(t, new)
	else
		if tContains(t, original) then
			for i, v in ipairs(t) do
				if v == original then
					tremove(t, i)
					tinsert(t, i, new)	
					break
				end
			end
		else
			tinsert(t, new)
		end
	end
	return t
end

local function removebyvalue(t, value)
	if #t == 0 then return end
	if tContains(t, value) then
		for i, v in ipairs(t) do
			if v == value then
				tremove(t, i)
				break
			end
		end
	end
	return t
end

DropEpicSpells = function(current) 
	local infoType, info1, info2 = GetCursorInfo()
	local data = EpicUIDataPerChar.cabprimary
	
	if (infoType == "item") then
		EpicUIDataPerChar.cabprimary = replaceadd(data, current, info1)
	elseif (infoType == "spell") then
		local spellType, id = GetSpellBookItemInfo(info1, info2)
		EpicUIDataPerChar.cabprimary = replaceadd(data, current, GetSpellInfo(id))
	end
	ClearCursor()
end

DragEpicSpells = function(current) 
	removebyvalue(EpicUIDataPerChar.cabprimary, current)
end

local function MakeButtons()
	local custombutton = {}
	local custombuttondiv = {}
	local dropframe = CustomActionBarDropFrame
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	if #EpicUIDataPerChar.cabprimary == 0 then
		custombar:Hide()
		dropframe:Point("TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -1, -8)
	else
		custombarline1 = CreateFrame("Frame", nil, custombar)
		custombarline1:CreatePanel("Default", 2, 18, "BOTTOMRIGHT", custombar, "TOPRIGHT", -15, 0)
		custombarline1:SetFrameStrata("BACKGROUND")
		custombarline2 = CreateFrame("Frame", nil, custombar)
		custombarline2:CreatePanel("Default", 2, 18, "BOTTOMLEFT", custombar, "TOPLEFT", 15, 0)
		custombarline2:SetFrameStrata("BACKGROUND")
		custombar:Show()
		custombar:SetWidth((#EpicUIDataPerChar.cabprimary)*bsize - (#EpicUIDataPerChar.cabprimary-1))
	end
	
	for i, v in ipairs(EpicUIDataPerChar.cabprimary) do
		--button stuffz
		custombutton[i] = CreateFrame("Button", "PrimaryCustomButton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:Size(bsize, bsize)
		custombutton[i]:Point("TOPLEFT", custombar, "TOPLEFT", 0, 0)
		
		dropframe:ClearAllPoints()
		dropframe:Point("LEFT", custombutton[i], "RIGHT", -1, 0)
		
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", -1, 0)
			-- dividers
			custombuttondiv[i] = CreateFrame("Frame", "PrimaryCustomLine"..i, custombar)
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
		-- hoverover stuffz
		custombutton[i]:StyleButton()

		custombutton[i]:SetScript("OnReceiveDrag", function() DropEpicSpells(v) end)
		-- custombutton[i]:SetScript("OnClick", function() DragEpicSpells(v) end)
		-- cooldown stuffz
		local function OnUpdate(self, elapsed)
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
			if(TimeSinceLastUpdate > .10) then
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
					custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
					local start, duration, enabled = GetSpellCooldown(v)
					custombutton[i].startval = start
					custombutton[i]:SetAttribute("type", "spell")
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

local function Kill(more)
	local val =  #EpicUIDataPerChar.cabprimary
	if more then val = val + 1 end
	for i = 1, val do
		if _G["PrimaryCustomButton"..i] then
			_G["PrimaryCustomButton"..i]:Kill()
			_G["PrimaryCustomButton"..i] = nil
			_G["PrimaryCustomButton"..i.."CD"]:Kill()
		end
		if _G["PrimaryCustomLine"..i] then
			_G["PrimaryCustomLine"..i]:Kill()
			_G["PrimaryCustomLine"..i] = nil
		end
	end
end

local function MakeNewButtons(removing)
	if removing then Kill(true) else Kill(false) end
	MakeButtons()
end

hooksecurefunc("DropEpicSpells", function() MakeNewButtons() end)
hooksecurefunc("DragEpicSpells", function() MakeNewButtons(true) end)

-- Area To Add Spells
local dropframe = CreateFrame("Button", "CustomActionBarDropFrame", UIParent)
dropframe:Size(bsize, bsize)
dropframe:SetNormalTexture(C.media.plusicon)
dropframe:SetTemplate("Default")
dropframe:SetAlpha(0)
dropframe:StyleButton()
dropframe:SetScript("OnReceiveDrag", function() DropEpicSpells() MakeNewButtons() end)
dropframe:SetScript("OnUpdate", function()
	if CursorHasSpell() or CursorHasItem() then
		dropframe:SetAlpha(1)
	else
		dropframe:SetAlpha(0)
	end
end)

local f = CreateFrame("FRAME")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then
		if not EpicUIDataPerChar then EpicUIDataPerChar = {} end
		if not EpicUIDataPerChar.cabprimary then EpicUIDataPerChar.cabprimary = {} end
	else
		MakeNewButtons()
	end
end)