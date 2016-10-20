local name, ns = ...
local cfg = CreateFrame('Frame')
local _, class = UnitClass('player')

-- Media ------------------------------------------------------------------------------------------
-- Texture
local mediaPath = 'Interface\\AddOns\\oUF_KBJ\\Media\\'
cfg.texture = mediaPath..'texture'
cfg.symbol = mediaPath..'symbol.ttf'
cfg.glow = mediaPath..'glowTex'

-- Font
cfg.font, cfg.fontsize, cfg.shadowoffsetX, cfg.shadowoffsetY, cfg.fontflag = mediaPath..'fontThick.ttf', 10, 0, 0,  'THINOUTLINE' -- '' for none THINOUTLINE Outlinemonochrome
cfg.krfont, cfg.krfontsize, cfg.krshadowoffsetX, cfg.krshadowoffsetY, cfg.krfontflag = STANDARD_TEXT_FONT, 10, 0, 0,  'THINOUTLINE' -- '' for none THINOUTLINE Outlinemonochrome

-- Unit Frames ------------------------------------------------------------------------------------
-- Enable
cfg.uf = {
	party = true,			-- Party
	party_target = true,	-- Party target
	raid = true,			-- Raid
	boss = true,			-- Boss
	arena = true,			-- Arena
	tank = true,			-- Maintank
	tank_target = true,		-- Maintank target
}

-- Unit Frames Size
cfg.player = { 
    width = 28,
    health = 41,
    power = 2, -- height = health + power + 1(space)
}

cfg.target = { 
    width = 73,
    health = 41,
    power = 2, -- height = health + power + 1(space)
} -- target, party, arena

cfg.focus = { 
    width = 73,
    health = 18,
    power = 2, -- height = health + power + 1(space)
} -- focus, boss, tank

cfg.raid = { 
    width = 44, 
    health = 41,
    power = 2, -- height = health + power + 1(space)
} -- raid

cfg.ttarget = { 
    width = 73 ,
    height = 13,
} -- targettarget, focustarget, arenatarget, partytarget, maintanktarget

-- Unit Frames Positions
cfg.unit_positions = { 				
          Player = { a = UIParent,		  x=  110, y=   21},  
          Target = { a = 'oUF_KBJPlayer', x=  260, y=  350},  
    Targettarget = { a = 'oUF_KBJTarget', x=    0, y=  -64},  
           Focus = { a = 'oUF_KBJPlayer', x= -105, y=  320},  
     Focustarget = { a = 'oUF_KBJFocus',  x=   95, y=    0},  
             Pet = { a = 'oUF_KBJPlayer', x=	0, y=  -64},  
            Boss = { a = 'oUF_KBJTarget', x=   82, y=  350},  
            Tank = { a = UIParent,		  x= -300, y=   21},  
            Raid = { a = UIParent,		  x=  15, y=  -100},   
	       Party = { a = UIParent,		  x= -133, y=  -53},
           Arena = { a = 'oUF_KBJTarget', x=  246, y=  -53},			  
}

-----------------------------
-- Unit Frames Options
-----------------------------
cfg.options = {
	healcomm = false,
	smooth = true,
	disableRaidFrameManager = true,	-- disable default compact Raid Manager 
	ResurrectIcon = true,
	--TotemBar = false,
	--Maelstrom = true,
	--MushroomBar = true,
}

-----------------------------
-- Auras 
-----------------------------
cfg.aura = {
	-- player
	player_debuffs = true,
	player_debuffs_num = 18,
	-- target
	target_debuffs = true,
	target_debuffs_num = 18,
	target_buffs = true,
	target_buffs_num = 8,		
	-- focus
	focus_debuffs = true,
	focus_debuffs_num = 12,
	focus_buffs = false,
	focus_buffs_num = 8,
	-- boss
	boss_buffs = true,
	boss_buffs_num = 4,
	boss_debuffs = true,
	boss_debuffs_num = 4,
	-- target of target
	targettarget_debuffs = true,
	targettarget_debuffs_num = 4,
	-- party
	party_buffs = true,
	party_buffs_num = 4,
	
	onlyShowPlayer = false,         -- only show player debuffs on target
	disableCooldown = true,         -- hide omniCC
	font = mediaPath..'pixel.ttf',
	fontsize = 8,
	fontflag = 'Outlinemonochrome',
}

-----------------------------
-- Plugins 
-----------------------------

--ThreatBar
cfg.treat = {
	enable = true,
	text = false,
	pos = {'CENTER', UIParent, 0, 39},
	width = 40,
	height = 4,
}

--GCD
cfg.gcd = {
	enable = true,
	pos = {'CENTER', UIParent, 0, 51},
	width = 229,
	height = 7,
}

