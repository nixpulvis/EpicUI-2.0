-- raid editing guide by hydra/tukz

local T, C, L = unpack(Tukui)

--------------------------------------------------------------
-- Edit Unit Raid Frames here!
--------------------------------------------------------------
-- 1 second delay before edited skin apply (can probably be a lower because 1 second is really too long, 0.1 or 0.2 should be the best, setting it to 1 was just for testing, CANNOT BE 0)
local delay = .1 

local function EditUnitFrame(frame, header)
	local name = frame.Name
	local health = frame.Health
	local power = frame.Power
	local panel = frame.panel
	local name = frame.Name
	-- continue adding element... 
	if header ~= TukuiRaid40 then
		power:ClearAllPoints()
		power:SetAllPoints(frame)
	else
		power = CreateFrame("StatusBar", nil, frame)
		power:SetAllPoints()
		power:SetStatusBarTexture(C["media"].normTex)
		frame.Power = power

		power.frequentUpdates = true
		power.colorDisconnected = true

		power.bg = power:CreateTexture(nil, "BORDER")
		power.bg:SetAllPoints(power)
		power.bg:SetTexture(C["media"].normTex)
		power.bg:SetAlpha(1)
		power.bg.multiplier = 0.4
		
		if C.unitframes.unicolor == true then
			power.colorClass = true
			power.bg.multiplier = 0.1				
		else
			power.colorPower = true
			power.PostUpdate = T.PreUpdatePower
		end
		frame:EnableElement('Power')
	end
	
	health:ClearAllPoints()
	health:SetParent(power)
	health:Point("TOPLEFT", power, "TOPLEFT", 2, -2)
	health:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
	health:CreateBorder(false, true)
	
	health.bg:SetTexture(.6,.6,.6)
	health.bg:SetVertexColor(unpack(C.unitframes.deficitcolor))
	
	name:SetFont(C.media.pixelfont, 12*C["unitframes"].gridscale*T.raidscale, "MONOCHROMEOUTLINE")
	-- for layout-specifics, here we edit only 1 layout at time
	if header == TukuiRaid25 then
		-- more blah
	elseif header == TukuiRaid40 then
		-- more blah
	elseif header == TukuiRaidHealer15 then
		-- more blah
	elseif header == TukuiRaidHealerGrid then		
		panel:ClearAllPoints()
		panel:Size(name:GetStringWidth()+10, 14)
		panel:Point("CENTER", frame, "CENTER", 0, 2)
		panel:SetFrameStrata("HIGH")
		panel:SetFrameLevel(5)	
		
		name:SetParent(panel)
		name:ClearAllPoints()
		name:SetPoint("CENTER", 0, 1)
		
		health.value:Point("BOTTOM", health, "BOTTOM", 0, 2)
		health.value:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
		health.value:SetShadowColor(0,0,0,0)
	end
end

local function EditUnitAttributes(layout)
	local header = _G[layout]
	local dpsmax25 = layout:match("Raid25")
	local dpsmax40 = layout:match("Raid40")
	local healmax15 = layout:match("Healer15")
	local grid = layout:match("HealerGrid")
	
	-- set your new attributes here, in this example we only resize units, X/Y offset and column spacing to Grid.
	if dpsmax25 then
		header:SetAttribute("initial-height", 20)
	elseif dpsmax40 then
		header:SetAttribute("initial-height", 12)
	elseif grid then
		header:SetAttribute("initial-width", 90)
		header:SetAttribute("initial-height", 45)
		header:SetAttribute("xoffset", 2)
		header:SetAttribute("yOffset", -2)
		header:SetAttribute("columnSpacing", T.Scale(2))
	end
end

--------------------------------------------------------------
-- Stop Editing!
--------------------------------------------------------------

-- import the framework
local oUF = oUFTukui or oUF

local function InitScript()
	local children
	local heal = IsAddOnLoaded("Tukui_Raid_Healing")
	local dps = IsAddOnLoaded("Tukui_Raid")
	
	-- don't need to load, because we will reload anyway after user select their layout
	if heal and dps then return end
	
	local function UpdateRaidUnitSize(frame, header)
		frame:SetSize(header:GetAttribute("initial-width"), header:GetAttribute("initial-height"))
	end

	local GetActiveHeader = function()
		local players = (GetNumPartyMembers() + 1)
		
		if UnitInRaid("player") then
			players = GetNumRaidMembers()
		end

		if heal then
			if C["unitframes"].gridonly then
				return TukuiRaidHealerGrid
			else
				if players <= 15 then
					return TukuiRaidHealer15
				else
					return TukuiRaidHealerGrid
				end
			end
		elseif dps then
			if players <= 25 then
				return TukuiRaid25
			elseif players > 25 then
				return TukuiRaid40
			end
		end
	end
	
	local function Update(frame, header, event)
		if (frame and frame.unit) then
			local isEdited = frame.isEdited
			
			-- we need to update size of every raid frames if already in raid when we enter world (or /rl)
			if event == "PLAYER_ENTERING_WORLD" then
				UpdateRaidUnitSize(frame, header)
			end
			
			-- we check for "isEdited" here because we don't want to edit every frame
			-- every time a member join the raid else it will cause high cpu usage
			-- and could cause screen freezing
			if not frame.isEdited then
				EditUnitFrame(frame, header)
				frame.isEdited = true
			end
		end	
	end

	local function Skin(header, event)
		children = {header:GetChildren()}
		
		for _, frame in pairs(children) do
			Update(frame, header, event)
		end	
	end
	
	local StyleRaidFrames = function(self, event)
		local header = GetActiveHeader()
		-- make sure we... catch them all! (I feel pikachu inside me)
		-- we add a delay to make sure latest created unit is catched.
		T.Delay(delay, function() Skin(header, event) end)
	end

	-- init, here we modify the initial Config.
	local function SpawnHeader(name, layout, visibility, ...)
		EditUnitAttributes(layout)
	end
	
	-- this is the function oUF framework use to create and set attributes to headers
	hooksecurefunc(oUF, "SpawnHeader", SpawnHeader)

	local style = CreateFrame("Frame")
	style:RegisterEvent("PLAYER_ENTERING_WORLD")
	style:RegisterEvent("PARTY_MEMBERS_CHANGED")
	style:RegisterEvent("RAID_ROSTER_UPDATE")
	style:SetScript("OnEvent", StyleRaidFrames)
