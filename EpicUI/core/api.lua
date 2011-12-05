local T, C, L = unpack(Tukui)

--API Functions
local function CreateBorder(f, i, o)
	if i then
		if f.iborder then return end
		local border = CreateFrame("Frame", f:GetName() and f:GetName() .. "InnerBorder" or nil, f)
		border:Point("TOPLEFT", T.mult, -T.mult)
		border:Point("BOTTOMRIGHT", -T.mult, T.mult)
		border:SetBackdrop({
			edgeFile = C["media"].blank, 
			edgeSize = mult, 
			insets = { left = T.mult, right = T.mult, top = T.mult, bottom = T.mult }
		})
		border:SetBackdropBorderColor(unpack(C["media"].backdropcolor))
		f.iborder = border
	end

	if o then
		if f.oborder then return end
		local border = CreateFrame("Frame", f:GetName() and f:GetName() .. "OuterBorder" or nil, f)
		border:Point("TOPLEFT", -T.mult, T.mult)
		border:Point("BOTTOMRIGHT", T.mult, -T.mult)
		border:SetFrameLevel(f:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = C["media"].blank, 
			edgeSize = T.mult, 
			insets = { left = T.mult, right = T.mult, top = T.mult, bottom = T.mult }
		})
		border:SetBackdropBorderColor(unpack(C["media"].backdropcolor))
		f.oborder = border
	end
end

local function SetVerticalText(self, r, g, b, shadow) -- Must call this function after every update to self:SetText()
	if self.VertTexted then
		for key in pairs(self.words) do
			self.words[key].str:Kill()
		end
		
		wipe(self.words)
	end
		
	local string = self:GetText()
	local parent = self:GetParent()
	local fontName, fontHeight, fontFlags = self:GetFont()
	local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	self.words = {}

	if not type(string) == "string" then return end
	
	for word in string.gmatch(string, "%a+") do
		local wordCenter = ((strlen(word)-1)*fontHeight)/2
		
		for i = 1, strlen(word) do
			self.words[i] = CreateFrame("Frame") -- Need a reference object

			self.words[i].letter = strsub(word, i, i)

			self.words[i].str = parent:CreateFontString(nil, "OVERLAY")
			self.words[i].str:SetFont(fontName, fontHeight, fontFlags)
			self.words[i].str:SetText(self.words[i].letter)
			
			if i == 1 then
				if point == "CENTER" then
					self.words[i].str:Point(point, relativeTo, relativePoint, xOfs, yOfs+wordCenter)
				else
					self.words[i].str:Point(point, relativeTo, relativePoint, xOfs, yOfs)
				end
			else
				self.words[i].str:Point("TOP", self.words[i-1].str, "TOP", 0, -fontHeight)
			end
			
			if shadow then
				self.words[i].str:SetShadowColor(0,0,0)
				self.words[i].str:SetShadowOffset(1.25, -1.25)
			end
			
			if r or g or b then
				self.words[i].str:SetTextColor(r, g, b)
			end
		end
	end
	
	self:Hide() -- Hide the original string :)
	self.VertTexted = true
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.CreateBorder then mt.CreateBorder = CreateBorder end
	if not object.SetVerticalText then mt.SetVerticalText = SetVerticalText end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end