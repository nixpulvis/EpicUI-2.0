local T, C, L = unpack(Tukui)

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUFTukui

ns._Objects = {}
ns._Headers = {}

if not C["databars"].talents or C["databars"].talents == 0 then return end
local barNum = C["databars"].talents

T.databars[barNum]:Show()

local Stat = CreateFrame("Frame", nil, T.databars[barNum])
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)

local StatusBar = T.databars[barNum].statusbar
local Text = T.databars[barNum].text

local function HasDualSpec() if GetNumTalentGroups() > 1 then return true end end

local function OnEvent(self)
	if not GetPrimaryTalentTree() then Text:SetText("No talents") return end
	
	local tree1 = select(5,GetTalentTabInfo(1))
	local tree2 = select(5,GetTalentTabInfo(2))
	local tree3 = select(5,GetTalentTabInfo(3))
	local primaryTree = GetPrimaryTalentTree()
	Text:SetText(tree1.."/"..tree2.."/"..tree3)
	self:SetAllPoints(T.databars[barNum])
end
          
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnMouseDown", function()
	if InCombatLockdown() then return end
	if IsShiftKeyDown() then
		if not HasDualSpec() then return end
		SetActiveTalentGroup(GetActiveTalentGroup() == 1 and 2 or 1)
	else
		if not IsAddOnLoaded("Blizzard_TalentUI") then LoadAddOn("Blizzard_TalentUI") end
		ToggleFrame(PlayerTalentFrame)
	end
end)
Stat:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	
	local anchor, panel, xoff, yoff = T.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	local primary = GetPrimaryTalentTree(false,false,GetActiveTalentGroup())
	local primaryone = select(5,GetTalentTabInfo(1))
	local primarytwo = select(5,GetTalentTabInfo(2))
	local primarythree = select(5,GetTalentTabInfo(3))
	GameTooltip:AddLine("Current Spec: "..select(2,GetTalentTabInfo(primary)).." - "..primaryone.."/"..primarytwo.."/"..primarythree)
	if HasDualSpec() then
		local secondary = GetActiveTalentGroup() == 1 and 2 or 1
		local secondaryone = select(5,GetTalentTabInfo(1,false,false, secondary))
		local secondarytwo = select(5,GetTalentTabInfo(2,false,false, secondary))
		local secondarythree = select(5,GetTalentTabInfo(3,false,false, secondary))
		GameTooltip:AddLine("Shift click to swap to "..select(2,GetTalentTabInfo(GetPrimaryTalentTree(false,false,(secondary)))).." - "..secondaryone.."/"..secondarytwo.."/"..secondarythree)
	end
	GameTooltip:Show()
end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)