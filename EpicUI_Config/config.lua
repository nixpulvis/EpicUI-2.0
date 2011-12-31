local C = {}

C.epicui = {
	specialbuff = 80398,							-- Optional buff to watch for in the raidbuffReminder, set to nil for nothing.
}

C.media = {
	font = [[Interface\Addons\EpicUI\media\HelveticaNeueLTCom-Cn.ttf]],
	plusicon = [[Interface\Addons\EpicUI\media\plus_icon.tga]],
	dpsicon = [[Interface\Addons\EpicUI\media\switch_layout_dd.tga]],
	healicon = [[Interface\Addons\EpicUI\media\switch_layout_heal.tga]],
}

C.general = {
	backdropcolor = { .05,.05,.05 },                   -- default backdrop color of panels
	bordercolor = { .15, .15, .15 },                   -- default border color of panels
	highlighted = {.4, .4, .4},						   -- used for hoverover
}

C.unitframes = {
	cblatency = true,                              -- enable castbar latency
	totdebuffs = true,                             -- enable tot debuffs (high reso only)
	unicolor = true,                               -- enable unicolor theme
	healcomm = true,                               -- enable healprediction support.
	bordercolor = { .4,.4,.4 },                     -- unit frames panel border color
	deficitcolor = {(178/225), (34/225), (34/225)},	-- Healthbar deficit color (if unicolor = true) (FIREBRICK > all)

	-- raid layout (if one of them is enabled)
	gridonly = true,                               -- enable grid only mode for all healer mode raid layout.
	showplayerinparty = true,                      -- show my player frame in party
	gridhealthvertical = false,
}

C.loot = {
	autogreed = false,                               -- auto-dez or auto-greed item at max level, auto-greed Frozen orb
}

C.datatext = {
	fps_ms = 4,                                     -- show fps and ms on panels
	system = 5,                                     -- show total memory and others systems infos on panels
	bags = 0,                                       -- show space used in bags on panels
	gold = 6,                                       -- show your current gold on panels
	wowtime = 8,                                    -- show time on panels
	guild = 1,                                      -- show number on guildmate connected on panels
	dur = 2,                                        -- show your equipment durability on panels.
	friends = 3,                                    -- show number of friends connected.
	dps_text = 0,                                   -- show a dps meter on panels
	hps_text = 0,                                   -- show a heal meter on panels
	power = 0,                                      -- show your attackpower/spellpower/healpower/rangedattackpower whatever stat is higher gets displayed
	haste = 0,                                      -- show your haste rating on panels.
	crit = 0,                                       -- show your crit rating on panels.
	avd = 0,                                        -- show your current avoidance against the level of the mob your targeting
	armor = 0,                                      -- show your armor value against the level mob you are currently targeting
	currency = 0,                                   -- show your tracked currency on panels
	hit = 0,                                        -- show hit rating
	mastery = 0,                                    -- show mastery rating
	micromenu = 7,                                  -- add a micro menu thought datatext
	regen = 0,                                      -- show mana regeneration
	talent = 0,                                     -- show talent
	calltoarms = 0,                                 -- show dungeon and call to arms

	battleground = true,                            -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	time24 = false,                                 -- set time to 24h format.
	localtime = true,                               -- set time to local time instead of server time.
	fontsize = 12,                                  -- font size for panels.
}

C.databars = {
	framerate = 2,
	latency = 3,
	memory = 4,
	bags = 0,
	exp_rep = 1,
	durability = 5,
	currency = 0,
	talents = 0,
}

C.chat = {
	background = true,
}

C.nameplate = {
	enable = true,                                  -- enable nice skinned nameplates that fit into tukui
	showhealth = true,				                -- show health text on nameplate
	enhancethreat = true,			                -- threat features based on if your a tank or not
}

TukuiEditedDefaultConfig = C