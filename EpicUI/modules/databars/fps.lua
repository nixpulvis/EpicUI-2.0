local T, C, L = unpack(Tukui)
local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUFTukui

ns._Objects = {}
ns._Headers = {}

if not C["databars"].framerate or C["databars"].framerate == 0 then return end
local barNum = C["databars"].framerate

T.databars[barNum]:Show()

local Stat = CreateFrame("Frame", nil, T.databars[barNum])
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)

local StatusBar = T.databars[barNum].statusbar
local Text = T.databars[barNum].text

local int = 1
local function Update(self, t)
	int = int - t
	if int < 0 then
		local fps = floor(GetFramerate())
		r, g, b = oUF.ColorGradient(fps/45, 0.8,0.2,0.2, 0.8,0.8,0.2, 0.2,0.8,0.2)
		Text:SetText(fps.." FPS")
		StatusBar:SetMinMaxValues(0, GetCVar("maxFPS"))
		StatusBar:SetValue(fps)
		StatusBar:SetStatusBarColor(r,g,b)
		self:SetAllPoints(T.databars[barNum])
		int = 1
	end	
end
Stat:SetScript("OnUpdate", Update) 
Update(Stat, 10)