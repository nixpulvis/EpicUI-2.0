-----------------------------------------------
-- SpecHelper by Epic
-----------------------------------------------
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local dr, dg, db = unpack(C.general.highlighted)
panelcolor = ("|cff%.2x%.2x%.2x"):format(dr * 255, dg * 255, db * 255)

-- Gear Settings
local Autogearswap = false -- make this a setting

--functions
local function GetUnactiveTalentGroup()
	if GetActiveTalentGroup() == 1 then
		return 2
	else
		return 1
	end
end

local function GetActiveTalents()
	local t1 = select(5,GetTalentTabInfo(1))
	local t2 = select(5,GetTalentTabInfo(2))
	local t3 = select(5,GetTalentTabInfo(3))
	local tr = GetPrimaryTalentTree(false,false,GetActiveTalentGroup())
	return t1, t2, t3, tr
end	

local function GetUnactiveTalents()
	local st1 = select(5,GetTalentTabInfo(1,false,false, GetUnactiveTalentGroup()))
	local st2 = select(5,GetTalentTabInfo(2,false,false, GetUnactiveTalentGroup()))
	local st3 = select(5,GetTalentTabInfo(3,false,false, GetUnactiveTalentGroup()))
	local str = GetPrimaryTalentTree(false,false,(GetUnactiveTalentGroup()))
	return st1, st2, st3, str
end

local function HasDualSpec() if GetNumTalentGroups() > 1 then return true end end

local function HasUnactiveTalents()
	local sTree = GetPrimaryTalentTree(false,false,(GetUnactiveTalentGroup()))
	if sTree == nil then
		return false
	else
		return true
	end
end

local function SwitchSpecs()
	if IsShiftKeyDown() then ToggleTalentFrame() end
	local i = GetActiveTalentGroup()
	if i == 1 then SetActiveTalentGroup(2) end
	if i == 2 then SetActiveTalentGroup(1) end
end

local function AutoGear()
	local name1 = GetEquipmentSetInfo(1)
	local name2 = GetEquipmentSetInfo(2)
	if GetActiveTalentGroup() == 1 then
		if name1 then UseEquipmentSet(name1) end
	else
		if name2 then UseEquipmentSet(name2) end
	end
end

-----------
-- Spec
-----------
local spec = CreateFrame("Button", "Tukui_Spechelper", UIParent)
spec:CreatePanel("Default", TukuiMinimap:GetWidth(), 20, "TOP", TukuiMinimap, "BOTTOM", 0, -3)
	
-- Text
spec.t = spec:CreateFontString(spec, "OVERLAY")
spec.t:SetPoint("CENTER", -8, 0)
spec.t:SetFont(C.media.font, C.datatext.fontsize)

