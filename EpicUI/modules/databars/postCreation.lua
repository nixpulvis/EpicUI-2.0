local T, C, L = unpack(Tukui)

local pWidth, pHeight = databar_settings.width, databar_settings.height
for i = 1, #T.databars do
	if not T.databars[i]:IsShown() then
		T.databars[i]:SetHeight(C.databar_settings.padding)
	end
end