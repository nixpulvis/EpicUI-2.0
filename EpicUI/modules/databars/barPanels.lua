local T, C, L = unpack(Tukui)

databar_settings = {
	height = 21,								-- set the height of the bars
	width = 100,								-- set the width of the bars
	spacing = 3,								-- amount of spacing between bars
	padding = 3,								-- amount of space between sections (skip a number to make a new "section", e.g. fps:3, latency:4, memory:5, bags:7)
}

local pWidth, pHeight = databar_settings.width, databar_settings.height
T["databars"] = {}

local hovercolor = {.6, .6, .6}

T.maxDatabars = 0
for i,v in pairs(C.databars) do
	if (type(v) == "number" and v > 0) then T.maxDatabars = max(T.maxDatabars, v) end
end
if T.maxDatabars == 0 then return end

for i = 1, T.maxDatabars do
	T.databars[i] = CreateFrame("Frame", "TukuiDataBar"..i.."_Panel", UIParent)
	if i == 1 then
		T.databars[i]:CreatePanel("ThickTransparent", pWidth, pHeight, "TOPRIGHT", TukuiMinimap, "TOPLEFT", -12, -2)
	else
		T.databars[i]:CreatePanel("ThickTransparent", pWidth, pHeight, "TOPRIGHT", T.databars[i-1], "BOTTOMRIGHT", 0, -databar_settings.spacing)
	end
	
	T.databars[i].statusbar = CreateFrame("StatusBar",  "TukuiDataBar"..i.."_StatusBar", T.databars[i], "TextStatusBar")
	T.databars[i].statusbar:SetFrameStrata("BACKGROUND")
	T.databars[i].statusbar:SetStatusBarTexture(C.media.normTex)
	T.databars[i].statusbar:SetStatusBarColor(1,1,1)
	T.databars[i].statusbar:SetFrameLevel(2)
	T.databars[i].statusbar:SetPoint("TOPRIGHT", T.databars[i], "TOPRIGHT", -2, -2)
	T.databars[i].statusbar:SetPoint("BOTTOMLEFT", T.databars[i], "BOTTOMLEFT", 2, 2)
	T.databars[i].statusbar:SetMinMaxValues(0,1)
	T.databars[i].statusbar:SetValue(0)
	
	T.databars[i].text = T.databars[i].statusbar:CreateFontString("DataBar"..i.."_Text", "OVERLAY")
	T.databars[i].text:SetFont(C.media.pixelfont, C.datatext.fontsize, "MONOCHROMEOUTLINE")
	T.databars[i].text:SetPoint("TOPRIGHT", T.databars[i].statusbar, "TOPRIGHT", -2, -2)
	T.databars[i].text:SetPoint("BOTTOMLEFT", T.databars[i].statusbar, "BOTTOMLEFT", 3, 3)
	
	T.databars[i]:Hide()
end

local function hideDatabars(self)
	for i = 1, T.maxDatabars do
		T.databars[i]:Hide()
	end
	self.text:SetVerticalText("open")
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", TukuiMinimap, "TOPLEFT", -3, 0)
	self:SetPoint("BOTTOMRIGHT", TukuiMinimap, "BOTTOMLEFT", -3, 0)
	self:SetAlpha(1)
	T.databars["toggle"]:HookScript("OnEnter", function(self) self:SetAlpha(1) self:SetBackdropBorderColor(unpack(hovercolor)) end)
	T.databars["toggle"]:HookScript("OnLeave", function(self) self:SetAlpha(1) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
end

local function showDatabars(self)
	for i = 1, T.maxDatabars do
		T.databars[i]:Show()
	end
	self.text:SetVerticalText("close")
	self:ClearAllPoints()
	self:Point("TOPRIGHT", databarsBG, "TOPLEFT", -3, 0)
	self:Point("BOTTOMRIGHT", databarsBG, "BOTTOMLEFT", -3, 0)
	
	T.databars["toggle"]:HookScript("OnEnter", function(self) self:SetAlpha(1) self:SetBackdropBorderColor(unpack(hovercolor)) end)
	T.databars["toggle"]:HookScript("OnLeave", function(self) self:SetAlpha(0) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
end

-- Background
databarsBG = CreateFrame("Frame", "TukuiDataBarBG", UIParent)
databarsBG:CreatePanel("ThickTransparent", 0, 0, "TOP", T.databars[1], "TOP", 0, 0)
databarsBG:Point("TOPLEFT", T.databars[1], "TOPLEFT", -2, 2)
databarsBG:Point("BOTTOMRIGHT", T.databars[T.maxDatabars], "BOTTOMRIGHT", 2, -2)

-- Lines
line1 = CreateFrame("Frame", nil, databarsBG)
line1:CreatePanel("Default", 12, 2, "LEFT", databarsBG, "RIGHT", -1, 35)
line1:SetFrameStrata("BACKGROUND")

line2 = CreateFrame("Frame", nil, databarsBG)
line2:CreatePanel("Default", 12, 2, "LEFT", databarsBG, "RIGHT", -1, -35)
line2:SetFrameStrata("BACKGROUND")

-- Toggle
T.databars["toggle"] = CreateFrame("Frame", "TukuiDataBarToggle", UIParent)
T.databars["toggle"]:SetAlpha(0)
T.databars["toggle"].text = T.databars["toggle"]:CreateFontString(nil, "OVERLAY")
T.databars["toggle"].text:SetFont(C.media.pixelfont, C.datatext.fontsize, "MONOCHROMEOUTLINE")
T.databars["toggle"].text:SetJustifyH("LEFT")
T.databars["toggle"].text:SetPoint("CENTER")
T.databars["toggle"].text:SetVerticalText("close")

T.databars["toggle"]:CreatePanel("ThickTransparent", 20, 1, "TOPRIGHT", databarsBG, "TOPLEFT", -3, 0)
T.databars["toggle"]:Point("BOTTOMRIGHT", databarsBG, "BOTTOMLEFT", -3, 0)
T.databars["toggle"]:EnableMouse(true)

T.databars["toggle"]:HookScript("OnEnter", function(self) self:SetAlpha(1) self:SetBackdropBorderColor(unpack(hovercolor)) end)
T.databars["toggle"]:HookScript("OnLeave", function(self) self:SetAlpha(0) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
T.databars["toggle"]:SetScript("OnMouseDown", function(self) 
	if T.databars[1]:IsShown() then
		hideDatabars(self)
		databarsBG:Hide()
		TukuiDataPerChar.hidedatabars = true
	else
		showDatabars(self)
		databarsBG:Show()
		TukuiDataPerChar.hidedatabars = false
	end
end)

T.databars["toggle"]:RegisterEvent("PLAYER_ENTERING_WORLD")
T.databars["toggle"]:SetScript("OnEvent", function(self, event)
	T.databars["toggle"]:UnregisterEvent("PLAYER_ENTERING_WORLD")	
	-- Setup the Perchar Variable
	if (TukuiDataPerChar.hidedatabars == nil) then
		TukuiDataPerChar.hidedatabars = true
	end

	 -- Hide the bars on load
	if TukuiDataPerChar.hidedatabars == true then
		hideDatabars(self)
		databarsBG:Hide()
	end
end)






