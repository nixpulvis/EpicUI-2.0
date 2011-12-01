-----------------------------------------------
-- Spec Helper, by EPIC
-----------------------------------------------
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- colors
local hoverovercolor = {.4, .4, .4}
local cp = "|cff319f1b" -- +
local cm = "|cff9a1212" -- -
local dr, dg, db = unpack({ 0.4, 0.4, 0.4 })
panelcolor = ("|cff%.2x%.2x%.2x"):format(dr * 255, dg * 255, db * 255)

-- Gear Settings
local Enablegear = true -- herp
local Autogearswap = true -- derp
local set1 = 1 -- this is the gear set that gets equiped with your primary spec. (must be the NUMBER from 1-10)
local set2 = 2 -- this is the gear set that gets equiped with your secondary spec.(must be the NUMBER from 1-10)

--functions
local function HasDualSpec() if GetNumTalentGroups() > 1 then return true end end

local function GetSecondaryTalentIndex()
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
	local sTree1 = select(5,GetTalentTabInfo(1,false,false, GetSecondaryTalentIndex()))
	local sTree2 = select(5,GetTalentTabInfo(2,false,false, GetSecondaryTalentIndex()))
	local sTree3 = select(5,GetTalentTabInfo(3,false,false, GetSecondaryTalentIndex()))
	local sTree = GetPrimaryTalentTree(false,false,(GetSecondaryTalentIndex()))
	return sTree1, sTree2, sTree3, sTree
end

local function HasUnactiveTalents()
	local sTree = GetPrimaryTalentTree(false,false,(GetSecondaryTalentIndex()))
	if sTree == nil then
		return false
	else
		return true
	end
end

local function AutoGear(set1, set2)
	local name1 = GetEquipmentSetInfo(set1)
	local name2 = GetEquipmentSetInfo(set2)
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
spec:CreatePanel("Default", 100, 20, "CENTER", TukuiControl, "CENTER", 3, 0)
	
-- Text
spec.t = spec:CreateFontString(spec, "OVERLAY")
spec.t:SetPoint("CENTER")
spec.t:SetFont(C.media.font, C.datatext.fontsize)

local int = 1
local function Update(self, t)
int = int - t
if int > 0 then return end
	if not GetPrimaryTalentTree() then spec.t:SetText("No talents") return end
	local tree1, tree2, tree3, Tree = ActiveTalents()
	local name = select(2, GetTalentTabInfo(Tree))
	spec.t:SetText(name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3)
	
	if HasDualSpec() then
		if HasUnactiveTalents() then 
			local sTree1, sTree2, sTree3, sTree = UnactiveTalents()
			sName = select(2, GetTalentTabInfo(sTree))
			spec:SetScript("OnEnter", function() spec.t:SetText(cm..sName.." "..panelcolor..sTree1.."/"..sTree2.."/"..sTree3) end)
			spec:SetScript("OnLeave", function() spec.t:SetText(name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3) end)
		else
			spec:SetScript("OnEnter", function() spec.t:SetText(cm.."No talents") end)
			spec:SetScript("OnLeave", function() spec.t:SetText(name.." "..panelcolor..tree1.."/"..tree2.."/"..tree3) end)
		end
	end
	int = 1
	self:SetScript("OnUpdate", nil)
end

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	else
		self:SetScript("OnUpdate", Update)
	end
end	

spec:RegisterEvent("PLAYER_TALENT_UPDATE")
spec:RegisterEvent("PLAYER_ENTERING_WORLD")
spec:RegisterEvent("CHARACTER_POINTS_CHANGED")
spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
spec:SetScript("OnEvent", OnEvent) 

spec:SetScript("OnClick", function(self) 
local i = GetActiveTalentGroup()
if IsModifierKeyDown() then
	ToggleTalentFrame()
else
	if i == 1 then SetActiveTalentGroup(2) end
	if i == 2 then SetActiveTalentGroup(1) end
end
end)
	
------------
--Move UI
------------
local mui = CreateFrame("Button", nil, spec, "SecureActionButtonTemplate")
mui:CreatePanel("Default", 20, 20, "TOPRIGHT", spec, "TOPLEFT", -3, 0)
-- mui:Hide()	
mui.t = mui:CreateFontString(nil, "OVERLAY")
mui.t:SetPoint("CENTER")
mui.t:SetFont(C.media.font, C.datatext.fontsize)
mui.t:SetText("M")

mui:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverovercolor)) end)
mui:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
mui:SetAttribute("type", "macro")
mui:SetAttribute("macrotext", "/moveui")
	
------------
--Key Binds
------------
local binds = CreateFrame("Button", nil, mui, "SecureActionButtonTemplate")
binds:CreatePanel("Default", 20, 20, "RIGHT", mui, "LEFT", -3, 0)

binds.t = binds:CreateFontString(nil, "OVERLAY")
binds.t:SetPoint("CENTER")
binds.t:SetFont(C.media.font, C.datatext.fontsize)
binds.t:SetText("K")

binds:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverovercolor)) end)
binds:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
binds:SetAttribute("type", "macro")
binds:SetAttribute("macrotext", "/bindkey")

	if C.general.colorscheme == true then
		binds:SetBackdropColor(unpack(C.general.color))
	end	
	
