local T, C, L = unpack(Tukui)
-- DATA SOTRED AT: EpicUIDataPerChar.cabsecondary = {{id, tpye}, ...} AND EpicUIDataPerChar.cabprimary = {{id, tpye}, ...}
local BUTTON_SIZE = 50
local b = {}

--- EXAMPLES
local EpicUIDataPerChar = {}
EpicUIDataPerChar.cabprimary = {{61295, "spell"}, {16188, "spell"}, {72898, "item"}}

local function ActiveSpells()
	if GetActiveTalentGroup() == 1 then
		return EpicUIDataPerChar.cabprimary
	else
		return EpicUIDataPerChar.cabsecondary
	end
end

-- ListRemove: table, number --> table
local function ListRemove(oldID)
	for i, v in ipairs(ActiveSpells()) do
		if oldID == v[1] then
			tremove(ActiveSpells(), i)
			tremove(b, i)
			break
		end
	end
end

-- Addtolist: table, number, number --> table 
local function ListInsert(oldID, oldType, newID, newType)
	if not tContains(ActiveSpells(), {oldID, oldType}) then 
		tinsert(ActiveSpells(), {newID, newType})
	end
	for i, v in ipairs(ActiveSpells()) do
		if oldID == v[1] then
			ListRemove(oldID)
			tinsert(ActiveSpells(), i, {newID, newType})
			break
		end
	end
end

local function RepositionButtons()
	local lastPos
	for i, v in ipairs(ActiveSpells()) do
		b[i]:ClearAllPoints()
		if i == 1 then
			b[i]:Point("CENTER", UIParent, "CENTER", 0, 0)
		else
			b[i]:Point("LEFT", lastPos, "RIGHT", 3, 0)
		end
		lastPos = b[i]
	end
end

-- CreateButton: number, string
local function CreateButton(id, metatype)	
	local button = CreateFrame("Button", "CustomBarButton"..id, UIParent, "SecureActionButtonTemplate")
	button:SetTemplate()
	button:Size(BUTTON_SIZE, BUTTON_SIZE)
	
	button.tex = button:CreateTexture(nil, "BORDER")
	button.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.tex:SetAllPoints()
	
	button.cooldown = CreateFrame("Cooldown", "$parentCD", button, "CooldownFrameTemplate")
	button.cooldown:SetAllPoints(button.tex)				
	button:StyleButton()
	
	local function Suicide(self)
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
		local newID
		local newType, info1, info2 = GetCursorInfo()
		if newType == "spell" then
			_,newID = GetSpellBookItemInfo(info1, info2)
		else
			newID = info1
		end
		SetDynamic(newID, newType)
		
		
		ListInsert(self.id, self.metatype, newID, newType)
		ClearCursor()
	end
	
	local function Dragged(self)
		local id = self.id
		PickupSpell(id)
		
		ListRemove(self.id)
		RepositionButtons()
		Suicide(self)
	end
	
	button:RegisterEvent("PLAYER_ENTERING_WORLD")
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:RegisterEvent("BAG_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", SetCooldownTimer)

	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", Dragged)
	button:SetScript("OnReceiveDrag", Dropped)
	-- button:SetScript("PreClick", Dropped)
	
	return button
end

local function MakeDropButton()
	
end

-- ONLY CALL ONCE!!!
local function InitButtons()
	for i, v in ipairs(ActiveSpells()) do
		b[i] = CreateButton(v[1], v[2])   --v[1] is the ID, v[2] is the metatype
	end
	RepositionButtons()
end
-- THE ONE CALL
InitButtons()	
	
	
	
	
	
	