local int = 1
local function SetSpecInfo(self, t)
	int = int - t
	if int > 0 then return end
	
	local tree1, tree2, tree3, treeIndex, name, sTree1, sTree2, sTree3, sTreeIndex, sName
	if GetPrimaryTalentTree() then
		tree1, tree2, tree3, treeIndex = GetActiveTalents()
		name = select(2, GetTalentTabInfo(treeIndex))
		if HasDualSpec() and HasUnactiveTalents() then
			sTree1, sTree2, sTree3, sTreeIndex = GetUnactiveTalents()
			sName = select(2, GetTalentTabInfo(sTreeIndex))
		end
	end
	
	if GetPrimaryTalentTree() then 
		self.t:SetText(name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3)
	else
		self.t:SetText("No talents") 
	end
	
	-- tooltip
	self:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self,"ANCHOR_TOP", 0, 4)
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:ClearLines()
		if HasDualSpec() and HasUnactiveTalents() then
			GameTooltip:AddDoubleLine("Active Spec:", name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3 or "No Talents", 0, 1, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine("Unactive Spec:", sName.." "..panelcolor..sTree1.."/"..sTree2.."/"..sTree3, 1, 0, 0, 1, 1, 1)
		elseif HasDualSpec() and not HasUnactiveTalents() then
			GameTooltip:AddDoubleLine("Active Spec:", name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3 or "No Talents", 0, 1, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine("Unactive Spec:", "No Talents", 1, 0, 0, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine("Active Spec", name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3, 0, 1, 0, 1, 1, 1)
		end
		GameTooltip:AddLine("Click to Switch Specs")
		GameTooltip:AddLine("Shift-click to View Talents")
		GameTooltip:Show() 
		
		self:SetBackdropBorderColor(unpack(C.general.highlighted))
	end)
	self:SetScript("OnLeave", function(self) 
		GameTooltip_Hide()
		self:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end)
	self:EnableMouse(true)
	
	self:SetScript("OnUpdate", nil)
end

local function OnEvent(self, event)
	--if event == "PLAYER_ENTERING_WORLD" then
	--	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	--else
		self:SetScript("OnUpdate", SetSpecInfo)
	--end
end

spec:RegisterEvent("PLAYER_TALENT_UPDATE")
spec:RegisterEvent("PLAYER_ENTERING_WORLD")
spec:RegisterEvent("CHARACTER_POINTS_CHANGED")
spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
spec:SetScript("OnEvent", OnEvent) 
spec:SetScript("OnClick", SwitchSpecs)

---------------	
-- Layout
---------------
local layout = CreateFrame("Button", nil, spec, "SecureActionButtonTemplate")
layout:Size(16, 16)
layout:Point("RIGHT", spec, "RIGHT", -2, 0 )
layout:SetFrameStrata(spec:GetFrameStrata())
layout:SetFrameLevel(spec:GetFrameLevel() + 1)
layout:SetTemplate()

layout.tex = layout:CreateTexture(nil, "ARTWORK")
layout.tex:Point("TOPLEFT", 2, -2)
layout.tex:Point("BOTTOMRIGHT", -2, 2)
layout.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local SetIcon = function(self)
	local tex, switchto
	if IsAddOnLoaded("EpicUI_Raid") then
		tex = C.media.dpsicon
		switchto = "heal"
	elseif IsAddOnLoaded("EpicUI_Raid_Healing") then
		tex = C.media.healicon
		switchto = "dps"
	end

	self.tex:SetTexture(tex)
	
	self:SetAttribute("type", "macro")
	self:SetAttribute("macrotext", "/"..switchto)
end

layout:RegisterEvent("PLAYER_ENTERING_WORLD")
layout:SetScript("OnEvent", SetIcon)		

-- tooltip
layout:SetScript("OnEnter", function(self) 
	GameTooltip:SetOwner(self,"ANCHOR_TOP", 0, 4)
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Switch Raidframe Layout")
	GameTooltip:Show()
	self:SetBackdropBorderColor(unpack(C.general.highlighted)) 
end)
layout:SetScript("OnLeave", function(self) 
	GameTooltip_Hide() 
	self:SetBackdropBorderColor(unpack(C.general.bordercolor))
end)
layout:EnableMouse(true)
	
---------	
--Panel
---------
local shpanel = CreateFrame("Frame", nil, spec)
shpanel:CreatePanel("Default", spec:GetWidth(), 72, "TOP", spec, "BOTTOM", 0, -3)
shpanel:Hide()

------------
-- Toggle
------------
local toggle = CreateFrame("Button", nil, spec)
toggle:CreatePanel("Default", spec:GetWidth(), 20, "TOP", spec, "BOTTOM", 0, -2)
toggle:SetAlpha(0)

toggle.t = toggle:CreateFontString(nil, "OVERLAY")
toggle.t:SetPoint("CENTER")
toggle.t:SetFont(C.media.font, C.datatext.fontsize)
toggle.t:SetText("OPEN")

toggle:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
toggle:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
toggle:SetScript("OnClick", function() 
	if shpanel:IsShown() then
		shpanel:Hide()
		toggle.t:SetText("OPEN")
		toggle:Point("TOP", spec, "BOTTOM", 0, -2)
	else
		shpanel:Show()
		toggle.t:SetText("CLOSE")
		toggle:Point("TOP", shpanel, "BOTTOM", 0, -2)
	end
end)

------------------		
-- Gear switching
------------------
local btnsize = 30

local gearpanel = CreateFrame("Frame", nil, shpanel)
gearpanel:CreatePanel("Default", btnsize+6, 1, "TOPRIGHT", shpanel, "TOPLEFT", -3, 0)
gearpanel:SetFrameStrata("High")
gearpanel:Hide()

local gearSets = CreateFrame("Frame", nil, gearpanel)	
for i = 1, 6 do
	gearSets[i] = CreateFrame("Button", nil, gearpanel)
	gearSets[i]:SetTemplate()
	gearSets[i]:Size(btnsize, btnsize)

	if i == 1 then
		gearSets[i]:Point("TOP", gearpanel, "TOP", 0, -3)
	else
		gearSets[i]:SetPoint("TOP", gearSets[i-1], "BOTTOM", 0, -3)
	end
	gearSets[i]:Hide()
end	

local function SetGearButtons()	
	local sets = GetNumEquipmentSets()
	if sets > 6 then
		sets = 6
	end

	if sets < 6 then
		for i = sets+1, 6 do
			gearSets[i]:Hide()
		end
	end

	for i = 1, sets do				
		gearSets[i]:Show()
		
		gearSets[i].texture = gearSets[i]:CreateTexture(nil, "BORDER")
		gearSets[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		gearSets[i].texture:SetPoint("TOPLEFT", gearSets[i] ,"TOPLEFT", 2, -2)
		gearSets[i].texture:SetPoint("BOTTOMRIGHT", gearSets[i] ,"BOTTOMRIGHT", -2, 2)
		gearSets[i].texture:SetTexture(select(2, GetEquipmentSetInfo(i))) -- weirdness here
			
		gearSets[i]:SetScript("OnClick", function(self) UseEquipmentSet(GetEquipmentSetInfo(i)) end)
		gearSets[i]:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
		gearSets[i]:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
		
		if Autogearswap == true then
			gearSets[1]:SetBackdropBorderColor(0,1,0)
			gearSets[2]:SetBackdropBorderColor(1,0,0)
			gearSets[1]:SetScript("OnEnter", nil)
			gearSets[1]:SetScript("OnLeave", nil)
			gearSets[2]:SetScript("OnEnter", nil)
			gearSets[2]:SetScript("OnLeave", nil)
		end
	end
	
	gearpanel:Height((GetNumEquipmentSets()*btnsize)+(GetNumEquipmentSets()*4))
end

gearfunc = CreateFrame("Frame", nil, UIParent)		
gearfunc:RegisterEvent("PLAYER_ENTERING_WORLD")
gearfunc:RegisterEvent("EQUIPMENT_SETS_CHANGED")
gearfunc:SetScript("OnEvent", SetGearButtons)

if Autogearswap == true then
	autofunc = CreateFrame("Frame", nil, UIParent)
	autofunc:RegisterEvent("PLAYER_ENTERING_WORLD")
	autofunc:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	autofunc:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		else
			AutoGear() 
		end
	end)
end

------------
-- Gear Button
------------
local geartoggle = CreateFrame("Button", nil, shpanel)
geartoggle:CreatePanel("Default", shpanel:GetWidth()-6, 20, "TOPLEFT", shpanel, "TOPLEFT", 3, -3)

geartoggle.t = geartoggle:CreateFontString(nil, "OVERLAY")
geartoggle.t:SetPoint("CENTER")
geartoggle.t:SetFont(C.media.font, C.datatext.fontsize)
geartoggle.t:SetText("Gear Sets ("..GetNumEquipmentSets()..")")

geartoggle:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
geartoggle:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
geartoggle:SetScript("OnClick", function(self) 
	if gearpanel:IsShown() then
		gearpanel:Hide() 
	else
		gearpanel:Show()
	end
end)

------------
--Move UI
------------
local mui = CreateFrame("Button", nil, geartoggle, "SecureActionButtonTemplate")
mui:CreatePanel("Default", (geartoggle:GetWidth()/2)-3, 20, "TOPLEFT", geartoggle, "BOTTOMLEFT", 0, -2)

mui.t = mui:CreateFontString(nil, "OVERLAY")
mui.t:SetPoint("CENTER")
mui.t:SetFont(C.media.font, C.datatext.fontsize)
mui.t:SetText("Move UI")

mui:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
mui:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
mui:SetAttribute("type", "macro")
mui:SetAttribute("macrotext", "/moveui")
	
------------
--Key Binds
------------
local binds = CreateFrame("Button", nil, mui, "SecureActionButtonTemplate")
binds:CreatePanel("Default", (spec:GetWidth()/2)-4, 20, "LEFT", mui, "RIGHT", 2, 0)

binds.t = binds:CreateFontString(nil, "OVERLAY")
binds.t:SetPoint("CENTER")
binds.t:SetFont(C.media.font, C.datatext.fontsize)
binds.t:SetText("Keybinds")

binds:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
binds:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
binds:SetAttribute("type", "macro")
binds:SetAttribute("macrotext", "/bindkey")

------------
-- Glyphs
------------
local glyphpanel = CreateFrame("Frame", nil, shpanel)
glyphpanel:CreatePanel("Default", 300, 200, "TOPRIGHT", shpanel, "TOPLEFT", -3, 0)
glyphpanel:SetFrameStrata("HIGH")
glyphpanel:Hide()

local glyphbutton = {}
for i = 1, NUM_GLYPH_SLOTS do
	local enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(i)
	
	glyphbutton[i] = CreateFrame("Frame", "FrameGlyph"..i, glyphpanel)	
	if i == 1 then
		glyphbutton[i]:CreatePanel("Default", 20, 20, "TOPLEFT", glyphpanel, "TOPLEFT", 3, -3)
	else
		glyphbutton[i]:CreatePanel("Default", 20, 20, "TOP", glyphbutton[i-1], "BOTTOM", 0, -3)
	end
	glyphbutton[i]:SetFrameStrata("HIGH")
	glyphbutton[i].tex = glyphbutton[i]:CreateTexture(nil, "OVERLAY")
	glyphbutton[i].tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	glyphbutton[i].tex:Point("TOPLEFT", 2, -2)
	glyphbutton[i].tex:Point("BOTTOMRIGHT", -2, 2)
	glyphbutton[i].tex:SetTexture(icon)

	glyphbutton[i]:EnableMouse(true)
	glyphbutton[i]:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self,"ANCHOR_BOTTOM", 0, -4)
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:ClearLines()
		GameTooltip:SetGlyph(i, 1)
		GameTooltip:Show()
		self:SetBackdropBorderColor(unpack(C.general.highlighted)) 
	end)
	glyphbutton[i]:SetScript("OnLeave", function(self) 
		GameTooltip_Hide() 
		self:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end)
end

--toggle
local glyphs = CreateFrame("Button", nil, mui)
glyphs:CreatePanel("Default", spec:GetWidth()-4, 20, "TOPLEFT", mui, "BOTTOMLEFT", 0, -3)

glyphs.t = glyphs:CreateFontString(nil, "OVERLAY")
glyphs.t:SetPoint("CENTER")
glyphs.t:SetFont(C.media.font, C.datatext.fontsize)
glyphs.t:SetText("Glyphs")

glyphs:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
glyphs:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
glyphs:SetScript("OnClick", function(self) 
	if glyphpanel:IsShown() then
		glyphpanel:Hide()
	else
		glyphpanel:Show()
	end
end)





