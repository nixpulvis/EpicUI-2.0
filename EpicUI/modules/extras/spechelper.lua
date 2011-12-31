-----------------------------------------------
-- Spec Info
-----------------------------------------------
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local dr, dg, db = unpack(C.general.highlighted)
panelcolor = ("|cff%.2x%.2x%.2x"):format(dr * 255, dg * 255, db * 255)

-- Gear Settings
local Enablegear = true -- make this a setting
local Autogearswap = false -- make this a setting

--functions
local function HasDualSpec() if GetNumTalentGroups() > 1 then return true end end

local function GetUnactiveTalentGroup()
	local secondary
	if GetActiveTalentGroup() == 1 then
		secondary = 2
	else
		secondary = 1
	end
	return secondary
end

local function ActiveTalents()
	local tree1 = select(5,GetTalentTabInfo(1))
	local tree2 = select(5,GetTalentTabInfo(2))
	local tree3 = select(5,GetTalentTabInfo(3))
	local Tree = GetPrimaryTalentTree(false,false,GetActiveTalentGroup())
	return tree1, tree2, tree3, Tree
end	

local function UnactiveTalents()
	local sTree1 = select(5,GetTalentTabInfo(1,false,false, GetUnactiveTalentGroup()))
	local sTree2 = select(5,GetTalentTabInfo(2,false,false, GetUnactiveTalentGroup()))
	local sTree3 = select(5,GetTalentTabInfo(3,false,false, GetUnactiveTalentGroup()))
	local sTree = GetPrimaryTalentTree(false,false,(GetUnactiveTalentGroup()))
	return sTree1, sTree2, sTree3, sTree
end

local function HasUnactiveTalents()
	local sTree = GetPrimaryTalentTree(false,false,(GetUnactiveTalentGroup()))
	if sTree == nil then
		return false
	else
		return true
	end
end

local function SwitchSpecs()
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
spec:CreatePanel("Default", TukuiMinimap:GetWidth(), 20, "TOP", TukuiMinimap, "BOTTOM", 0, -5)
	
-- Text
spec.t = spec:CreateFontString(spec, "OVERLAY")
spec.t:SetPoint("CENTER", -8, 0)
spec.t:SetFont(C.media.font, C.datatext.fontsize)

local function SetSpecInfo(self)
	local Name, sName, tree1, tree2, tree3, Tree, sTree1, sTree2, sTree3, sTree
	
	if GetPrimaryTalentTree() then
		tree1, tree2, tree3, Tree = ActiveTalents()
		Name = select(2, GetTalentTabInfo(Tree))
		if HasDualSpec() and HasUnactiveTalents() then
			sTree1, sTree2, sTree3, sTree = UnactiveTalents()
			sName = select(2, GetTalentTabInfo(sTree))
		end
	elseif HasDualSpec() and HasUnactiveTalents() then
			local sTree1, sTree2, sTree3, sTree = UnactiveTalents()
			sName = select(2, GetTalentTabInfo(sTree))
	end
	
	if GetPrimaryTalentTree() then 
		self.t:SetText(Name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3)
	else
		self.t:SetText("No talents") 
	end
	-- tooltip
	self:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self,"ANCHOR_TOP", 0, 4)
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:ClearLines()
		if HasDualSpec() and HasUnactiveTalents() then
			GameTooltip:AddDoubleLine("Active Spec:", Name or "No Talents", 0, 1, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine("Unactive Spec:", sName, 1, 0, 0, 1, 1, 1)
		elseif HasDualSpec() and not HasUnactiveTalents() then
			GameTooltip:AddDoubleLine("Active Spec:", Name or "No Talents", 0, 1, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine("Unactive Spec:", "No Talents", 1, 0, 0, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine("Active Spec", Name, 0, 1, 0, 1, 1, 1)
		end
		GameTooltip:AddLine("Click to Switch Specs")
		GameTooltip:AddLine("Shift-click to View Talents")
		GameTooltip:Show() 
	end)
	self:SetScript("OnLeave", function(self) GameTooltip_Hide() end)
	self:EnableMouse(true)
end

spec:RegisterEvent("PLAYER_TALENT_UPDATE")
spec:RegisterEvent("PLAYER_ENTERING_WORLD")
spec:RegisterEvent("CHARACTER_POINTS_CHANGED")
spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
spec:SetScript("OnEvent", SetSpecInfo) 
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
	if IsAddOnLoaded("Tukui_Raid") then
		tex = C.media.dpsicon
		switchto = "heal"
	elseif IsAddOnLoaded("Tukui_Raid_Healing") then
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
end)
layout:SetScript("OnLeave", function(self) GameTooltip_Hide() end)
layout:EnableMouse(true)
	
---------	
--Panel
---------
local shpanel = CreateFrame("Frame", nil, spec)
shpanel:CreatePanel("Default", spec:GetWidth(), 70, "TOP", spec, "BOTTOM", 0, -3)
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

------------
-- Gear Button
------------
local geartoggle = CreateFrame("Button", nil, shpanel)
geartoggle:CreatePanel("Default", shpanel:GetWidth()-6, 20, "TOPLEFT", shpanel, "TOPLEFT", 3, -3)

geartoggle.t = switch:CreateFontString(nil, "OVERLAY")
geartoggle.t:SetPoint("CENTER")
geartoggle.t:SetFont(C.media.font, C.datatext.fontsize)
geartoggle.t:SetText("Show Gear Sets")

geartoggle:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.general.highlighted)) end)
geartoggle:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.general.bordercolor)) end)
geartoggle:SetScript("OnClick", SwitchSpecs)

------------------		
-- Gear switching
------------------
if Enablegear == true then
	local gearSets = CreateFrame("Frame", nil, shpanel)	
	for i = 1, 6 do
			gearSets[i] = CreateFrame("Button", nil, shpanel)
			gearSets[i]:SetTemplate()
			gearSets[i]:Size(20, 20)

			if i == 1 then
				gearSets[i]:Point("TOPLEFT", mui, "BOTTOMLEFT", 0, -2)
			else
				gearSets[i]:SetPoint("LEFT", gearSets[i-1], "RIGHT", 3, 0)
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
end

------------
--Move UI
------------
local mui = CreateFrame("Button", nil, switch, "SecureActionButtonTemplate")
mui:CreatePanel("Default", (spec:GetWidth()/2)-3, 20, "TOPLEFT", switch, "BOTTOMLEFT", 0, -2)

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