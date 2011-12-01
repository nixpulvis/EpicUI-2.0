local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if not C["databars"].exp_rep or C["databars"].exp_rep == 0 then return end
local barNum = C["databars"].exp_rep

T.databars[barNum]:Show()

local function ShortValue(value)
	if value >= 1e6 then
		return ("%.2fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?+([km])$", "%1")
	else
		return value
	end
end

local reaction = {
	[1] = {{ 170/255, 70/255,  70/255 }, "Hated", "FFaa4646"},
	[2] = {{ 170/255, 70/255,  70/255 }, "Hostile", "FFaa4646"},
	[3] = {{ 170/255, 70/255,  70/255 }, "Unfriendly", "FFaa4646"},
	[4] = {{ 200/255, 180/255, 100/255 }, "Neutral", "FFc8b464"},
	[5] = {{ 75/255,  175/255, 75/255 }, "Friendly", "FF4baf4b"},
	[6] = {{ 75/255,  175/255, 75/255 }, "Honored", "FF4baf4b"},
	[7] = {{ 75/255,  175/255, 75/255 }, "Revered", "FF4baf4b"},
	[8] = {{ 155/255,  255/255, 155/255 }, "Exalted","FF9bff9b"},
}

local Stat = CreateFrame("Frame", nil, T.databars[barNum])
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)

local StatusBar = T.databars[barNum].statusbar
local Text = T.databars[barNum].text

local restBar = CreateFrame("StatusBar", "DataBar"..barNum.."_restBar", StatusBar, "TextStatusBar")
T.DataBarPoint(barNum, restBar)
restBar:SetStatusBarTexture(barTex)
restBar:SetFrameLevel(1)
restBar:SetStatusBarColor(0, .4, .8)
restBar:Hide()


local function OnEvent(self)
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local XP, maxXP = UnitXP("player"), UnitXPMax("player")
		local restXP = GetXPExhaustion()
		if restXP then
			Text:SetText(math.floor(XP/maxXP*100).."%|cff7fcaff+"..math.floor(restXP/maxXP*100).."%|r")
			if not restBar:IsShown() then restBar:Show() end
			restBar:SetMinMaxValues(min(0, XP), maxXP)
			restBar:SetValue(XP+restXP)
		else
			Text:SetText(math.floor(XP/maxXP*100).."%")
		end
		StatusBar:SetStatusBarColor(.4, 0, .4)
		StatusBar:SetMinMaxValues(min(0, XP), maxXP)
		StatusBar:SetValue(XP)
	elseif GetWatchedFactionInfo() then
		if restBar:IsShown() then restBar:Hide() end
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		Text:SetText(value-minRep.."/"..maxRep-minRep)
		StatusBar:SetStatusBarColor(unpack(reaction[rank][1]))
		StatusBar:SetMinMaxValues(min(0, value-minRep), maxRep-minRep)
		StatusBar:SetValue(value-minRep)
	else
		StatusBar:SetValue(0)
		Text:SetText("-")
		Text:SetTextColor(1,1,1)
	end
	self:SetAllPoints(T.databars[barNum])
end
	
--Event handling
Stat:RegisterEvent("PLAYER_LEVEL_UP")
Stat:RegisterEvent("PLAYER_XP_UPDATE")
Stat:RegisterEvent("UPDATE_EXHAUSTION")
Stat:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
Stat:RegisterEvent("UPDATE_FACTION")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnEvent", OnEvent)

--Tooltip
Stat:SetScript("OnEnter", function(self)
		local xoff, yoff = T.DataBarTooltipAnchor(barNum)
		GameTooltip:SetOwner(T.databars[barNum], "ANCHOR_BOTTOMRIGHT", xoff, yoff)
		
		GameTooltip:ClearLines()
		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			local XP, maxXP = UnitXP("player"), UnitXPMax("player")
			local restXP = GetXPExhaustion()
			GameTooltip:AddLine("Experience:")
			GameTooltip:AddLine("XP: "..T.CommaValue(XP).."/"..T.CommaValue(maxXP).."("..floor(XP/maxXP*100).."%)")
			GameTooltip:AddLine("Remaining: -"..T.CommaValue(maxXP-XP))
			if restXP then
				GameTooltip:AddLine("|cff7fcaffRested: "..T.CommaValue(restXP).."("..floor(restXP/maxXP*100).."%)|r")
			end
		end
		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			if UnitLevel("player") ~= MAX_PLAYER_LEVEL then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine("Reputation: "..name)
			GameTooltip:AddLine("Standing: |c"..reaction[rank][3]..reaction[rank][2].."|r")
			GameTooltip:AddLine("Rep: "..T.CommaValue(value-min).."/"..T.CommaValue(max-min).."("..floor((value-min)/(max-min)*100).."%)")
			GameTooltip:AddLine("Remaining: -"..T.CommaValue(max-value))
		end
		GameTooltip:Show()
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)