local T, C, L = unpack(Tukui)
-- DATA SOTRED AT: EpicUIDataPerChar.cabsecondary = {{id, tpye}, ...} AND EpicUIDataPerChar.cabprimary = {{id, tpye}, ...}
local BUTTON_SIZE = C.actionbar.buttonsize + 6
local b = {}
local emptybutton
local cabframe

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function ActiveTable()
	if GetActiveTalentGroup() == 1 then
		return _G["EpicUIDataPerChar"].primary
	else
		return _G["EpicUIDataPerChar"].secondary
	end
end

-- ListRemove: table, number --> table
local function ListRemove(id)
	for i, v in ipairs(ActiveTable()) do
		if id == v[1] then
			tremove(ActiveTable(), i)
			break
		end
	end
end

-- Addtolist: table, number, number --> table 
local function ListInsert(oldID, oldType, newID, newType)
	if not oldID then 
		tinsert(ActiveTable(), {newID, newType})
	else
		for i, v in ipairs(ActiveTable()) do
			if oldID == v[1] then
				ListRemove(oldID)
				tinsert(ActiveTable(), i, {newID, newType})
				break
			end
		end
	end
end

local function ButtonRemove(id)
	for i, v in ipairs(b) do
		if id == v.id then
			tremove(b, i)
			break
		end
	end
end


local function RepositionButtons()
	local lastPos = nil
	for i, v in ipairs(b) do
		b[i]:ClearAllPoints()
		if i == 1 then
			b[i]:Point("TOPLEFT", cabframe, "TOPLEFT", 2, -2)
		else
			b[i]:Point("LEFT", lastPos, "RIGHT", 3, 0)
		end
		lastPos = b[i]
	end
	emptybutton:ClearAllPoints()
	if lastPos then
		emptybutton:Point("LEFT", lastPos, "RIGHT", 3, 0)
	else
		emptybutton:Point("TOPLEFT", cabframe, "TOPLEFT", 2, -2)
	end
end

-- CreateButton: number, string
local function CreateButton(id, metatype)
	local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	button:Size(BUTTON_SIZE, BUTTON_SIZE)
	
	button.tex = button:CreateTexture(nil, "BORDER")
	button.tex:SetTexCoord(.08, .92, .08, .92)
	button.tex:SetAllPoints()
	
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cooldown:SetAllPoints(button.tex)				
	-- button:StyleButton() --FIX ME
	
	local function Suicide(self)
		ButtonRemove(self.id)
		ListRemove(self.id)
		self:Kill()
		self.cooldown:Kill()
		self = nil
	end
	
	local function SetCooldownTimer(self)
		local start, duration, enabled
		if self.metatype == "spell" then
			start, duration, enabled = GetSpellCooldown(self.id)
		else
			start, duration, enabled = GetItemCooldown(self.id)
		end
		
		self.cooldown:SetAlpha(1)
		if enabled == 0 then
			self.tex:SetVertexColor(.35, .35, .35)
		elseif start ~= 0 then
			self.tex:SetVertexColor(1, 1, 1)
			self.cooldown:SetCooldown(start, duration)
		elseif duration == 0 then
			self.cooldown:SetAlpha(0)
			self.cooldown:SetCooldown(0, 0)
		end
	end
	
	local function SetDynamic(id, metatype)		
		local metainfo 
		if metatype == "spell" then
			metainfo = {GetSpellInfo(id)} 
		else
			metainfo = {GetItemInfo(id)}
		end

		button.id = id
		button.metatype = metatype
		button.metainfo = metainfo
		
		button:SetAttribute("type", metatype)
		button:SetAttribute(metatype, metainfo[1])
		
		button.tex:SetTexture(metainfo[10] or metainfo[3])
		SetCooldownTimer(button)
	end
	SetDynamic(id, metatype)
	
	local function ShowTooltip(self)
		GameTooltip:SetOwner(TukuiTooltipAnchor,"ANCHOR_TOPRIGHT", 0, 5); 
		GameTooltip:SetClampedToScreen(true);
		GameTooltip:ClearLines()
		if self.metatype == "spell" then
			GameTooltip:SetSpellByID(self.id)
		elseif self.metatype == "item" then
			GameTooltip:SetItemByID(self.id)
		end
		-- GameTooltip:_G["Set"..firstToUpper(self.metatype).."ByID"](self.id)
		GameTooltip:Show() 
	end
	
	local function Dropped(self)
		if InCombatLockdown() then return end
		local newID
		local newType, info1, info2 = GetCursorInfo()
		if not newType then return end
		
		if newType == "spell" then
			_,newID = GetSpellBookItemInfo(info1, info2)
		else
			newID = info1
		end
		
		ClearCursor()
		_G["Pickup"..firstToUpper(self.metatype)](self.id)
		
		self:SetButtonState("NORMAL", false)
		ListInsert(self.id, self.metatype, newID, newType)
		SetDynamic(newID, newType)
	end
	
	local function Dragged(self)
		if InCombatLockdown() then return end
		_G["Pickup"..firstToUpper(self.metatype)](self.id)
		
		Suicide(self)
		RepositionButtons()
	end
	
	local function DidEnter(self)
		if GetCursorInfo() then
			self:SetButtonState("NORMAL", true)
		else
			self:SetButtonState("NORMAL", false)
		end
	end
	
	local function OnEvent(self, event)
		if event == "SPELL_UPDATE_COOLDOWN" then
			SetCooldownTimer(self)
		elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
			Suicide(self)
		end
	end
	
	button:RegisterForDrag("LeftButton")	
	button:RegisterEvent("PLAYER_ENTERING_WORLD")
	button:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:RegisterEvent("BAG_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", OnEvent)
	button:SetScript("OnDragStart", Dragged)
	button:SetScript("OnReceiveDrag", Dropped)
	button:SetScript("OnEnter", DidEnter)
	button:SetScript("OnMouseUp", Dropped)
	button:SetScript("OnEnter", ShowTooltip)
	button:SetScript("OnLeave", function(self) GameTooltip_Hide() end)
	
	return button
