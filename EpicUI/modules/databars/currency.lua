local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF

ns._Objects = {}
ns._Headers = {}

if not C["databars"].currency or C["databars"].currency == 0 then return end
local barNum = C["databars"].currency
local barTex = C.media.normTex
local pWidth, pHeight = C.databars.settings.width, C.databars.settings.height

T.databars[barNum]:Show()

local Stat = CreateFrame("Frame", nil, T.databars[barNum])
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)

local function numWatched()
	local watched = 0
	for i=1, MAX_WATCHED_TOKENS do
		if select(1, GetBackpackCurrencyInfo(i)) then
			watched = watched+1
		end
	end
	return watched
end

-- Resize original databar to fit 3 bars inside
T.databars[barNum]:SetHeight((numWatched()*pHeight) + ((numWatched()-1)*C.databars.settings.spacing))
T.databars[barNum]:SetBackdropColor(0,0,0,0)
T.databars[barNum]:SetBackdropBorderColor(0,0,0,0)
if T.databars[barNum].iborder then T.databars[barNum].iborder:Hide() end
if T.databars[barNum].oborder then T.databars[barNum].oborder:Hide() end
if T.databars[barNum].shadow then T.databars[barNum].shadow:Hide() end

-- Make those 3 bars now
local currencybars = {}
for i = 1, 3 do
	currencybars[i] = CreateFrame("Frame", "TukuiDataPanel"..barNum.."CurrencyBar"..i, T.databars[barNum])
	currencybars[i]:CreateShadow()
	if i == 1 then
		currencybars[i]:CreatePanel("ThickTransparent", pWidth-pHeight-C.databars.settings.spacing, pHeight, "TOPRIGHT", T.databars[barNum], "TOPRIGHT", 0, 0)
	else
		currencybars[i]:CreatePanel("ThickTransparent", pWidth-pHeight-C.databars.settings.spacing, pHeight, "TOP", currencybars[i-1], "BOTTOM", 0, -C.databars.settings.spacing)
	end
	currencybars[i]["bar"] = {}
	currencybars[i]["bar"] = CreateFrame("StatusBar",  "DataBar"..barNum.."_StatusBar"..i, currencybars[i], "TextStatusBar")
	currencybars[i]["bar"]:SetPoint("TOPRIGHT", currencybars[i], "TOPRIGHT", -2, -2)
	currencybars[i]["bar"]:SetPoint("BOTTOMLEFT", currencybars[i], "BOTTOMLEFT", 2, 2)
	currencybars[i]["bar"]:SetFrameStrata("BACKGROUND")
	currencybars[i]["bar"]:SetStatusBarTexture(barTex)
	currencybars[i]["bar"]:SetStatusBarColor(1,1,1)
	currencybars[i]["bar"]:SetFrameLevel(2)
	
	
	currencybars[i]["text"] = currencybars[i]["bar"]:CreateFontString("DataBar"..barNum.."_Text"..i, "OVERLAY")
	currencybars[i]["text"]:SetFont(C.media.uffont, C.unitframes.fontsize)
	currencybars[i]["text"]:SetPoint("TOPRIGHT", currencybars[i]["bar"], "TOPRIGHT", -2, -2)
	currencybars[i]["text"]:SetPoint("BOTTOMLEFT", currencybars[i]["bar"], "BOTTOMLEFT", 3, 3)
	
	currencybars[i]["iconBorder"] = CreateFrame("Frame", nil, currencybars[i])
	currencybars[i]["iconBorder"]:CreatePanel("ThickTransparent", pHeight, pHeight, "RIGHT", currencybars[i], "LEFT", -C.databars.settings.spacing, 0)
	currencybars[i]["iconBorder"]:CreateShadow()
	
	currencybars[i]["icon"] = currencybars[i]:CreateTexture(nil, "OVERLAY")
	currencybars[i]["icon"]:SetHeight(pHeight-2)
	currencybars[i]["icon"]:SetWidth(pHeight-2)
	currencybars[i]["icon"]:SetPoint("CENTER", currencybars[i]["iconBorder"], "CENTER", 0, 0)
end

local function update()
	local _text = "---"
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, icon = GetBackpackCurrencyInfo(i)
		
		for j = 1, GetCurrencyListSize() do
			local n, _, _, _, _, _, _, maximum, hasWeeklyLimit, currentWeeklyAmount, unknown = GetCurrencyListInfo(j)
			if n == name then
				currencybars[i]["icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
				currencybars[i]["icon"]:SetTexture(icon)
				currencybars[i]["bar"]:EnableMouse(true)
				
				-- Because conquest point maximums work differently than others
				if name == "Conquest Points" then 
					currencybars[i]["bar"]:SetMinMaxValues(0, select(5,GetCurrencyInfo(390)))
					currencybars[i]["bar"]:SetValue(currentWeeklyAmount)
				elseif maximum > 0 then
					currencybars[i]["bar"]:SetMinMaxValues(0,(maximum/100))
					currencybars[i]["bar"]:SetValue(count)
				else
					currencybars[i]["bar"]:SetMinMaxValues(0,1)
					currencybars[i]["bar"]:SetValue(0)
				end
			end
		end
		
		
		if name and count then
			if not currencybars[i]:IsShown() then currencybars[i]:Show() end
			currencybars[i]["text"]:SetText(count)
		else
			if currencybars[i]:IsShown() then currencybars[i]:Hide() end
		end
	end
	T.databars[barNum]:SetHeight((numWatched()*pHeight) + ((numWatched()-1)*C.databars.settings.spacing))end

local function OnEvent(self, event, ...)
	update()
	self:SetAllPoints(T.databars[barNum])
	Stat:UnregisterEvent("PLAYER_LOGIN")	
end
Stat:RegisterEvent("PLAYER_LOGIN")	
hooksecurefunc("BackpackTokenFrame_Update", update)
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnMouseDown", function() ToggleCharacter("TokenFrame") end)
Stat:SetScript("OnEnter", function()
	if not InCombatLockdown() then
		local xoff, yoff = T.DataBarTooltipAnchor(barNum)
		GameTooltip:SetOwner(T.databars[barNum], "ANCHOR_BOTTOMRIGHT", xoff, yoff)
		GameTooltip:ClearLines()
		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, icon = GetBackpackCurrencyInfo(i)
			GameTooltip:AddLine(name)
		end
		GameTooltip:Show()
	end
end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)