end

local script = CreateFrame("Frame")
script:RegisterEvent("ADDON_LOADED")
script:SetScript("OnEvent", function(self, event, addon)
	if addon == "Tukui_Raid" or addon == "Tukui_Raid_Healing" then
		InitScript()
	end
end)





--[[



local T, C, L = unpack(Tukui)
C.unitframes.gridonly = true

local children

local GetActiveLayout = function()
	local players = (GetNumPartyMembers() + 1)
	if UnitInRaid("player") then
		players = GetNumRaidMembers()
	end

	if IsAddOnLoaded("Tukui_Raid_Healing") then
		return TukuiRaidHealerGrid
	elseif IsAddOnLoaded("Tukui_Raid") then
		if players <= 25 then
			return TukuiRaid25
		elseif players > 25 then
			return TukuiRaid40
		end
	end
end

local StyleRaidFrames = function()
	local layout = GetActiveLayout()
	children = {GetActiveLayout():GetChildren()}

	for _, self in pairs(children) do
		if (self and self.unit) then
			local name = self.Name
			local health = self.Health
			local Name = self.Name
			local power
			
			if layout ~= TukuiRaid40 then
				power = self.Power
				power:ClearAllPoints()
				power:SetAllPoints()
				power.bg.multiplier = 0.3
			else
				power = CreateFrame("StatusBar", nil, self)
				power:SetAllPoints()
				power:SetStatusBarTexture(C["media"].normTex)
				self.Power = power

				power.frequentUpdates = true
				power.colorDisconnected = true

				power.bg = power:CreateTexture(nil, "BORDER")
				power.bg:SetAllPoints(power)
				power.bg:SetTexture(C["media"].normTex)
				power.bg:SetAlpha(1)
				power.bg.multiplier = 0.4
				
				if C.unitframes.unicolor == true then
					power.colorClass = true
					power.bg.multiplier = 0.1				
				else
					power.colorPower = true
					power.PostUpdate = T.PreUpdatePower
				end
				self:EnableElement('Power')
			end
			
			health:ClearAllPoints()
			health:SetPoint("TOPLEFT", power, "TOPLEFT", 2, -2)
			health:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", -2, 2)
			health:CreateBorder(false, true)
			health:SetStatusBarColor(.2, .2, .2)
			health:SetFrameLevel(4)
			
			if C["unitframes"].unicolor == true then
				health.bg:SetTexture(.6,.6,.6)
				health.bg:SetVertexColor(unpack(C.unitframes.deficitcolor))
			end

			-- Unit name on target
			Name:ClearAllPoints()
			Name:SetParent(health)
			Name:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
			
			if layout == TukuiRaidHealerGrid then
				self:Size(74, 40)
				
				self.panel:ClearAllPoints()
				self.panel:Size(Name:GetStringWidth()+6, 12)
				self.panel:Point("CENTER", self, "CENTER", 0, 2)
				self.panel:SetFrameStrata("MEDIUM")
				self.panel:SetFrameLevel(5)				
				
				Name:ClearAllPoints()
				Name:SetParent(self.panel)
				Name:Point("LEFT", self.panel, "LEFT", 4, 1)
				
				health.value:Point("BOTTOM", health, "BOTTOM", 0, 2)
				health.value:SetFont(C.media.pixelfont, 12, "MONOCHROMEOUTLINE")
				health.value:SetShadowColor(0,0,0,0)				
			elseif layout == TukuiRaid25 then
				self:Size(74, 25)
				Name:Point("TOPLEFT", health, "TOPLEFT", 4, 0)
			elseif layout == TukuiRaid40 then
				self:Size(74, 15)
				Name:Point("TOPLEFT", health, "TOPLEFT", 4, 0)
			end
		end
	end
	
	-- TukuiRaidHealerGrid:SetAttribute("xoffset", T.Scale(3))
	-- TukuiRaidHealerGrid:SetAttribute("yoffset", T.Scale(-3))
	-- TukuiRaidHealerGrid:SetAttribute("initial-width", T.Scale(75*C["unitframes"].gridscale*T.raidscale))
	-- TukuiRaidHealerGrid:SetAttribute("initial-height", T.Scale(40*C["unitframes"].gridscale*T.raidscale))
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:SetScript("OnEvent", StyleRaidFrames)]]