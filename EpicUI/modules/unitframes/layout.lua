local T, C, L = unpack(Tukui)
C.unitframes.charportrait = nil

-- EpicUI Unitframes
T.Main, T.ToT, T.Boss = {200, 35}, {130, 25}, {200, 35}
local frames = {"Player", "Target", "TargetTarget", "Pet", "Focus"}

for _, frame in pairs(frames) do 
	
	local self = _G["Tukui"..frame]
	local unit = string.lower(frame)

	--lol
	self:ClearAllPoints()
	
	-- Positioning and Sizing
	if (unit == "player") then
		self:Point("RIGHT", UIParent, "CENTER", -150, -250)
		self:SetSize(unpack(T.Main))
	elseif (unit == "target") then
		self:Point("LEFT", UIParent, "CENTER", 150, -250)
		self:SetSize(unpack(T.Main))
	elseif (unit == "targettarget") then
		self:Point("TOPLEFT", TukuiTarget_Portrait, "TOPRIGHT", 3, 0)
		self:SetSize(unpack(T.ToT))
	elseif (unit == "pet") then
		self:Point("TOPRIGHT", TukuiPlayer_Portrait, "TOPLEFT", -3, 0)
		self:SetSize(unpack(T.ToT))
	elseif (unit == "focus") then
		self:Point("BOTTOM", TukuiPlayer, "TOP", -150, 150)
		self:SetSize(unpack(T.Main))
	end
	
	if self.shadow then
		self.shadow:Kill()
	end
	
	if (unit == "player") or (unit == "target") then
		local health = self.Health
		local power = self.Power
		local castbar = self.Castbar
		
		self.panel:Kill()
		
		power:ClearAllPoints()
		power:SetAllPoints()
		power:SetFrameLevel(3)
		power.bg.multiplier = 0.3
		
		health:ClearAllPoints()
		health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
		health:CreateBorder(false, true)
		health:SetStatusBarColor(.2, .2, .2)
		health:SetFrameLevel(4)
		health:CreateShadow()
		
		if C["unitframes"].unicolor == true then
			health.bg:SetTexture(.6,.6,.6)
			health.bg:SetVertexColor(unpack(C.unitframes.deficitcolor))
		end
			
		health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 2)
		health.value:SetShadowColor(0,0,0,0)
		health.PostUpdate = T.PostUpdateHealth

		power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		power.value:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 2, 2)
		power.value:SetShadowColor(0,0,0,0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower	
		
		-- Portrait Border
		local portrait = CreateFrame("Frame", self:GetName().."_Portrait", self)
		if unit == "player" then
			portrait:CreatePanel("", self:GetHeight(), 1, "TOPRIGHT", power, "TOPLEFT", -3, 0)
			portrait:Point("BOTTOMRIGHT", power, "BOTTOMLEFT", -4, 0)
		else
			portrait:CreatePanel("", self:GetHeight(), 1, "TOPLEFT", power, "TOPRIGHT", 3, 0)
			portrait:Point("BOTTOMLEFT", power, "BOTTOMRIGHT", 4, 0)
		end
		
		-- Class Icons (THANKS HYDRA!)
		local class = portrait:CreateTexture(self:GetName().."_ClassIcon", "ARTWORK")
		class:Point("TOPLEFT", 2, -2)
		class:Point("BOTTOMRIGHT", -2, 2)
		
		class.bg = portrait:CreateTexture(nil, "BORDER")
		class.bg:SetAllPoints(class)
		class.bg:SetTexture(0,0,0)
		self.ClassIcon = class
		
		local AuraTracker = CreateFrame("Frame")
		self.AuraTracker = AuraTracker
		AuraTracker.icon = portrait:CreateTexture(nil, "OVERLAY")
		AuraTracker.icon:Point("TOPLEFT", 2, -2)
		AuraTracker.icon:Point("BOTTOMRIGHT", -2, 2)
		AuraTracker.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
		AuraTracker.text = T.SetFontString(portrait, C.media.font, 15, "THINOUTLINE")
		AuraTracker.text:SetPoint("CENTER")
		AuraTracker:SetScript("OnUpdate", T.UpdateAuraTrackerTime)
		
		if unit == "player" or unit == "target" then
			self:EnableElement('ClassIcon')
			self:EnableElement('AuraTracker')
		end
		
		-- castbar
		castbar:ClearAllPoints()
		castbar.bg:SetVertexColor(0.05, 0.05, 0.05)
		castbar:CreateBorder(false, true)

		castbar.Text:ClearAllPoints()
		castbar.Text:Point("LEFT", castbar, "LEFT", 2, 0)
		
		castbar.time:ClearAllPoints()
		castbar.time:Point("RIGHT", castbar, "RIGHT", -2, 0)
		
		if (unit == "player") then
			castbar:Point("BOTTOMLEFT", TukuiBar1, "TOPLEFT", 2 , 5)
			castbar:Point("TOPRIGHT", TukuiControl, "TOPRIGHT", -3, -3)
			castbar:Height(25)
			if C["unitframes"].cbicons == true then
				local bsize = castbar:GetHeight() + 2
				castbar.button:SetBackdrop(nil)
				castbar.button.shadow:Kill()
				castbar.button:CreateBorder(false, true)
				castbar.button:Size(bsize, bsize)
				castbar.button:ClearAllPoints()
				
				castbar.icon:ClearAllPoints()
				castbar.icon:Point("TOPLEFT", castbar.button)
				castbar.icon:Point("BOTTOMRIGHT", castbar.button)
				
				castbar.button:Point("BOTTOMLEFT", TukuiBar1, "TOPLEFT", 2, 3)
				castbar:Point("BOTTOMLEFT", castbar.button, "BOTTOMRIGHT", 1, 0)
			end
		else	
			castbar:Point("TOPLEFT", self, "BOTTOMLEFT", 2 , -5)
			castbar:Point("TOPRIGHT", portrait, "BOTTOMRIGHT", -2, -5)
			castbar:Height(15)
			if C["unitframes"].cbicons == true then
				castbar.icon:SetParent(castbar)
				castbar.icon:Point("TOPLEFT", self:GetName().."_Portrait", "TOPLEFT", 2, -2)
				castbar.icon:Point("BOTTOMRIGHT", self:GetName().."_Portrait", "BOTTOMRIGHT", -2, 2)
				castbar.button:Kill()
			end
		end
		
		if (unit == "player") then
			--Combat Icon
			local Combat = self.Combat
			Combat:ClearAllPoints()
			Combat:Point("TOPRIGHT", health, -2, 0)
			
			--FlashInfo
			self.FlashInfo:Kill()
			
			-- pvp status text
			self.Status:Kill()
			
			-- leader icon
			local Leader = self.Leader
			Leader:ClearAllPoints()
			Leader:Point("BOTTOMLEFT", portrait, "TOPLEFT", -2, -2)
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)

			--Rep and Exp
			if self.Experience then
				local experience = self.Experience
				experience:Kill()
			end
			
			if self.Reputation then
				local reputation = self.Reputation
				reputation:Kill()
			end
			
			-- Druid Mana Text
			if T.myclass == "DRUID" then
				local DruidManaText = self.DruidManaText		
				DruidManaText:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then
					-- Druid Mana Bar
					local DruidManaBackground = self.DruidManaBackground
					local DruidManaBarStatus = self.DruidMana
					DruidManaBackground:ClearAllPoints()
					DruidManaBackground:Height(4)
					DruidManaBackground:Point("TOPLEFT", health, 2, -2)
					DruidManaBackground:Point("TOPRIGHT", health, -2, -2)
					DruidManaBarStatus:Size(DruidManaBackground:GetWidth(), DruidManaBackground:GetHeight())
					
					-- Eclipse Bar
					local eclipseBar = self.EclipseBar
					local eclipseBarText = self.EclipseBar.Text
					local solarBar = eclipseBar.SolarBar
					local lunarBar = eclipseBar.LunarBar
					eclipseBar:ClearAllPoints()
					eclipseBar:SetAllPoints(DruidManaBackground)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					eclipseBarText:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
				
				end
				if T.myclass == "PALADIN" or T.myclass == "WARLOCK" then
					local bars
					if T.myclass == "PALADIN" then
						bars = self.HolyPower
					elseif T.myclass == "WARLOCK" then
						bars = self.SoulShards
					end
					bars:ClearAllPoints()
					bars:SetParent(health)
					bars:Point("TOPLEFT", 2, -2)
					bars:Point("TOPRIGHT", -2, -2)
					bars:SetFrameLevel(15)
					bars:Height(4)
					for i = 1, 3 do
						bars[i]:SetFrameLevel(16)
						bars[i]:Height(bars:GetHeight())
						if i == 1 then
							bars[i]:SetPoint("LEFT", bars)
							bars[i]:Width((bars:GetWidth()/3)-1)
							bars[i].bg:SetAllPoints(bars[i])
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
							bars[i]:Width(bars:GetWidth()/3)
							bars[i].bg:SetAllPoints(bars[i])
						end
					end
				end
				if T.myclass == "DEATHKNIGHT" then
					local Runes = self.Runes
					Runes:ClearAllPoints()
					Runes:SetParent(health)
					Runes:Point("TOPLEFT", 2, -2)
					Runes:Point("TOPRIGHT", -2, -2)
					Runes:SetFrameLevel(15)
					Runes:Height(4)
					for i = 1, 6 do
						Runes[i]:ClearAllPoints()
						Runes[i]:SetFrameLevel(16)
						Runes[i]:Height(Runes:GetHeight())
											
						if i == 1 then
							Runes[i]:Width(Runes:GetWidth()/6)
							Runes[i]:SetPoint("LEFT", Runes)
						else
							Runes[i]:Point("LEFT", Runes[i-1], "RIGHT", 1, 0)
							Runes[i]:Width((Runes:GetWidth()/6)-1)
						end
					end
				end
				if T.myclass == "SHAMAN" then				
					local TotemBar = self.TotemBar
					for i = 1, 4 do
						TotemBar[i]:ClearAllPoints()
						TotemBar[i]:Height(4)
						TotemBar[i]:SetFrameLevel(15)
						if (i == 1) then
							TotemBar[i]:Point("TOPLEFT", health, "TOPLEFT", 2, -2)
						else
							TotemBar[i]:Point("TOPLEFT", TotemBar[i-1], "TOPRIGHT", 1, 0)
						end
						
						if i == 1 then
							TotemBar[i]:SetWidth((self:GetWidth()/4)-2)
						else
							TotemBar[i]:SetWidth((self:GetWidth()/4)-3)
						end
					end
				end
				if T.myclass == "ROGUE" then
					
				end
			end
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = self.Name
			Name:ClearAllPoints()
			Name:Point("TOPLEFT", health, "TOPLEFT", 2, 0)
			Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")

		end
	end
	
	-- Target of Target 
	if (unit == "targettarget") then
		self.panel:Kill()
		--Given Panel(Killed), Health, Name, Debuffs // Rest I need to make
		local health = self.Health
		local healthBG = self.Health.bg
		local Name = self.Name
		local debbuffs = self.Debuffs
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Point("TOPLEFT", self)
		power:Point("BOTTOM", self)
		power:SetStatusBarTexture(C.media.normTex)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(C.media.normTex)
		powerBG.multiplier = 0.3
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			power.colorTapping = true
			power.colorClass = true				
		else
			power.colorPower = true
		end
		
		power:CreateBorder(false, true)
		power:SetFrameLevel(3)
		
		self.Power = power
		self.Power.bg = powerBG
		
		self:EnableElement('Power')
		
		health:ClearAllPoints()
		health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
		health:CreateBorder(false, true)
		health:SetStatusBarColor(.2, .2, .2)
		health:SetFrameLevel(4)
		health:CreateShadow()
		
		if C["unitframes"].unicolor == true then
			healthBG:SetTexture(.6,.6,.6)
			healthBG:SetVertexColor(unpack(C.unitframes.deficitcolor))
		end
			
		power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		power.value:SetAlpha(0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 2)
		health.value:SetShadowColor(0,0,0,0)
		health.PostUpdate = T.PostUpdateHealth
		
		Name:ClearAllPoints()
		Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		Name:Point("LEFT", health, "LEFT", 3, 0)
	
		if (C["unitframes"].unitcastbar == true) then				
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(C["media"].normTex)
		
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(C["media"].normTex)
			castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
			castbar:SetFrameLevel(6)
			castbar:CreateBorder(false, true)
			castbar:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
			castbar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
			castbar:Height(7)
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			castbar.time:SetShadowColor(0,0,0,0)
			castbar.time:Point("TOPRIGHT", castbar, "BOTTOMRIGHT", -2, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			castbar.Text:SetShadowColor(0,0,0,0)
			castbar.Text:Point("TOPLEFT", castbar, "BOTTOMLEFT", 2, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			
			self:EnableElement('Castbar')
		end
	end
	
	-- Pet
	if (unit == "pet") then
		self.panel:Kill()
		
		local health = self.Health
		local healthBG = self.Health.bg
		local power = self.Power
		local Name = self.Name
		local debbuffs = self.Debuffs
	
		-- power
		power:ClearAllPoints()
		power:SetAllPoints()
		power.bg.multiplier = 0.3
		
		health:ClearAllPoints()
		health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
		health:CreateBorder(false, true)
		health:SetStatusBarColor(.2, .2, .2)
		health:SetFrameLevel(4)
		health:CreateShadow()
		
		if C["unitframes"].unicolor == true then
			healthBG:SetTexture(.6,.6,.6)
			healthBG:SetVertexColor(unpack(C.unitframes.deficitcolor))
		end
			
		power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		power.value:SetAlpha(0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 2)
		health.value:SetShadowColor(0,0,0,0)
		health.PostUpdate = T.PostUpdateHealth
		
		Name:ClearAllPoints()
		Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		Name:Point("LEFT", health, "LEFT", 3, 0)
	
		if (C["unitframes"].unitcastbar == true) then	
			local castbar = self.Castbar
			
			castbar:ClearAllPoints()
			castbar:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
			castbar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
			castbar:Height(7)
			castbar:CreateBorder(false, true)
			
			castbar.Text:ClearAllPoints()
			castbar.Text:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			castbar.Text:SetShadowColor(0,0,0,0)
			castbar.Text:Point("TOPLEFT", castbar, "BOTTOMLEFT", 2, 0)
			
			castbar.time:ClearAllPoints()
			castbar.time:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			castbar.time:SetShadowColor(0,0,0,0)
			castbar.time:Point("TOPRIGHT", castbar, "BOTTOMRIGHT", -2, 0)
		end
	end
	
	-- focus
	if (unit == "focus") then
		local health = self.Health
		local power = self.Power
		local castbar = self.Castbar
		
		power:ClearAllPoints()
		power:SetAllPoints()
		power:SetFrameLevel(3)
		power.bg.multiplier = 0.3
		
		health:ClearAllPoints()
		health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
		health:CreateBorder(false, true)
		health:SetStatusBarColor(.2, .2, .2)
		health:SetFrameLevel(4)
		health:CreateShadow()
		
		if C["unitframes"].unicolor == true then
			health.bg:SetTexture(.6,.6,.6)
			health.bg:SetVertexColor(unpack(C.unitframes.deficitcolor))
		end
			
		health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 2)
		health.value:SetShadowColor(0,0,0,0)
		health.PostUpdate = T.PostUpdateHealth

		power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		power.value:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 2, 2)
		power.value:SetShadowColor(0,0,0,0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower	
		
		-- Portrait Border
		local portrait = CreateFrame("Frame", self:GetName().."_Portrait", self)
		portrait:CreatePanel("", self:GetHeight(), 1, "TOPRIGHT", power, "TOPLEFT", -3, 0)
		portrait:Point("BOTTOMRIGHT", power, "BOTTOMLEFT", -4, 0)

		
		-- Class Icons (THANKS HYDRA!)
		local class = portrait:CreateTexture(self:GetName().."_ClassIcon", "ARTWORK")
		class:Point("TOPLEFT", 2, -2)
		class:Point("BOTTOMRIGHT", -2, 2)
		
		class.bg = portrait:CreateTexture(nil, "BORDER")
		class.bg:SetAllPoints(class)
		class.bg:SetTexture(0,0,0)
		self.ClassIcon = class
		
		local AuraTracker = CreateFrame("Frame")
		self.AuraTracker = AuraTracker
		AuraTracker.icon = portrait:CreateTexture(nil, "OVERLAY")
		AuraTracker.icon:Point("TOPLEFT", 2, -2)
		AuraTracker.icon:Point("BOTTOMRIGHT", -2, 2)
		AuraTracker.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
		AuraTracker.text = T.SetFontString(portrait, C.media.font, 15, "THINOUTLINE")
		AuraTracker.text:SetPoint("CENTER")
		AuraTracker:SetScript("OnUpdate", T.UpdateAuraTrackerTime)

		self:EnableElement('ClassIcon')
		self:EnableElement('AuraTracker')
		
		-- castbar
		castbar:ClearAllPoints()
		castbar:CreateBorder(false, true)

		castbar.Text:ClearAllPoints()
		castbar.Text:Point("LEFT", castbar, "LEFT", 2, 0)
		
		castbar.time:ClearAllPoints()
		castbar.time:Point("RIGHT", castbar, "RIGHT", -2, 0)
	
		castbar:Point("TOPRIGHT", self, "BOTTOMRIGHT", -2 , -5)
		castbar:Point("TOPLEFT", portrait, "BOTTOMLEFT", 2, -5)
		castbar:Height(15)
		if C["unitframes"].cbicons == true then
			castbar.icon:SetParent(castbar)
			castbar.icon:Point("TOPLEFT", self:GetName().."_Portrait", "TOPLEFT", 2, -2)
			castbar.icon:Point("BOTTOMRIGHT", self:GetName().."_Portrait", "BOTTOMRIGHT", -2, 2)
			castbar.button:Kill()
		end	
		
		-- Unit name on target
		local Name = self.Name
		Name:ClearAllPoints()
		Name:Point("TOPLEFT", health, "TOPLEFT", 2, 0)
		Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
	end
end

-- Boss and Arena
for i = 1, 4 do
	self = _G["TukuiBoss"..i]
	
	local health = self.Health
	local healthBG = self.Health.bg
	local power = self.Power

	-- power
	power:ClearAllPoints()
	power:SetAllPoints()
	power.bg.multiplier = 0.3
	
	health:ClearAllPoints()
	health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
	health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
	health:CreateBorder(false, true)
	health:SetStatusBarColor(.2, .2, .2)
	health:SetFrameLevel(4)
	health:CreateShadow()
	
	if C["unitframes"].unicolor == true then
		healthBG:SetTexture(.6,.6,.6)
		healthBG:SetVertexColor(unpack(C.unitframes.deficitcolor))
	end
		
	power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
	power.value:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 2, 2)
	power.value:SetShadowColor(0,0,0,0)
	power.PreUpdate = T.PreUpdatePower
	power.PostUpdate = T.PostUpdatePower
	
	health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
	health.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 2)
	health.value:SetShadowColor(0,0,0,0)
	health.PostUpdate = T.PostUpdateHealth

	-- Unit name on target
	local Name = self.Name
	Name:ClearAllPoints()
	Name:Point("TOPLEFT", health, "TOPLEFT", 2, 0)
	Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
