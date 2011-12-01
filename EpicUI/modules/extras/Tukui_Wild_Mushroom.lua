-- Wild Mushroom Tracker Addon By Smelly
-- Credits to Hydra for code inspiration :D
local T, C, L = unpack(Tukui)

if T.myclass ~= "DRUID" then return end

local tMushroom = {}
local options = {
	anchor = {"TOPLEFT", TukuiMinimapStatsLeft or TukuiMinimap or Minimap, "BOTTOMLEFT", 0, -3},
	color = {75/255,  175/255, 101/255},
}

for i = 1, 3 do
	tMushroom[i] = CreateFrame("Frame", "tMushroom"..i, UIParent)
	tMushroom[i]:CreatePanel("Default", TukuiMinimap:GetWidth(), 20, "CENTER", UIParent, "CENTER", 0, 0)	
	if i == 1 then
		tMushroom[i]:ClearAllPoints()
		tMushroom[i]:Point(unpack(options.anchor))
	else	
		tMushroom[i]:Point("TOP", tMushroom[i-1], "BOTTOM", 0, -3)
	end
	tMushroom[i].status = CreateFrame("StatusBar", "status"..i, tMushroom[i])
	tMushroom[i].status:SetStatusBarTexture(C.media.normTex)
	tMushroom[i].status:SetStatusBarColor(unpack(options.color))
	tMushroom[i].status:Point("TOPLEFT", tMushroom[i], "TOPLEFT", 2, -2)
	tMushroom[i].status:Point("BOTTOMRIGHT", tMushroom[i], "BOTTOMRIGHT", -2, 2)
	tMushroom[i].text = tMushroom[i].status:CreateFontString(nil, "ARTWORK")
	tMushroom[i].text:SetFont(C["media"].font, 12, "OUTLINE")
	tMushroom[i].text:Point("RIGHT", tMushroom[i].status, "RIGHT", -3, 0)
	tMushroom[i].name = tMushroom[i].status:CreateFontString(nil, "ARTWORK")
	tMushroom[i].name:SetFont(C["media"].font, 12, "OUTLINE")
	tMushroom[i].name:Point("LEFT", tMushroom[i].status, "LEFT", 3, 0)
end

local function FormatTime(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", ceil(s / day))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return format("%sm", floor(s))
	end
	return format("%.1f", s)
end

local function MushroomUpdate(self)
	for i = 1, 3 do
		local haveTotem, totemName, start, duration = GetTotemInfo(i)
		if haveTotem then
			tMushroom[i]:Show()
			local timeLeft = (start + duration) - GetTime()
			tMushroom[i].status:SetMinMaxValues(0, 300)
			tMushroom[i].status:SetValue(timeLeft)
			local tTime = FormatTime(timeLeft)
			tMushroom[i].text:SetText(tTime)
			tMushroom[i].name:SetText(totemName)
		else
			tMushroom[i]:Hide()
		end
	end 	
	
end

local UpdateMushroom = CreateFrame("Frame")
UpdateMushroom:SetScript("OnUpdate", MushroomUpdate)