end


-- Drop Button
local function MakeDropButton()
	local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	button:SetTemplate()
	button:Size(BUTTON_SIZE+2, BUTTON_SIZE+4)
	button:SetAlpha(0)
	
	local function Dropped(self)
		if InCombatLockdown() then return end
		local newID
		local newType, info1, info2 = GetCursorInfo()
		if not newType then return end
		
		if newType == "spell" then
			_,newID = GetSpellBookItemInfo(info1, info2)
		else
			newID = info1
		end

		ListInsert(self.id, self.metatype, newID, newType)
		tinsert(b, CreateButton(newID, newType))
		RepositionButtons()
		ClearCursor()
	end
	
	local function Visibility(self, event)
		if event == "ACTIONBAR_SHOWGRID" then
			if InCombatLockdown() then return end
			self:SetAlpha(1)
		elseif event == "ACTIONBAR_HIDEGRID" then
			self:SetAlpha(0)
		end
	end
	
	button:RegisterEvent("ACTIONBAR_SHOWGRID")
	button:RegisterEvent("ACTIONBAR_HIDEGRID")
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnReceiveDrag", Dropped)
	button:SetScript("OnMouseUp", Dropped)
	button:SetScript("OnEvent", Visibility)

	return button
end

local function CreateButtonFrame()
	cabframe = CreateFrame("Frame", "EpicUICustomactionbar", UIParent)
	cabframe:CreatePanel("Default", 1, BUTTON_SIZE+4, "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -3)
	cabframe:SetAlpha(0)
	
	local function UpdateFrame()
		if #ActiveTable() > 0 then
			cabframe:SetAlpha(1)
			cabframe:Width((#ActiveTable()*(BUTTON_SIZE+3))+1)
		else
			cabframe:SetAlpha(0)
		end
		
		local divider = {}
		for i = 1, #ActiveTable()-1 do
			divider[i] = CreateFrame("Frame", nil, cabframe)
			if i == 1 then
				divider[i]:CreatePanel("Default", 1, BUTTON_SIZE+4, "BOTTOMLEFT", cabframe, "BOTTOMLEFT", BUTTON_SIZE+3, 0)
			else
				divider[i]:CreatePanel("Default", 1, BUTTON_SIZE+4, "BOTTOMLEFT", divider[i-1], "BOTTOMLEFT", BUTTON_SIZE+3, 0)
			end
		end
	end
	UpdateFrame()

	cabframe:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	cabframe:RegisterEvent("ACTIONBAR_SHOWGRID")
	cabframe:RegisterEvent("ACTIONBAR_HIDEGRID")
	cabframe:SetScript("OnEvent", UpdateFrame)
end

local function InitButtons()
	for i, v in ipairs(ActiveTable()) do
		b[i] = CreateButton(v[1], v[2])   --v[1] is the ID, v[2] is the metatype
	end
	emptybutton = MakeDropButton()
	RepositionButtons()
end
	
local f = CreateFrame("FRAME")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then
		if not EpicUIDataPerChar then EpicUIDataPerChar = {} end
		if not EpicUIDataPerChar.primary then EpicUIDataPerChar.primary = {} end
		if not EpicUIDataPerChar.secondary then EpicUIDataPerChar.secondary = {} end
	else
		CreateButtonFrame()
		InitButtons()	
	end
end)
	
	
	
	
	