local T, C, L = unpack(Tukui)
----------------------
-- EPICUI FUNCTIONS --
----------------------

T.KillTableofFrames = function(t)
	for i, v in pairs(t) do
		v:Kill()
		v = nil
	end
end

-- Databar fuctions
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

----------------------------------
-- Overwriting Tukui Functions --
----------------------------------
--Killing functions I don't want
T.PostNamePosition = T.dummy

 T.SkinCloseButton = function(f, point)
	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
	
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture("")
	f.t = f:CreateFontString(nil, "OVERLAY")
	f.t:SetFont(C.media.pixelfont, 12, "MONOCHROME")
	f.t:SetPoint("CENTER", 0, 0)
	f.t:SetText("X")
end

-- for UFs mostly
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