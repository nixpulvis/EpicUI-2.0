local T, C, L = unpack(Tukui)

local classes = {
	"Warlock",
	"Druid",
	"Priest",
	"Mage",
}
local dots = {}
local xoffset = 70
local bsize = 45

local tempval = false

local enable
for i, k in ipairs(classes) do
	if UnitClass("player") == k and tempval == true then
		enable = true
	end
end

if enable == true then
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
		f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x+xoffset, y)	
	end

	local function SetButtonTexture(f)
		f.texture = f:CreateTexture(nil, "BORDER")
		f.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		f.texture:Point("TOPLEFT", f ,"TOPLEFT", 2, -2)
		f.texture:Point("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -2, 2)
		
		f.cooldown = CreateFrame("Cooldown", "$parentCD", f, "CooldownFrameTemplate")
		f.cooldown:SetAllPoints(f.texture)	
		
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
						dotframe[i].cooldown:SetCooldown(start, duration)
						dotframe[i].texture:SetVertexColor(1,1,1)
					else
						dotframe[i].texture:SetTexture(select(3, GetSpellInfo(v)))
						dotframe[i].cooldown:SetCooldown(0,0)
						dotframe[i].texture:SetVertexColor(1, .15, .15)
					end
					anchor:SetAlpha(1)
				else
					anchor:SetAlpha(0)
				end
			end)
		end
	end
	
	local function Kill()
		for i = 1, 5 do
			if _G["MouseoverDot"..i] then
				_G["MouseoverDot"..i]:Kill()
				_G["MouseoverDot"..i] = nil
				_G["MouseoverDot"..i.."CD"]:Kill()
			end
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
		
		Kill()
		CreateButtons()
	end

	anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
	anchor:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	anchor:SetScript("OnEvent", OnEvent)
	anchor:SetScript("OnUpdate", SetToMouse)
end