end
TukuiBoss1:ClearAllPoints()
TukuiBoss1:Point("BOTTOM", TukuiTarget, "TOP", 150, 150)

-- Raid Frames
local function SkinRaid()
	local numGrid = (GetNumPartyMembers() + 1)
	if UnitInRaid("player") then
		numGrid = GetNumRaidMembers()
	end

	for i = 1, numGrid do  
		local self = 0
		if numGrid > 25 then
			self = _G["TukuiRaid40UnitButton"..i]
			
			local power = CreateFrame("StatusBar", nil, self)
			power:ClearAllPoints()
			power:SetAllPoints()
			power:SetStatusBarTexture(C["media"].normTex)
			self.Power = power
			
			power.frequentUpdates = true
			power.colorDisconnected = true

			power.bg = self.Power:CreateTexture(nil, "BORDER")
			power.bg:SetAllPoints(power)
			power.bg:SetTexture(C["media"].normTex)
			power.bg:SetAlpha(1)
			power.bg.multiplier = 0.3
			self.Power.bg = power.bg
			
			if C.unitframes.unicolor == true then
				power.colorClass = true
				power.bg.multiplier = 0.1				
			else
				power.colorPower = true
			end
		else
			self = _G["TukuiRaid25UnitButton"..i]
				
			local power = self.Power
			power:ClearAllPoints()
			power:SetAllPoints()
			power.bg.multiplier = 0.3
		end
		
		self:EnableElement('Power')
		
		local health = self.Health
		local healthBG = self.Health.bg
		
		health:ClearAllPoints()
		health:SetPoint("TOPLEFT", self.Power, "TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", -2, 2)
		health:CreateBorder(false, true)
		health:SetStatusBarColor(.2, .2, .2)
		health:SetFrameLevel(4)
		health:CreateShadow()
		
		if C["unitframes"].unicolor == true then
			healthBG:SetTexture(.6,.6,.6)
			healthBG:SetVertexColor(unpack(C.unitframes.deficitcolor))
		end
			
		-- self.Power.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		-- self.Power.value:SetAlpha(0)
		-- self.Power.PreUpdate = T.PreUpdatePower
		-- self.Power.PostUpdate = T.PostUpdatePower
		
		health.value = T.SetFontString(health, C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 2, 1)
		health.value:SetShadowColor(0,0,0,0)
		health.PostUpdate = T.PostUpdateHealthRaid
	end
end

local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
testFrame:RegisterEvent("PLAYER_LOGIN")
testFrame:RegisterEvent("RAID_ROSTER_UPDATE")
if IsAddOnLoaded("Tukui_Raid") then
	testFrame:SetScript("OnEvent", SkinRaid)
end






