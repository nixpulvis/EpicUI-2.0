local T, C, L = unpack(Tukui)

 -- header
WatchFrameHeader:SetParent(TukuiWatchFrame)
WatchFrameHeader:SetTemplate()
WatchFrameHeader:FontString("text", C.media.font, 12)
WatchFrameHeader.text:SetText("Tracking")
WatchFrameHeader.text:Point("CENTER", 0, 0)

-- no move moving
TukuiWatchFrame:SetParent(UIParent)
TukuiWatchFrameAnchor:Kill()

local function setup()
	WatchFrameCollapseExpandButton:SetTemplate()
	WatchFrameCollapseExpandButton:Size(20, 20)
	WatchFrameCollapseExpandButton.t:SetText("|cff9a1212Q")
	TukuiWatchFrame:ClearAllPoints()
	TukuiWatchFrame:Point("TOPRIGHT", TukuiMinimap, "BOTTOMLEFT", 5, 4)
	
	-- show and hide the tracking header
	WatchFrameCollapseExpandButton:HookScript("OnClick", function(self) 
		if WatchFrame.collapsed then
			self.t:SetText("|cff319f1bQ")
			WatchFrameHeader:Hide()
		else 
			self.t:SetText("|cff9a1212Q")
			WatchFrameHeader:Show()
		end 
	end)
end

local f = CreateFrame("Frame")
f:Hide()
f.elapsed = 0
f:SetScript("OnUpdate", function(self, elapsed)
	f.elapsed = f.elapsed + elapsed
	if f.elapsed > .6 then
		setup()
		f:Hide()
	end
end)
-- header loves to pop up, lol not anymore motherfucker.
local q = CreateFrame("Frame")
q:Hide()
q.elapsed = 0
q:SetScript("OnUpdate", function(self, elapsed)
	if WatchFrame.collapsed or GetNumQuestWatches() == 0 then 
		WatchFrameHeader:Hide()
	else 
		WatchFrameHeader:Show()
	end 
end)
TukuiWatchFrame:HookScript("OnEvent", function() f:Show() q:Show() end)