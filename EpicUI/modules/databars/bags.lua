local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF

ns._Objects = {}
ns._Headers = {}

if not C["databars"].bags or C["databars"].bags == 0 then return end
local barNum = C["databars"].bags

T.databars[barNum]:Show()

local Stat = CreateFrame("Frame", nil, T.databars[barNum])
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)

local StatusBar = T.databars[barNum].statusbar
local Text = T.databars[barNum].text

local function OnEvent(self, event, ...)
	local free, total,used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free
	StatusBar:SetMinMaxValues(0,total)
	StatusBar:SetValue(used)
	local r, g, b = oUF.ColorGradient(used/total, 0.2,0.8,0.2, 0.8,0.8,0.2, 0.8,0.2,0.2)
	StatusBar:SetStatusBarColor(r,g,b)
	
	Text:SetFormattedText(L.datatext_bags.." "..used.."/"..total)
	self:SetAllPoints(T.databars[barNum])
end
          
Stat:RegisterEvent("PLAYER_LOGIN")
Stat:RegisterEvent("BAG_UPDATE")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnMouseDown", function() OpenAllBags() end)