local T, C, L = unpack(Tukui)

local bsize = C.actionbar.buttonsize + 6
local TimeSinceLastUpdate = 0
local MAXSPELLS =  6

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

local function GetSpellID(spell)
	local name
	for i = 1, 100000 do
		name = GetSpellInfo(i)
		if name == spell then
			return i
		end
	end
end

local function ActiveSpells()
	if GetActiveTalentGroup() == 1 then
		return EpicUIDataPerChar.cabprimary
	else
		return EpicUIDataPerChar.cabsecondary
	end
end

-- called when adding a new spell to the AB (grab true when gragging to a
-- location that has a spell
DropEpicSpells = function(self, current, grab)
	if InCombatLockdown() then return end
	
	if CursorHasSpell() or CursorHasItem() then
		local infoType, info1, info2 = GetCursorInfo()
		local data = ActiveSpells()
		
		-- data management
		if GetActiveTalentGroup() == 1 then
			if (infoType == "item") then
				EpicUIDataPerChar.cabprimary = replaceadd(data, current, info1)
			elseif (infoType == "spell") then
				local spellType, id = GetSpellBookItemInfo(info1, info2)
				EpicUIDataPerChar.cabprimary = replaceadd(data, current, GetSpellInfo(id))
			end
		else	
			if (infoType == "item") then
				EpicUIDataPerChar.cabsecondary = replaceadd(data, current, info1)
			elseif (infoType == "spell") then
				local spellType, id = GetSpellBookItemInfo(info1, info2)
				EpicUIDataPerChar.cabsecondary = replaceadd(data, current, GetSpellInfo(id))
			end	
		end
	
		ClearCursor()
		if grab then
			PickupSpell(GetSpellID(current))
		end
	end
end

-- called when removing a spell
DragEpicSpells = function(current) 
	if InCombatLockdown() then return end
	removebyvalue(ActiveSpells(), current)
	
	PickupSpell(GetSpellID(current))
end

local function SetClickSettings(self, v)
	if InCombatLockdown() then return end
	local name = GetItemInfo(v)
	-- Trinkets (Expand for all equiped items)
	if IsEquippedItem(name) == 1 then
		local invSlot
		for i = 0, 19 do
			if GetInventoryItemID("player", i) == v then
				invSlot = i
			end
		end
		self:SetAttribute("type", "item");
		self:SetAttribute("item", invSlot)
	-- spells
	elseif GetSpellInfo(v) == v then
		self:SetAttribute("type", "spell")
		self:SetAttribute("spell", v)
	-- Non Equiped Items
	elseif IsEquippableItem(name) == nil and type(v) == "number" then
			self:SetAttribute("type", "item");
			self:SetAttribute("item", GetItemInfo(v))
	end
end

local function MakeButtons()
	-- going to set up two layers, first layer is the action button, second layer is another button that is the drag and drop
	-- layer. Both look the same. (alpha (0) maybe)
	
	local custombutton = {}
	--local custombuttonover = {}
	local dropframe = CustomActionBarDropFrame
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	if #ActiveSpells() == 0 then
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
		custombar:SetWidth((#ActiveSpells())*bsize - (#ActiveSpells()-1))
	end
	
	for i, v in ipairs(ActiveSpells()) do
		--button stuffz
		custombutton[i] = CreateFrame("Button", "PrimaryCustomButton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:Size(bsize, bsize)
		custombutton[i]:Point("TOPLEFT", custombar, "TOPLEFT", 0, 0)
		
		dropframe:ClearAllPoints()
		dropframe:Point("LEFT", custombutton[i], "RIGHT", -1, 0)
		
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", -1, 0)
			-- dividers
			custombutton[i].div = CreateFrame("Frame", "PrimaryCustomLine"..i, custombar)
			custombutton[i].div:CreatePanel("Default", 1, bsize, "TOPRIGHT", custombutton[i], "TOPLEFT", 1, 0)
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
		
		custombutton[i]:RegisterForDrag("LeftButton")
		custombutton[i]:SetScript("OnDragStart", function(self) DragEpicSpells(v) end)
		
		custombutton[i].mouse = CreateFrame("Button", nil, custombutton[i])
		custombutton[i].mouse:SetAllPoints()
		custombutton[i].mouse:SetScript("OnReceiveDrag", function(self) DropEpicSpells(self, v, true) end)
		custombutton[i].mouse:SetScript("OnClick", function(self) DropEpicSpells(self, v, true) end)
		custombutton[i].mouse:SetScript("OnUpdate", function(self)
			if CursorHasSpell() or CursorHasItem() then
				self:EnableMouse(true)
			else
				self:EnableMouse(false)
			end
		end)
		
		-- cooldown stuffz
		local function OnUpdate(self, elapsed)
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
			if(TimeSinceLastUpdate > .10) then
				SetClickSettings(self, v)
				local name = GetItemInfo(v)
				-- Trinkets (Expand for all equiped items)
				if IsEquippedItem(name) == 1 then
					local invSlot
					for i = 0, 19 do
						if GetInventoryItemID("player", i) == v then
							invSlot = i
						end
					end
					custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
					local start, duration, enabled = GetItemCooldown(v)
					custombutton[i].startval = start
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				-- spells
				elseif GetSpellInfo(v) == v then
					custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
					local start, duration, enabled = GetSpellCooldown(v)
					custombutton[i].startval = start
					if enabled ~= 0 then
						custombutton[i].texture:SetVertexColor(1,1,1)
						custombutton[i].cooldown:SetCooldown(start, duration)
					else
						custombutton[i].texture:SetVertexColor(.35, .35, .35)
					end
				-- Non Equiped Items
				elseif IsEquippableItem(name) == nil then
					if type(v) == "number" then
						custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
						local start, duration, enabled = GetItemCooldown(v)
						custombutton[i].startval = start
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
		-- tooltip
		custombutton[i]:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(TukuiTooltipAnchor,"ANCHOR_TOPRIGHT", 0, 5); 
			GameTooltip:SetClampedToScreen(true);
			GameTooltip:ClearLines()
			local name = GetItemInfo(v)
			if GetSpellInfo(v) == v then
				GameTooltip:SetSpellByID(GetSpellID(v))
			else
				GameTooltip:SetItemByID(v)
			end
			GameTooltip:Show() 
		end)
		custombutton[i]:SetScript("OnLeave", function(self) GameTooltip_Hide() end);
		custombutton[i]:EnableMouse(true)
		
		custombutton[i]:SetScript("OnUpdate", OnUpdate)
	end
end

local function KillButtons()
	for i = 1, MAXSPELLS+1 do
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

local function MakeNewButtons()
	if InCombatLockdown() then return end
	KillButtons()
	MakeButtons()
end

hooksecurefunc("DropEpicSpells", function() MakeNewButtons() end)
hooksecurefunc("DragEpicSpells", function() MakeNewButtons() end)

-- Area To Add Spells
local dropframe = CreateFrame("Button", "CustomActionBarDropFrame", UIParent)
dropframe:Size(bsize, bsize)
dropframe:SetTemplate("Default")
dropframe:SetAlpha(0)
dropframe:StyleButton()
dropframe:SetScript("OnReceiveDrag", function() if #ActiveSpells() < MAXSPELLS then DropEpicSpells() MakeNewButtons() end end)
dropframe:SetScript("OnMouseUp", function() if #ActiveSpells() < MAXSPELLS then DropEpicSpells() MakeNewButtons() end end)
dropframe:SetScript("OnUpdate", function()
	if #ActiveSpells() < MAXSPELLS then
		dropframe:SetNormalTexture(C.media.plusicon)
	else
		dropframe:SetNormalTexture(C.media.closeicon)
	end
	
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
	if not EpicUIDataPerChar then EpicUIDataPerChar = {} end
	if not EpicUIDataPerChar.cabprimary then EpicUIDataPerChar.cabprimary = {} end
	if not EpicUIDataPerChar.cabsecondary then EpicUIDataPerChar.cabsecondary = {} end
	
	MakeNewButtons()
end)