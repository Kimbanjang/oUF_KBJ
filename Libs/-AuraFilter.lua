local name, ns = ...
local playerClass = select(2, UnitClass('player'))
local playerRace = select(2, UnitRace('player'))

-- Values:
-- 1 = by player
-- 2 = by anyone

local OffAuraList = {
	[GetSpellInfo(90355)]  = 2, -- Ancient Hysteria (core hound)
	[GetSpellInfo(2825)]   = 2, -- Bloodlust (shaman)
	[GetSpellInfo(32182)]  = 2, -- Heroism (shaman)
	[GetSpellInfo(80353)]  = 2, -- Time Warp (mage)
	[GetSpellInfo(10060)]  = 2, -- Power Infusion (priest)
}

local DefAuraList = {	
	[GetSpellInfo(1022)]   = 2, -- Hand of Protection
	[GetSpellInfo(102342)] = 2, -- Ironbark
	[GetSpellInfo(33206)]  = 2, -- Pain Suppression
}

-- ADD Racials
if playerRace == "Draenei" then
	DefAuraList[GetSpellInfo(59545)]  = 4 -- Gift of the Naaru (death knight)
	DefAuraList[GetSpellInfo(59543)]  = 4 -- Gift of the Naaru (hunter)
	DefAuraList[GetSpellInfo(59548)]  = 4 -- Gift of the Naaru (mage)
	DefAuraList[GetSpellInfo(121093)] = 4 -- Gift of the Naaru (monk)
	DefAuraList[GetSpellInfo(59542)]  = 4 -- Gift of the Naaru (paladin)
	DefAuraList[GetSpellInfo(59544)]  = 4 -- Gift of the Naaru (priest)
	DefAuraList[GetSpellInfo(59547)]  = 4 -- Gift of the Naaru (shaman)
	DefAuraList[GetSpellInfo(28880)]  = 4 -- Gift of the Naaru (warrior)
elseif playerRace == "Dwarf" then
	DefAuraList[GetSpellInfo(20594)]  = 4 -- Stoneform
elseif playerRace == "NightElf" then
	DefAuraList[GetSpellInfo(58984)]  = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	OffAuraList[GetSpellInfo(20572)]  = 4 -- Blood Fury (attack power)
	OffAuraList[GetSpellInfo(33702)]  = 4 -- Blood Fury (spell power)
	OffAuraList[GetSpellInfo(33697)]  = 4 -- Blood Fury (attack power and spell damage)
elseif playerRace == "Troll" then
	OffAuraList[GetSpellInfo(26297)]  = 4 -- Berserking
end

-- ADD Class
if playerClass == "DEATHKNIGHT" then

	OffAuraList[GetSpellInfo(48263)]  = 4 
	OffAuraList[GetSpellInfo(48266)]  = 4 
	OffAuraList[GetSpellInfo(158300)] = 4 
	OffAuraList[GetSpellInfo(57330)]  = 4 

	-- Self Buffs
	DefAuraList[GetSpellInfo(48707)]  = 1 -- Anti-Magic Shell
	DefAuraList[GetSpellInfo(51052)]  = 1 -- Anti-Magic Zone
	DefAuraList[GetSpellInfo(49222)]  = 2 -- Bone Shield
	DefAuraList[GetSpellInfo(119975)] = 1 -- Conversion
	DefAuraList[GetSpellInfo(101568)] = 1 -- Dark Succor <= glyph
	DefAuraList[GetSpellInfo(96268)]  = 1 -- Death's Advance
	DefAuraList[GetSpellInfo(59052)]  = 1 -- Freezing Fog <= Rime
	DefAuraList[GetSpellInfo(48792)]  = 1 -- Icebound Fortitude
	DefAuraList[GetSpellInfo(51124)]  = 1 -- Killing Machine
	DefAuraList[GetSpellInfo(49039)]  = 1 -- Lichborne
	DefAuraList[GetSpellInfo(51271)]  = 1 -- Pillar of Frost
	DefAuraList[GetSpellInfo(46584)]  = 1 -- Raise Dead
	DefAuraList[GetSpellInfo(108200)] = 1 -- Remorseless Winter
	DefAuraList[GetSpellInfo(51460)]  = 1 -- Runic Corruption
	DefAuraList[GetSpellInfo(50421)]  = 1 -- Scent of Blood
	DefAuraList[GetSpellInfo(116888)] = 1 -- Shroud of Purgatory
	DefAuraList[GetSpellInfo(81340)]  = 1 -- Sudden Doom
	DefAuraList[GetSpellInfo(51271)]  = 1	-- Unbreakable Armor
	DefAuraList[GetSpellInfo(115989)] = 1 -- Unholy Blight
	DefAuraList[GetSpellInfo(53365)]  = 1 -- Unholy Strength <= Rune of the Fallen Crusader
	DefAuraList[GetSpellInfo(55233)]  = 1 -- Vampiric Blood
end

do
	local OffensiveCustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
		if(caster == 'player' and OffAuraList[name]) then
			return true
		end
	end

	local DefensiveCustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
		if(caster == 'player' and DefAuraList[name]) then
			return true
		end
	end

	ns.OffensiveCustomFilter = OffensiveCustomFilter
	ns.DefensiveCustomFilter = DefensiveCustomFilter
end
