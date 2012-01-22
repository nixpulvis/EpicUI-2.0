local T, C, L = unpack(Tukui)
-- DATA SOTRED AT: EpicUIDataPerChar.cabsecondary = {{id, tpye}, ...} AND EpicUIDataPerChar.cabprimary = {{id, tpye}, ...}
local BUTTON_SIZE = 50
local b = {}
local emptybutton

--- EXAMPLES
local EpicUIDataPerChar = {}
EpicUIDataPerChar.cabprimary = {{61295, "spell"}, {16188, "spell"}, {72898, "item"}}

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function ActiveTable()
	if GetActiveTalentGroup() == 1 then
		return EpicUIDataPerChar.cabprimary
	else
		return EpicUIDataPerChar.cabsecondary
	end
end

-- ListRemove: table, number --> table
local function ListRemove(oldID)
	for i, v in ipairs(ActiveTable()) do
		if oldID == v[1] then
			tremove(ActiveTable(), i)
			break
		end
	end
end

-- Addtolist: table, number, number --> table 
local function ListInsert(oldID, oldType, newID, newType)
	if not tContains(ActiveTable(), {oldID, oldType}) then 
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

local function ButtonRemove(oldID)
	for i, v in ipairs(b) do
		if oldID == v.id then
			tremove(b, i)
			break
		end
	end
end


local function RepositionButtons()
	local lastPos
	for i, v in ipairs(b) do
		b[i]:ClearAllPoints()
		if i == 1 then
			b[i]:Point("CENTER", UIParent, "CENTER", 0, 0)
		else
			b[i]:Point("LEFT", lastPos, "RIGHT", 3, 0)
		end
		lastPos = b[i]
	end
	emptybutton:ClearAllPoints()
	emptybutton:Point("LEFT", lastPos, "RIGHT", 3, 0)
end

-- CreateButton: number, string
local function CreateButton(id, metatype)
	local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	button:SetTemplate()
	button:Size(BUTTON_SIZE, BUTTON_SIZE)
	
	button.tex = button:CreateTexture(nil, "BORDER")
	button.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.tex:SetAllPoints()
	
	button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cooldown:SetAllPoints(button.tex)				
	-- button:StyleButton() --FIX ME
	
	local function Suicide(self)
		ButtonRemove(self.id)
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
		
		SetDynamic(newID, newType)
		self:SetButtonState("NORMAL", false)
		ListInsert(self.id, self.metatype, newID, newType)
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
	
	
	button:RegisterEvent("PLAYER_ENTERING_WORLD")
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:RegisterEvent("BAG_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", SetCooldownTimer)

	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", Dragged)
	button:SetScript("OnReceiveDrag", Dropped)
	button:SetScript("OnEnter", DidEnter)
	button:SetScript("OnMouseUp", Dropped)
	
	return button
end

local function MakeDropButton()
	local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	button:SetTemplate()
	button:Size(BUTTON_SIZE, BUTTON_SIZE)
	button:SetAlpha(0)
	-- button:StyleButton()
	
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

-- ONLY CALL ONCE!!!
local function InitButtons()
	for i, v in ipairs(ActiveTable()) do
		b[i] = CreateButton(v[1], v[2])   --v[1] is the ID, v[2] is the metatype
	end
	emptybutton = MakeDropButton()
	RepositionButtons()
end
-- THE ONE CALL
InitButtons()	
	
	
	
	
	
	