--RaidDebuffs
cfg.RaidDebuffs = {
	enable = true,
	pos = {'CENTER'},
	size = 20,
	ShowDispelableDebuff = true,
	FilterDispellableDebuff = true,
	MatchBySpellName = false,
}

--Threat/DebuffHighlight
cfg.dh = {
	player = true,
	target = true,
	focus = true,
	pet = true,
	partytaget = false,
	party = true,
	arena = true,
	raid = true,
	targettarget = false,
}

--AuraWatch
cfg.aw = {
	enable = true,
	onlyShowPresent = true,
	anyUnit = true,
}

--AuraWatch Spells
cfg.spellIDs = {
	  DRUID = {
	          {33763, {0.2, 0.8, 0.2}},			    -- Lifebloom
	          {8936, {0.8, 0.4, 0}, 'TOPLEFT'},		-- Regrowth
	          {102342, {0.38, 0.22, 0.1}},		    -- Ironbark
	          {48438, {0.4, 0.8, 0.2}, 'BOTTOMLEFT'},	-- Wild Growth
	          {774, {0.8, 0.4, 0.8},'TOPRIGHT'},		-- Rejuvenation
	          },
	   MONK = {
	          {119611, {0.2, 0.7, 0.7}},			    -- Renewing Mist
	          {132120, {0.4, 0.8, 0.2}},			    -- Enveloping Mist
	          {124081, {0.7, 0.4, 0}},			    -- Zen Sphere
	          {116849, {0.81, 0.85, 0.1}},		    -- Life Cocoon
	          },
	PALADIN = {
	          {20925, {0.9, 0.9, 0.1}},	            -- Sacred Shield
	          {6940, {0.89, 0.1, 0.1}, 'BOTTOMLEFT'}, -- Hand of Sacrifice
	          {114039, {0.4, 0.6, 0.8}, 'BOTTOMLEFT'},-- Hand of Purity
	          {1022, {0.2, 0.2, 1}, 'BOTTOMLEFT'},	-- Hand of Protection
	          {1038, {0.93, 0.75, 0}, 'BOTTOMLEFT'},  -- Hand of Salvation
	          {1044, {0.89, 0.45, 0}, 'BOTTOMLEFT'},  -- Hand of Freedom
	          {114163, {0.9, 0.6, 0.4}, 'RIGHT'},	    -- Eternal Flame
	          {53563, {0.7, 0.3, 0.7}, 'TOPRIGHT'},   -- Beacon of Light
	          },
	 PRIEST = {
	          {41635, {0.2, 0.7, 0.2}},			    -- Prayer of Mending
	          {33206, {0.89, 0.1, 0.1}},			    -- Pain Suppress
	          {47788, {0.86, 0.52, 0}},			    -- Guardian Spirit
	          {6788, {1, 0, 0}, 'BOTTOMLEFT'},	    -- Weakened Soul
	          {17, {0.81, 0.85, 0.1}, 'TOPLEFT'},	    -- Power Word: Shield
	          {139, {0.4, 0.7, 0.2}, 'TOPRIGHT'},     -- Renew
	          },
	 SHAMAN = {
	          {974, {0.2, 0.7, 0.2}},				    -- Earth Shield
	          {61295, {0.7, 0.3, 0.7}, 'TOPRIGHT'},   -- Riptide
	          },
	 HUNTER = {
	          {35079, {0.2, 0.2, 1}},				    -- Misdirection
	          },
	   MAGE = {
	          {111264, {0.2, 0.2, 1}},			    -- Ice Ward
	          },
	  ROGUE = {
	          {57933, {0.89, 0.1, 0.1}},			    -- Tricks of the Trade
	          },
	WARLOCK = {
	          {20707, {0.7, 0.32, 0.75}},			    -- Soulstone
	          },
	WARRIOR = {
	          {114030, {0.2, 0.2, 1}},			    -- Vigilance
	          {3411, {0.89, 0.1, 0.1}, 'TOPRIGHT'},   -- Intervene
	          },
 }
 
-----------------------------
-- Castbars 
-----------------------------

-- Player
cfg.player_cb = {
	enable = true,
	pos = {'CENTER', UIParent, 0, 36},
	width = 100,
	height = 14,
}

-- Target
cfg.target_cb = {
	enable = true,
	pos = {'CENTER', UIParent, 0, 240},
	width = 180,
	height = 22,
}

-- Focus
cfg.focus_cb = {
	enable = true,
	pos = {'CENTER', UIParent, 0, 280},
	width = 180,
	height = 18,
}

-- Boss
cfg.boss_cb = {
	enable = false,
	pos = {'BOTTOMRIGHT', 0, -16},
	width = 150,
	height = 15,
}

-- Arena
cfg.arena_cb = {
	enable = true,
	pos = {'TOPRIGHT', -80, 0},
	height = 9,
	width = 130,
}

ns.cfg = cfg