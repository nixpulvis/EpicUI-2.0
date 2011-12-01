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

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.CreateBorder then mt.CreateBorder = CreateBorder end
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