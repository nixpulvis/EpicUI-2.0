-- raid editing guide by hydra/tukz

local T, C, L = unpack(Tukui)

--[[
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
	if header == TukuiRaid25 or header == TukuiRaid40 then
		name:ClearAllPoints()
		name:SetPoint("LEFT", 2, 1)
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
	local function SetAttributes()
		if dpsmax25 or dpsmax40 then
			header:SetAttribute("initial-width", 75)
			header:SetAttribute("initial-height", 20)
			header:SetAttribute("xoffset", T.Scale(3))
			header:SetAttribute("yOffset", T.Scale(-3))
			header:SetAttribute("point", "LEFT")
			header:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
			header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
			header:SetAttribute("groupBy", "GROUP")
			header:SetAttribute("maxColumns", 8)
			header:SetAttribute("unitsPerColumn", 5)
			header:SetAttribute("columnSpacing", T.Scale(3))
			header:SetAttribute("columnAnchorPoint", "TOP")
			
			header:ClearAllPoints()
			header:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "TOPLEFT", 0, 300)
		elseif grid then
		
		end
	end
	
	SetAttributes()
	if dpsmax25 or dpsmax40 then
		for i = 1, header:GetNumChildren() do
			local child = select(i, header:GetChildren())
			if child and child.unit then
				child:ClearAllPoints()
			end
		end	
	end
	SetAttributes()
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
end)]]