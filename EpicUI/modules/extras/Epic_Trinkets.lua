local T, C, L = unpack(Tukui)
local bsize = 35

local trinketbar = CreateFrame("Frame", "TukuiTrinketBar", UIParent, "SecureHandlerStateTemplate")
trinketbar:CreatePanel("Default", (bsize*2)-1, bsize, "CENTER", UIParent, "CENTER", 0, 0)
trinketbar:SetMovable(true)
trinketbar:SetClampedToScreen(true)
local trinketbutton = CreateFrame("Button", "trinketbutton", trinketbar, "SecureActionButtonTemplate")
local trinketbuttondiv = CreateFrame("Frame", nil, trinketbar)
trinketbuttondiv:CreatePanel("Default", 1, bsize, "TOP", trinketbar, "TOP", 0, 0)

-- move frame
local mover = CreateFrame("Frame", "TukuiTrinketBarAnchor", UIParent)
mover:SetAllPoints(TukuiTrinketBar)
mover:SetTemplate("Default")
mover:SetFrameStrata("HIGH")
mover:SetBackdropBorderColor(1,0,0)
mover:SetAlpha(0)
mover.text = T.SetFontString(mover, C.media.uffont, 12)
mover.text:SetPoint("CENTER")
mover.text:SetText("Move Trinket Bar")

local TimeSinceLastUpdate = 0
for i = 1, 2 do
	--button stuffz
	trinketbutton[i] = CreateFrame("Button", "trinketbutton"..i, trinketbar, "SecureActionButtonTemplate")
	trinketbutton[i]:Size(bsize, bsize)
	trinketbutton[i]:Point("TOPLEFT", trinketbar, "TOPLEFT", 0, 0)
	
	if i ~= 1 then
		trinketbutton[i]:SetPoint("TOPLEFT", trinketbutton[i-1], "TOPRIGHT", -1, 0)
	end
	-- texture settup
	trinketbutton[i].texture = trinketbutton[i]:CreateTexture(nil, "BORDER")
	trinketbutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	trinketbutton[i].texture:SetPoint("TOPLEFT", trinketbutton[i] ,"TOPLEFT", 2, -2)
	trinketbutton[i].texture:SetPoint("BOTTOMRIGHT", trinketbutton[i] ,"BOTTOMRIGHT", -2, 2)
	-- cooldown overlay
	trinketbutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", trinketbutton[i], "CooldownFrameTemplate")
	trinketbutton[i].cooldown:SetAllPoints(trinketbutton[i].texture)				
	-- text settup
	trinketbutton[i].value = trinketbutton[i]:CreateFontString(nil, "ARTWORK")
	trinketbutton[i].value:SetFont(C.media.pixelfont, 8, "MONOCHROMEOUTLINE")
	trinketbutton[i].value:SetText("ERROR")
	trinketbutton[i].value:SetTextColor(1, 0, 0)
	trinketbutton[i].value:Point("CENTER", trinketbutton[i], "CENTER")
	-- hoverover stuffz
	trinketbutton[i]:StyleButton()
	-- cooldown stuffz
	local function OnUpdate(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	if(TimeSinceLastUpdate > .25) then
		local var = i + 12
		local trinket1id = GetInventoryItemID("player", 13)
		local trinket2id = GetInventoryItemID("player", 14)
		if i == 1 then
			if trinket1id then
				trinketbutton[i].value:Hide()
				trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket1id)))
				local start, duration, enabled = GetItemCooldown(trinket1id)
				trinketbutton[i].startval = start
				if enabled ~= 0 then
				trinketbutton[i].texture:SetVertexColor(1,1,1)
				trinketbutton[i].cooldown:SetCooldown(start, duration)
				else
				trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
				end	
			else
				trinketbutton[i].value:Show()
			end
		else
			if trinket2id then
				trinketbutton[i].value:Hide()
				trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket2id)))
				local start, duration, enabled = GetItemCooldown(trinket2id)
				trinketbutton[i].startval = start
				if enabled ~= 0 then
				trinketbutton[i].texture:SetVertexColor(1,1,1)
				trinketbutton[i].cooldown:SetCooldown(start, duration)
				else
				trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
				end	
			else
				trinketbutton[i].value:Show()
			end	
		end
		trinketbutton[i]:SetAttribute("type", "item");
		trinketbutton[i]:SetAttribute("item", var)
		
		if trinketbutton[i].startval == 0 then
			trinketbutton[i].cooldown:SetAlpha(0)
		else
			trinketbutton[i].cooldown:SetAlpha(1)
		end
		TimeSinceLastUpdate = 0
	end
	end
	trinketbutton[i]:SetScript("OnUpdate", OnUpdate)
end
trinketbar:Kill()