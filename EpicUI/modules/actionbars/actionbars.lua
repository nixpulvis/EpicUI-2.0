local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

TukuiBar4Button:Kill()

TukuiBar3:ClearAllPoints()
TukuiBar3:Point("BOTTOMLEFT", TukuiChatBackgroundRight, "TOPLEFT", 0, 3)
TukuiBar3:Point("BOTTOMRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", 0, 3)
TukuiBar3:Height(C.actionbar.buttonsize + (T.buttonspacing * 2))
TukuiBar3:SetAlpha(.75)
for i= 1, 12 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:ClearAllPoints()
	b:SetFrameStrata("BACKGROUND")
	b:SetFrameLevel(15)
	
	if i == 1 then
		b:SetPoint("BOTTOMLEFT", TukuiBar3, T.buttonspacing, T.buttonspacing)
	elseif i == 2 or i == 3 or i == 6 or i == 9 or i == 12 then
		b:SetPoint("LEFT", b2, "RIGHT", T.buttonspacing + 1, 0)
	else
		b:SetPoint("LEFT", b2, "RIGHT", T.buttonspacing, 0)
	end
end

TukuiBar2:ClearAllPoints()
TukuiBar2:Point("BOTTOMLEFT", TukuiControl, "TOPLEFT", 1, 0)
TukuiBar2:Point("BOTTOMRIGHT", TukuiControl, "TOPRIGHT", -1, 0)
TukuiBar2:Height(C.actionbar.buttonsize + (T.buttonspacing * 2))

for i= 1, 12 do
	local b = _G["MultiBarBottomLeftButton"..i]
	local b2 = _G["MultiBarBottomLeftButton"..i-1]
	b:ClearAllPoints()
	b:SetFrameStrata("BACKGROUND")
	b:SetFrameLevel(15)
	
	if i == 1 then
		b:SetPoint("BOTTOMLEFT", TukuiBar2, T.buttonspacing, T.buttonspacing)
	else
		b:SetPoint("LEFT", b2, "RIGHT", T.buttonspacing, 0)
	end
end

local function MoveButtonBar(button, bar)
	local db = TukuiDataPerChar
	
	-- Anchor to fancy new control panel
	if button == TukuiBar2Button then
		if bar:IsShown() then
			db.hidebar2 = false
			button:ClearAllPoints()
			button:Point("LEFT", TukuiControl, 4, 0)
			button.text:SetText("|cff4BAF4C-|r")
		else
			db.hidebar2 = true
			button:ClearAllPoints()
			button:Point("LEFT", TukuiControl, 4, 0)
			button.text:SetText("|cff4BAF4C+|r")
		end
	end
	
	if button == TukuiBar3Button then
		if bar:IsShown() then
			db.hidebar3 = false
			button:ClearAllPoints()
			button:Point("BOTTOMLEFT", TukuiBar2Button, "BOTTOMRIGHT", 3, 0)
			button.text:SetText("|cff4BAF4C<|r")
		else
			db.hidebar3 = true
			button:ClearAllPoints()
			button:Point("BOTTOMLEFT", TukuiBar2Button, "BOTTOMRIGHT", 3, 0)
			button.text:SetText("|cff4BAF4C>|r")
		end
	end
end

local init = CreateFrame("Frame")
init:RegisterEvent("VARIABLES_LOADED")
init:SetScript("OnEvent", function(self, event)
	MoveButtonBar(TukuiBar2Button, TukuiBar2)
	MoveButtonBar(TukuiBar3Button, TukuiBar3)
end)

-- Bar 2 Button Settup
TukuiBar2Button:ClearAllPoints()
TukuiBar2Button:Point("LEFT", TukuiControl, 4, 0)
TukuiBar2Button:Size(20, 20)
TukuiBar2Button:SetAlpha(1)
TukuiBar2Button:HookScript("OnClick", function(self)
	MoveButtonBar(self, TukuiBar2)
end)
TukuiBar2Button:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(.4, .4, .4) end)
TukuiBar2Button:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)

-- Bar 3 Button Settup
TukuiBar3Button:ClearAllPoints()
TukuiBar3Button:Point("BOTTOMLEFT", TukuiBar2Button, "BOTTOMRIGHT", 3, 0)
TukuiBar3Button:Size(20, 20)
TukuiBar3Button:SetAlpha(1)
TukuiBar3Button:HookScript("OnClick", function(self)
	MoveButtonBar(self, TukuiBar3)
end)
TukuiBar3Button:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(.4, .4, .4) end)
TukuiBar3Button:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
