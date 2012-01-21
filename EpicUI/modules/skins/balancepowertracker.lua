local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
------------------------------------------------------------------------
	-- Balance Power Panel             
------------------------------------------------------------------------
if IsAddOnLoaded("BalancePowerTracker") then
if (T.myclass == "DRUID") then
	local bpt = BalancePowerTrackerBackgroundFrame
	
	
	-- local bptBG = bpt:CreateTexture(nil, 'BORDER')
	-- bptBG:SetAllPoints()
	-- bptBG:SetTexture(unpack(C["media"].bordercolor))
	
	local eclipseBarfunc = CreateFrame("Frame")
	eclipseBarfunc:RegisterEvent("PLAYER_ENTERING_WORLD")
	eclipseBarfunc:RegisterEvent("UNIT_AURA")
	eclipseBarfunc:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	eclipseBarfunc:RegisterEvent("PLAYER_TALENT_UPDATE")
	eclipseBarfunc:RegisterEvent("UNIT_TARGET")
	eclipseBarfunc:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		BalancePowerTrackerLunarEclipseIconFrame:Kill()
		BalancePowerTrackerSolarEclipseIconFrame:Kill()
		bpt:SetBackdrop(nil)
		
		bpt:CreateBackdrop()
		bpt.backdrop:Point("TOPLEFT", 2, -2)
		bpt.backdrop:Point("BOTTOMRIGHT", -2, 2)
	end
	
	-- local activeTalent = GetPrimaryTalentTree()
    -- local shift = GetShapeshiftForm()
	-- local grace = select(7, UnitAura("player", "Nature's Grace", nil, "HELPFUL"))
    	-- if grace then
			-- bptBG:SetTexture((236/255), (242/255), (69/255))
		-- else
			-- bptBG:SetTexture(unpack(C["media"].bordercolor))
		-- end

		-- if activeTalent == 1 then
		    -- if shift == 1 or shift == 2 or shift == 3 or shift == 4 or shift == 6 then
		        -- bpt:Hide()
			-- else
			    -- bpt:Show()
			-- end
		-- else
		    -- bpt:Hide()
		-- end
	end)

end
end