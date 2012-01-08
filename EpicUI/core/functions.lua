local T, C, L = unpack(Tukui)
----------------------
-- EPICUI FUNCTIONS --
----------------------

--Killing functions I don't want
T.PostNamePosition = T.dummy

-- Stupid shadow
-- hooksecurefunc(T, "PostCreateAura", function(element, button)
	-- button.Glow:Kill()
-- end)

-- master looter icon
T.MLAnchorUpdate = T.dummy
T.MLAnchorUpdate = function(self)
	self.MasterLooter:ClearAllPoints()
	if self.Leader:IsShown() then
		self.MasterLooter:SetPoint("BOTTOMLEFT", self:GetName().."_Portrait", "TOPLEFT", 10, 0)
	else
		self.MasterLooter:SetPoint("BOTTOMLEFT", self:GetName().."_Portrait", "TOPLEFT", -2, -2)
	end
end

T.UpdateAuraTrackerTime = function(self, elapsed)
	if (self.active) then
		self.timeleft = self.timeleft - elapsed

		if (self.timeleft <= 5) then
			self.text:SetTextColor(1, 0, 0)
		else
			self.text:SetTextColor(1, 1, 1)
		end
		
		if (self.timeleft <= 0) then
			self.icon:SetTexture("")
			self.text:SetText("")
		end	
		self.text:SetFormattedText("%.1f", self.timeleft)
	end
end

T.DataBarPoint = function(p, obj)
	obj:SetPoint("TOPRIGHT", T.databars[p], "TOPRIGHT", -2, -2)
	obj:SetPoint("BOTTOMLEFT", T.databars[p], "BOTTOMLEFT", 2, 2)
end

T.DataBarTooltipAnchor = function(barNum)
	local xoff = -T.databars[barNum]:GetWidth()
	local yoff = T.Scale(-5)
	
	if databar_settings.vertical then
		xoff = T.Scale(5)
		yoff = T.databars[barNum]:GetHeight()
	end
	
	return xoff, yoff
end

function T.CommaValue(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

---------------------------------------------------
-- just fucking around --
---------------------------------------------------
local bsize = 45
local dots = {}
local xoffset = 70

local anchor = CreateFrame("Frame", "MouseoverDotTracker", UIParent)
anchor:SetTemplate()
anchor:SetFrameStrata("BACKGROUND")

local function SetToMouse(f)
	local scale = UIParent:GetEffectiveScale()
	local framescale = f:GetScale()
	local x, y = GetCursorPosition()
	x = (x / scale / framescale) - f:GetWidth() / 2
	y = (y / scale / framescale) - f:GetHeight() / 2
	f:ClearAllPoints()
	f:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x+xoffset, y )
end

local function SetButtonTexture(f)
	f.texture = f:CreateTexture(nil, "BORDER")
	f.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.texture:Point("TOPLEFT", f ,"TOPLEFT", 2, -2)
	f.texture:Point("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -2, 2)
	
	-- f.cooldown = CreateFrame("Cooldown", "$parentCD", f, "CooldownFrameTemplate")
	-- f.cooldown:SetAllPoints(f.texture)	
	
	f.textured = true
end

local function Dottable()
	if UnitCanAttack("player", "mouseover") and (not UnitIsDead("mouseover")) then
		return true
	else
		return false
	end
end

local function CreateButtons()
	local dotframe = CreateFrame("Frame", nil, anchor)
	anchor:Size(bsize+6, (bsize*#dots)+(2*#dots)+4)
	
	for i, v in ipairs(dots) do
		dotframe[i] = CreateFrame("Frame", "MouseoverDot"..i, anchor)
		if i == 1 then
			dotframe[i]:CreatePanel("Default", bsize, bsize, "BOTTOM", anchor, "BOTTOM", 0, 3)
		else
			dotframe[i]:CreatePanel("Default", bsize, bsize, "BOTTOM", dotframe[i-1], "TOP", 0, 2)
		end
		
		dotframe[i]:SetScript("OnUpdate", function()
			if not dotframe[i].textured then
				SetButtonTexture(dotframe[i])
			end
			
			local name,_, icon,_,_, duration, expirationTime,_,_,_,_ = UnitAura("mouseover", v, nil, "PLAYER|HARMFUL")
			-- yea this if statment is just because moonfire = sunfire. UGH
			if v == "Moonfire" then
				local fuckmoonfire
				if select(1, UnitAura("mouseover", "Sunfire", nil, "PLAYER|HARMFUL")) then
					fuckmoonfire = "Sunfire"
				else
					fuckmoonfire = "Moonfire"
				end
				name,_, icon,_,_, duration, expirationTime,_,_,_,_ = UnitAura("mouseover", fuckmoonfire, nil, "PLAYER|HARMFUL")
			end
			if Dottable() then
				if name then
					local start = expirationTime - duration
					dotframe[i].texture:SetTexture(icon)
					-- dotframe[i].cooldown:SetCooldown(start, duration)
					dotframe[i].texture:SetVertexColor(1,1,1)
				else
					dotframe[i].texture:SetTexture(select(3, GetSpellInfo(v)))
					-- dotframe[i].cooldown:SetCooldown(0,0)
					dotframe[i].texture:SetVertexColor(1, .15, .15)
				end
				anchor:SetAlpha(1)
			else
				anchor:SetAlpha(0)
			end
		end)
	end
end

local function OnEvent()
	if UnitClass("player") == "Warlock" then
		if GetPrimaryTalentTree() == 1 then
			dots = {"Corruption", "Unstable Affliction"}
		else
			dots = {"Corruption", "Immolate"}
		end
	elseif UnitClass("player") == "Druid" then
		dots = {"Moonfire", "Insect Swarm"}
	elseif UnitClass("player") == "Priest" then
		dots = {"Corruption", "Immolate"}
	elseif UnitClass("player") == "Mage" then
		dots = {"Corruption", "Immolate"}
	end
	
	CreateButtons()
end

anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
anchor:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
anchor:SetScript("OnEvent", OnEvent)
anchor:SetScript("OnUpdate", SetToMouse)