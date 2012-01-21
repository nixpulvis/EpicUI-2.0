local T, C, L = unpack(Tukui)
--[[
--Base code by Dawn (dNameplates), rewritten by Elv22
if not C["nameplate"].enable == true then return end

local FONT = C["media"].font
local FONTSIZE = 10
local FONTFLAG = "THINOUTLINE"
local hpWidth = 110
local noscalemult = T.mult * C["general"].uiscale

--Create our Aura Icons
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)
	
	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetTexture(unpack(C["media"].backdropcolor))
	button.bg:SetAllPoints(button)
	
	button.bord = button:CreateTexture(nil, "BORDER")
	button.bord:SetTexture(unpack(C["media"].bordercolor))
	button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
	button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
	
	button.bg2 = button:CreateTexture(nil, "ARTWORK")
	button.bg2:SetTexture(unpack(C["media"].backdropcolor))
	button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
	button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)	
	
	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.cd = CreateFrame("Cooldown",nil,button)
	button.cd:SetAllPoints(button)
	button.cd:SetReverse(true)
	button.count = button:CreateFontString(nil,"OVERLAY")
	button.count:SetFont(FONT,7,FONTFLAG)
	button.count:SetShadowColor(0, 0, 0, 0.4)
	button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -2)
	return button
end

--Update an Aura Icon
local function UpdateAuraIcon(button, unit, index, filter)
	local name,_,icon,count,debuffType,duration,expirationTime,_,_,_,spellID = UnitAura(unit,index,filter)
	
	button.icon:SetTexture(icon)
	button.cd:SetCooldown(expirationTime-duration,duration)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	if count > 1 then 
		button.count:SetText(count)
	else
		button.count:SetText("")
	end
	button.cd:SetScript("OnUpdate", function(self) if not button.cd.timer then self:SetScript("OnUpdate", nil) return end button.cd.timer.text:SetFont(FONT,9,FONTFLAG) button.cd.timer.text:SetShadowColor(0, 0, 0, 0.4) end)
	button:Show()
end

--Filter auras on nameplate, and determine if we need to update them or not.
local function OnAura(frame, unit)
	if not frame.icons or not frame.unit then return end
	local i = 1
	for index = 1,40 do
		if i > 5 then return end
		local match
		local name,_,_,_,_,duration,_,caster,_,_,spellid = UnitAura(frame.unit,index,"HARMFUL")
		if caster == "player" then match = true end
		
		if duration and match == true then
			if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
			local icon = frame.icons[i]
			if i == 1 then icon:SetPoint("RIGHT",frame.icons,"RIGHT") end
			if i ~= 1 and i <= 5 then icon:SetPoint("RIGHT", frame.icons[i-1], "LEFT", -2, 0) end
			i = i + 1
			UpdateAuraIcon(icon, frame.unit, index, "HARMFUL")
		end
	end
	for index = i, #frame.icons do frame.icons[index]:Hide() end
end

local function UpdateObjects(frame)
	-- Aura tracking
	if C["nameplate"].trackauras == true then
		if frame.icons then return end
		frame.icons = CreateFrame("Frame",nil,frame)
		frame.icons:SetPoint("BOTTOMRIGHT",frame.hp,"TOPRIGHT", 2, FONTSIZE+3)
		frame.icons:SetWidth(20 + hpWidth)
		frame.icons:SetHeight(25)
		frame.icons:SetFrameLevel(frame.hp:GetFrameLevel()+2)
		frame:RegisterEvent("UNIT_AURA")
		frame:HookScript("OnEvent", OnAura)
	end	
end

for i = 1, 10 do
	local frame = select(i, WorldFrame:GetChildren())
	print(frame)
	-- frame.hp:HookScript('OnShow', UpdateObjects)
	-- UpdateObjects(hp)
end
]]