---------------	
-- Heal layout
---------------
local heal = CreateFrame("Button", nil, mui, "SecureActionButtonTemplate")
heal:CreatePanel("Default", 20, 20, "RIGHT", binds, "LEFT", -3, 0)
		
heal.t = heal:CreateFontString(nil, "OVERLAY")
heal.t:SetPoint("CENTER")
heal.t:SetFont(C.media.font, C.datatext.fontsize)
heal.t:SetText("|cff4BAF4CH|r")

heal:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverovercolor)) end)
heal:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
heal:SetAttribute("type", "macro")
heal:SetAttribute("macrotext", "/heal")

--------------
-- DPS layout
--------------
local dps = CreateFrame("Button", nil, mui, "SecureActionButtonTemplate")
dps:CreatePanel("Default", 20, 20, "RIGHT", heal, "LEFT", -3, 0)		
dps.t = dps:CreateFontString(nil, "OVERLAY")
dps.t:SetPoint("CENTER")
dps.t:SetFont(C.media.font, C.datatext.fontsize)
dps.t:SetText("|cFFC11B17D|r")

dps:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverovercolor)) end)
dps:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
dps:SetAttribute("type", "macro")
dps:SetAttribute("macrotext", "/dps")

------------------
-- Layout Checker
------------------
local checker = CreateFrame("Frame")
checker:RegisterEvent("ADDON_LOADED")
checker:SetScript("OnEvent", function(self, event, addon)
	if addon == "Tukui_Raid" then
		dps:SetBackdropBorderColor(.8,.8,.8)
		dps:SetScript("OnEnter", T.dummy)
		dps:SetScript("OnLeave", T.dummy)
		dps:EnableMouse(false)
	elseif addon == "Tukui_Raid_Healing" then
		heal:SetBackdropBorderColor(.8,.8,.8)
		heal:SetScript("OnEnter", T.dummy)
		heal:SetScript("OnLeave", T.dummy)
		heal:EnableMouse(false)
	end
end)
------------------		
-- Gear switching
------------------
if Enablegear == true then
	local gearSets = CreateFrame("Frame", nil, spec)	
	for i = 1, 5 do
			gearSets[i] = CreateFrame("Button", nil, spec)
			gearSets[i]:CreatePanel("Default", 19, 20, "CENTER", spec, "CENTER", 0, 0)

			if i == 1 then
				gearSets[i]:Point("LEFT", spec, "RIGHT", 3, 0)
			else
				gearSets[i]:SetPoint("LEFT", gearSets[i-1], "RIGHT", 3, 0)
			end
			gearSets[i].texture = gearSets[i]:CreateTexture(nil, "BORDER")
			gearSets[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			gearSets[i].texture:SetPoint("TOPLEFT", gearSets[i] ,"TOPLEFT", 2, -2)
			gearSets[i].texture:SetPoint("BOTTOMRIGHT", gearSets[i] ,"BOTTOMRIGHT", -2, 2)
			gearSets[i].texture:SetTexture(select(2, GetEquipmentSetInfo(i)))
			gearSets[i]:Hide()
		
		gearSets[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
		gearSets[i]:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		gearSets[i]:SetScript("OnEvent", function(self, event)
			local points, pt = 0, GetNumEquipmentSets()
			local frames = { gearSets[1]:IsShown(), gearSets[2]:IsShown(), gearSets[3]:IsShown(), gearSets[4]:IsShown(), 
						 gearSets[5]:IsShown()} -- lol WTF was I thinking here!
			if pt > points then
				for i = points + 1, pt do
					gearSets[i]:Show()
				end
			end
			if frames[pt+1] == 1 then
				gearSets[pt+1]:Hide()
			end
			
			gearSets[i].texture = gearSets[i]:CreateTexture(nil, "BORDER")
			gearSets[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			gearSets[i].texture:SetPoint("TOPLEFT", gearSets[i] ,"TOPLEFT", 2, -2)
			gearSets[i].texture:SetPoint("BOTTOMRIGHT", gearSets[i] ,"BOTTOMRIGHT", -2, 2)
			gearSets[i].texture:SetTexture(select(2, GetEquipmentSetInfo(i)))
			
			gearSets[i]:SetScript("OnClick", function(self) UseEquipmentSet(GetEquipmentSetInfo(i)) end)
			gearSets[i]:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverovercolor)) end)
			gearSets[i]:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
			
			if Autogearswap == true then
				gearSets[1]:SetBackdropBorderColor(0,1,0)
				gearSets[2]:SetBackdropBorderColor(1,0,0)
				gearSets[1]:SetScript("OnEnter", nil)
				gearSets[1]:SetScript("OnLeave", nil)
				gearSets[2]:SetScript("OnEnter", nil)
				gearSets[2]:SetScript("OnLeave", nil)
			end
		end)
	end	
	
	if Autogearswap == true then
		gearsetfunc = CreateFrame("Frame", "gearSetfunc", UIParent)
		local function OnEvent(self, event)
			if event == "PLAYER_ENTERING_WORLD" then
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			else
				AutoGear(set1, set2) 
			end
		end
		
		gearsetfunc:RegisterEvent("PLAYER_ENTERING_WORLD")
		gearsetfunc:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		gearsetfunc:SetScript("OnEvent", OnEvent)
	end
end