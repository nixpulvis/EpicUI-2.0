local T, C, L = unpack(Tukui)
-- DATA SOTRED AT: EpicUIDataPerChar.cabsecondary = {{id, tpye}, ...} AND EpicUIDataPerChar.cabprimary = {{id, tpye}, ...}
local BUTTON_SIZE = C.actionbar.buttonsize + 6
local b = {} 			-- buttons actually stored here
local emptybutton 		-- this is the drop buttoon
local cabframe 			-- background of the actionbar
local dividers = {}

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

-- Parent BG frame
cabframe = CreateFrame("Frame", "EpicUICustomactionbar", UIParent)
cabframe:CreatePanel("Default", 1, BUTTON_SIZE+4, "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -6)
cabframe:SetAlpha(0)

local function UpdateBGFrame()
	if #ActiveTable() > 0 then
		cabframe:SetAlpha(1)
		cabframe:Width((#ActiveTable()*(BUTTON_SIZE+3))+1)
	else
		cabframe:SetAlpha(0)
	end
end

local function ManageDividers()
	if #dividers < #b then
		tinsert(dividers,  CreateFrame("Frame", nil, cabframe))
		if #dividers == 1 then
			dividers[#dividers]:CreatePanel("Default", 1, BUTTON_SIZE+4, "BOTTOMLEFT", cabframe, "BOTTOMLEFT", BUTTON_SIZE+3, 0)
		else
			dividers[#dividers]:CreatePanel("Default", 1, BUTTON_SIZE+4, "BOTTOMLEFT", dividers[#dividers-1], "BOTTOMLEFT", BUTTON_SIZE+3, 0)
		end
	elseif #dividers > #b then
		dividers[#dividers]:Kill()
		tremove(dividers, #dividers)
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
		ManageDividers()
		lastPos = b[i]
	end
	emptybutton:ClearAllPoints()
	if lastPos then
		emptybutton:Point("LEFT", lastPos, "RIGHT", 3, 0)
	else
		emptybutton:Point("TOPLEFT", cabframe, "TOPLEFT", 0, 0)
	end
	lastPos = nil
	
	UpdateBGFrame()
end

--Style the buttons
local function StyleButton(b, n)
	local hover = b:CreateTexture("frame", nil, self) -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:SetHeight(b:GetHeight())
	hover:SetWidth(b:GetWidth())
	hover:Point("TOPLEFT",b,2,-2)
	hover:Point("BOTTOMRIGHT",b,-2,2)
	b:SetHighlightTexture(hover)

	local pushed = b:CreateTexture("frame", nil, self) -- pushed
	pushed:SetTexture(0.9,0.8,0.1,0.3)
	pushed:SetHeight(b:GetHeight())
	pushed:SetWidth(b:GetWidth())
	pushed:Point("TOPLEFT",b,2,-2)
	pushed:Point("BOTTOMRIGHT",b,-2,2)
	b:SetPushedTexture(pushed)
	
	if n then
		pushed:ClearAllPoints()
		pushed:SetAllPoints()
		hover:ClearAllPoints()
		hover:SetAllPoints()		
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
	StyleButton(button, true)
	
	local function Suicide(self)
		ButtonRemove(self.id)
		ListRemove(self.id)
		self:Kill()
		self.cooldown:Kill()
		self = nil
	end
	
	local function SetCooldownTimer(self)
		local start, duration, enabled
		start, duration, enabled = _G["Get"..firstToUpper(self.metatype).."Cooldown"](self.id)
		
		if (start ~= 0) and (enabled == 1) then
			self.cooldown:SetAlpha(1)
			self.cooldown:SetCooldown(start, duration)
		elseif duration == 0 then
			self.cooldown:SetAlpha(0)
		end
		
		if enabled == 0 or (not _G["IsUsable"..firstToUpper(self.metatype)](self.id)) then
			self.tex:SetVertexColor(.35, .35, .35)
		else
			self.tex:SetVertexColor(1, 1, 1)
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
		GameTooltip:Show() 
	end
	
	local function Dropped(self)
		if InCombatLockdown() then return end
		local newID
		local newType, info1, info2 = GetCursorInfo()
		if not newType then return end
		
		if newType == "spell" then
			_,newID = GetSpellBookItemInfo(info1, info2)
		elseif newType == "item" then
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
		if event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_USABLE" then
			SetCooldownTimer(self)
		elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
			Suicide(self)
		end
	end
	
	button:RegisterForDrag("LeftButton")	
	button:RegisterEvent("PLAYER_ENTERING_WORLD")
	button:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	button:RegisterEvent("SPELL_UPDATE_USABLE")
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
	button:Size(BUTTON_SIZE+4, BUTTON_SIZE+4)
	button:SetAlpha(0)
	StyleButton(button)
	
	local function Dropped(self)
		if InCombatLockdown() then return end
		local newID
		local newType, info1, info2 = GetCursorInfo()
		if not newType then return end
		
		if newType == "spell" then
			_,newID = GetSpellBookItemInfo(info1, info2)
		elseif newType == "item" then
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

local function InitButtons()
	T.KillTableofFrames(b)
	for i, v in ipairs(ActiveTable()) do
		b[i] = CreateButton(v[1], v[2])   --v[1] is the ID, v[2] is the metatype
	end
	RepositionButtons()
end
	
local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	if event == "ADDON_LOADED" then
		if not EpicUIDataPerChar then EpicUIDataPerChar = {} end
		if not EpicUIDataPerChar.primary then EpicUIDataPerChar.primary = {} end
		if not EpicUIDataPerChar.secondary then EpicUIDataPerChar.secondary = {} end
	elseif event == "PLAYER_ENTERING_WORLD" then
		emptybutton = MakeDropButton()
		InitButtons()
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		T.KillTableofFrames(dividers)
		T.Delay(.1, InitButtons)
	end
end)

-- Clear Data
SLASH_CLEARCAB1 = "/clearcab"
SlashCmdList.CLEARCAB = function()
	_G["EpicUIDataPerChar"].primary = nil
	_G["EpicUIDataPerChar"].secondary = nil
	_G["EpicUIDataPerChar"].cabprimary = nil
	_G["EpicUIDataPerChar"].cabsecondary = nil
	ReloadUI()
end