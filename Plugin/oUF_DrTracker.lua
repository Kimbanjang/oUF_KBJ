local framelist, self, aura, classCat
local select = select
local UnitGUID, GetSpellInfo, GetTime, pairs, print = UnitGUID, GetSpellInfo, GetTime, pairs, print
local class = select(2, UnitClass('player'))

-- DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets.
-- If you are experiencing constant problems with DR reset accuracy, you can change this value
local DRtime = 18


	framelist = {
		--[FRAME NAME]	= {UNITID,SIZE,ANCHOR,ANCHORFRAME,X,Y,"ANCHORNEXT","ANCHORPREVIOUS",nextx,nexty},
		["oUF_Arena1"]	= {"arena1",29,"TOPRIGHT","BOTTOMLEFT",-2,-2,"RIGHT","LEFT",-2,0},
		["oUF_Arena2"]	= {"arena2",29,"TOPRIGHT","BOTTOMLEFT",-2,-2,"RIGHT","LEFT",-2,0},
		["oUF_Arena3"]	= {"arena3",29,"TOPRIGHT","BOTTOMLEFT",-2,-2,"RIGHT","LEFT",-2,0},
		["oUF_Arena4"]	= {"arena4",29,"TOPRIGHT","BOTTOMLEFT",-2,-2,"RIGHT","LEFT",-2,0},
		["oUF_Arena5"]	= {"arena5",29,"TOPRIGHT","BOTTOMLEFT",-2,-2,"RIGHT","LEFT",-2,0},
	}

-- This is the config section for what DR categories to show for each class
if class == 'DEATHKNIGHT' then
	classCat = {
		["silence"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'DRUID' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = true,
		["disorient"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'HUNTER' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = false,
		["disorient"] = false,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'MAGE' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'MONK' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = false,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'PALADIN' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = false,
		["disorient"] = true,
		["ctrlstun"] = true,
		}
elseif class == 'PRIEST' then
	classCat = {
		["silence"] = true,
		["disorient"] = true,
		["ctrlroot"] = true,
		["incapacitate"] = true,
		}
elseif class == 'ROGUE' then
	classCat = {
		["incapacitate"] = true,
		["silence"] = true,
		["disorient"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = false,
		}
elseif class == 'SHAMAN' then
	classCat = {
	    ["silence"] = false,
		["incapacitate"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
elseif class == 'WARLOCK' then
	classCat = {
		["silence"] = false,
		["disorient"] = true,
		["ctrlstun"] = true,
		["incapacitate"] = true,
		}
elseif class == 'WARRIOR' then
	classCat = {
	    ["silence"] = false,
		["disorient"] = true,
		["ctrlstun"] = true,
		["ctrlroot"] = true,
		}
end

local function GetDrIcons() 
	if class == 'DEATHKNIGHT' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(108194)), --Aspyxiate
		["ctrlroot"] = select(3,GetSpellInfo(96294)), -- Chains of Ice (Chilblains Root)
		["silence"] = select(3,GetSpellInfo(47476)), -- Strangulate
		}
	elseif class == 'DRUID' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(5211)), -- Mighty Bash
		["disorient"] = select(3,GetSpellInfo(113056)), -- Intimidating Roar
		["ctrlroot"] = select(3,GetSpellInfo(339)), -- Entangling Roots
		["silence"] = select(3,GetSpellInfo(78675)), -- Solar Beam
		}
	elseif class == 'HUNTER' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(24394)), -- Intimidation
		["incapacitate"] = select(3,GetSpellInfo(91644)), -- Freezing Trap
		["ctrlroot"] = select(3,GetSpellInfo(128405)), -- Narrow Escape
		}
	elseif class == 'MAGE' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(44572)),
		["incapacitate"] = select(3,GetSpellInfo(118)),
		["ctrlroot"] = select(3,GetSpellInfo(122)),
		}
	elseif class == 'MONK' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(119381)), -- Leg Sweep 
		["incapacitate"] = select(3,GetSpellInfo(115078)), -- Paralysis
		["ctrlroot"] = select(3,GetSpellInfo(116706)), -- Disable
		}
	elseif class == 'PALADIN' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(853)), -- Hammer of Justice
		["incapacitate"] = select(3,GetSpellInfo(20066)), -- Repentance
		["disorient"] = select(3,GetSpellInfo(10326)), -- Turn Evil
		["silence"] = select(3,GetSpellInfo(31935)), -- Avenger's Shield
		}
	elseif class == 'PRIEST' then
		return {
		["incapacitate"] = select(3,GetSpellInfo(9484)), -- Shackle Undead
		["incapacitate"] = select(3,GetSpellInfo(64044)), -- Psyhcic Horror
		["ctrlroot"] = select(3,GetSpellInfo(114404)), -- Void Tendrils
		["silence"] = select(3,GetSpellInfo(15487)), -- Silence
		}
	elseif class == 'ROGUE' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(408)),-- Kidney Shot
		["incapacitate"] = select(3,GetSpellInfo(6770)), -- Sap
		["disorient"] = select(3,GetSpellInfo(2094)), -- Blind
		["silence"] = select(3,GetSpellInfo(1330)), -- Garrote
		}
	elseif class == 'SHAMAN' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(118905)), -- Static Charge (Capacitor Totem)
		["incapacitate"] = select(3,GetSpellInfo(51514)), -- Hex
		["ctrlroot"] = select(3,GetSpellInfo(64695)), -- Earthgrab
		}
	elseif class == 'WARLOCK' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(89766)), -- Axe Toss (Felguard)
		["disorient"] = select(3,GetSpellInfo(5782)), -- Fear
		["incapacitate"] = select(3,GetSpellInfo(6789)), -- Mortal Coil
		}
	elseif class == 'WARRIOR' then
		return {
		["ctrlstun"] = select(3,GetSpellInfo(132168)), -- Shockwave
		["disorient"] = select(3,GetSpellInfo(5246)), -- Intimidating Shout
		["ctrlroot"] = select(3,GetSpellInfo(107566)), -- Staggering Shout 
		}
	end
		--["test"] = select(3,GetSpellInfo(80353)),
end

local function GetSpellDR() 
	return {
		--[[ INCAPACITATES ]]--
		[    99] = {"incapacitate"},	-- Incapacitating Roar (talent)
		[  3355] = {"incapacitate"},	-- Freezing Trap
		[ 19386] = {"incapacitate"},	-- Wyvern Sting
		[ 31661] = {"incapacitate"},    -- Dragon's Breath
		[   118] = {"incapacitate"},	-- Polymorph
		[ 28272] = {"incapacitate"},	-- Polymorph (pig)
		[ 28271] = {"incapacitate"},	-- Polymorph (turtle)
		[ 61305] = {"incapacitate"},	-- Polymorph (black cat)
		[ 61025] = {"incapacitate"},	-- Polymorph (serpent) -- FIXME: gone ?
		[ 61721] = {"incapacitate"},	-- Polymorph (rabbit)
		[ 61780] = {"incapacitate"},	-- Polymorph (turkey)
		[ 82691] = {"incapacitate"},	-- Ring of Frost
		[157997] = {"incapacitate"},    -- Ice Nova [Talent]
		[123394] = {"incapacitate"},    -- Glyph of Breath of Fire
		[115078] = {"incapacitate"},	-- Paralysis
		[116844] = {"incapacitate"},    -- Ring of Peace {Talent}
		[ 20066] = {"incapacitate"},	-- Repentance
		[   605] = {"incapacitate"},	-- Dominate Mind
		[ 88625] = {"incapacitate"},    -- Holy Word: Chastise
		[  9484] = {"incapacitate"},	-- Shackle Undead
		[  1776] = {"incapacitate"},	-- Gouge
		[  6770] = {"incapacitate"},	-- Sap
		[ 51514] = {"incapacitate"},	-- Hex
		[   710] = {"incapacitate"},    -- Banish
		[ 64044] = {"incapacitate"},	-- Psychic Horror
		[  6789] = {"incapacitate"},	-- Mortal Coil
		[107079] = {"incapacitate"},	-- Quaking Palm

		--[[ SILENCES ]]--
		[ 47476] = {"silence"},		-- Strangulate
		[114237] = {"silence"},     -- Glyph of Fae Silence
		[ 78675] = {"silence"},		-- Solar Beam -- FIXME: check id
		[ 81261] = {"silence"},		-- Solar Beam -- Definitely correct
		[102051] = {"silence"},		-- Frostjaw (talent)
		[ 31935] = {"silence"},		-- Avenger's Shield
		[ 15487] = {"silence"},		-- Silence
		[  1330] = {"silence"},		-- Garrote
		[ 25046] = {"silence"},		-- Arcane Torrent (Energy version)
		[ 28730] = {"silence"},		-- Arcane Torrent (Mana version)
		[ 50613] = {"silence"},		-- Arcane Torrent (Runic power version)
		[ 69179] = {"silence"},		-- Arcane Torrent (Rage version)
		[ 80483] = {"silence"},		-- Arcane Torrent (Focus version)

		--[[ DISORIENTS ]]--
		[ 33786] = {"disorient"},		-- Cyclone
		[105421] = {"disorient"},		-- Blinding Light
		[ 10326] = {"disorient"},		-- Turn Evil
		[  8122] = {"disorient"},		-- Psychic Scream
		[  2094] = {"disorient"},		-- Blind
		[  5782] = {"disorient"},		-- Fear
		[  5484] = {"disorient"},		-- Howl of Terror
		[  6358] = {"disorient"},		-- Seduction (Succubus)
		[115268] = {"disorient"},		-- Mesmerize (Shivarra) -- FIXME: verify this is the correct category
		[  5246] = {"disorient"},		-- Intimidating Shout (main target)
		[ 20511] = {"disorient"},		-- Intimidating Shout (secondary targets)

		--[[ CONTROL STUNS ]]--
		[108194] = {"ctrlstun"},	-- Asphyxiate (talent)
		[ 91800] = {"ctrlstun"},	-- Gnaw (Ghoul)
		[ 91797] = {"ctrlstun"},	-- Monstrous Blow (Dark Transformation Ghoul)
		[115001] = {"ctrlstun"},	-- Remorseless Winter (talent)
		[ 22570] = {"ctrlstun"},	-- Maim
		[  5211] = {"ctrlstun"},	-- Mighty Bash (talent)
		[  1822] = {"ctrlstun"},    -- Feral Druids new Pounce
		[ 24394] = {"ctrlstun"},	-- Intimidation
		[117526] = {"ctrlstun"},	-- Binding Shot (talent)
		[ 44572] = {"ctrlstun"},	-- Deep Freeze
		[119392] = {"ctrlstun"},	-- Charging Ox Wave (talent)
		[119381] = {"ctrlstun"},	-- Leg Sweep (talent)
		[120086] = {"ctrlstun"},	-- Fists of Fury (Windwalker)
		[   853] = {"ctrlstun"},	-- Hammer of Justice
		[119072] = {"ctrlstun"},	-- Holy Wrath (Protection)
		[105593] = {"ctrlstun"},	-- Fist of Justice (talent)
		[  1833] = {"ctrlstun"},	-- Cheap Shot
		[   408] = {"ctrlstun"},	-- Kidney Shot
		[118345] = {"ctrlstun"},    -- Pulverize (Primal Earth Elemental)
		[118905] = {"ctrlstun"},	-- Static Charge (Capacitor Totem)
		[ 30283] = {"ctrlstun"},	-- Shadowfury
		[ 89766] = {"ctrlstun"},	-- Axe Toss (Felguard)
		[ 22703] = {"ctrlstun"},    -- Infernal Awakening (Infernal)
		[132168] = {"ctrlstun"},	-- Shockwave
		[107570] = {"ctrlstun"},    -- Storm Bolt
		[103828] = {"ctrlstun"},	-- Warbringer (talent)
		[ 20549] = {"ctrlstun"},	-- War Stomp

		--[[ ROOTS ]]--
		[ 96294] = {"ctrlroot"},	-- Chains of Ice (Chilblains Root)
		[   339] = {"ctrlroot"},	-- Entangling Roots
		[102359] = {"ctrlroot"},	-- Mass Entanglement (talent)
		[ 61685] = {"ctrlroot"},    -- Hunter's pet Charge
		[128405] = {"ctrlroot"},	-- Narrow Escape (talent)
		[ 19387] = {"ctrlroot"},    -- Entrapment
		[   122] = {"ctrlroot"},	-- Frost Nova
		[ 33395] = {"ctrlroot"},	-- Freeze (Water Elemental)
		[111264] = {"ctrlroot"},    -- Ice Ward [Talent]
		[116706] = {"ctrlroot"},	-- Disable
		[ 87195] = {"ctrlroot"},    -- Glyph of Mind Blast
		[114404] = {"ctrlroot"},	-- Void Tendrils
		[ 64695] = {"ctrlroot"},	-- Earthgrab
		[ 63374] = {"ctrlroot"},    -- Frozen Power

		[  1459] = {"test"},		-- Testing purpose (Intel Mage)
		[   130] = {"test","disorient"},	-- Testing purpose (Slow Fall)
	}
end

function UpdateDRTracker(self)
	local time = self.start + DRtime - GetTime()

	if time < 0 then
		local frame = self:GetParent()
		frame.actives[self.cat] = nil
		self:SetScript("OnUpdate", nil)
		DisplayDrActives(frame)
	end
end

function DisplayDrActives(self)
--	print("mem DrTracker = "..GetAddOnMemoryUsage("Tukui_DrTracker"))
	if not self.actives then return end
	if not self.auras then self.auras = {} end
	local index
	local previous = nil
	index = 1
	
	for _, _ in pairs(self.actives) do
		local aura = self.auras[index]
		if not aura then
			aura = CreateFrame("Frame", "IldyUI"..self.target.."DrFrame"..index, self)
			aura:Width(self.size) -- default value
			aura:Height(self.size) -- default value
			aura:SetScale(1)
			aura:SetTemplate("Default")
			if index == 1 and IsAddOnLoaded("ElvUI") then
				aura:Point("BOTTOMRIGHT", self.mover, "BOTTOMRIGHT", 0, 0)
			elseif index == 1 then
				aura:Point(self.anchor, self:GetParent().Health, self.anchorframe, self.x, self.y)
			else
				aura:Point(self.nextanchor, previous, self.nextanchorframe, self.nextx, self.nexty)
			end
			aura.icon = aura:CreateTexture("$parenticon", "ARTWORK")
			aura.icon:Point("TOPLEFT", 2, -2)
			aura.icon:Point("BOTTOMRIGHT", -2, 2)
			aura.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			aura.cooldown = CreateFrame("Cooldown", "$parentCD", aura, "CooldownFrameTemplate")
			aura.cooldown:SetAllPoints(aura.icon)
			aura.cooldown:SetReverse()
			if IsAddOnLoaded("ElvUI") then
				ElvUI[1]:RegisterCooldown(aura.cooldown)
			end
			aura.cat = "cat"
			aura.start = 0
			
			-- insert aura
			self.auras[index] = aura
		end
		-- save previous
		previous = aura
		-- next
		index = index + 1
	end

	index = 1
	for cat, value in pairs(self.actives) do
		aura = self.auras[index]
		aura.icon:SetTexture(value.icon)
		if(value.dr == 1) then
			aura:SetBackdropBorderColor(1,1,0,1)
		elseif(value.dr == 2) then
			aura:SetBackdropBorderColor(1,.5,0,1)
		else
			aura:SetBackdropBorderColor(1,0,0,1)
		end
		CooldownFrame_SetTimer(aura.cooldown, value.start, DRtime, 1)
		aura.start = value.start
		aura.cat = cat
		aura:SetScript("OnUpdate", UpdateDRTracker)
		aura.cooldown:Show()

		aura:Show()
		index = index + 1
	end
	
	-- Hide remaining
	for i = index, #self.auras, 1 do
		local aura = self.auras[i]
		aura:SetScript("OnUpdate", nil)
		aura:Hide()
	end
end

local spell = GetSpellDR()

local icon = GetDrIcons()

local eventRegistered = {
		["SPELL_AURA_APPLIED"] = true,
		["SPELL_AURA_REFRESH"] = true,
		["SPELL_AURA_REMOVED"] = true
		}

local function CombatLogCheck(self, ...)																-- Combat event handler
	local _, _, eventType, _, _, _, _, _, destGUID, _, _, _, spellID, spellName, _, auraType, _ = ...

	if( not eventRegistered[eventType] ) then
		return
	end

	if(destGUID ~= UnitGUID(self.target)) then
		return
	end

	-- Enemy gained a debuff
	local needupdate = false
	if( eventType == "SPELL_AURA_APPLIED" ) then
		if( auraType == "DEBUFF" and spell[spellID] ) then
		-- if( auraType == "BUFF" and spell[spellID]) then
			if not self.actives then self.actives = {} end
			for _,cat in pairs(spell[spellID]) do
				if classCat[cat] then
					if self.actives[cat] then
						if(self.actives[cat].start + DRtime < GetTime()) then
							self.actives[cat].start = GetTime()
							self.actives[cat].dr = 1
							self.actives[cat].icon = icon[cat]
						else
							self.actives[cat].start = GetTime()
							self.actives[cat].dr = 2*self.actives[cat].dr
							self.actives[cat].icon = icon[cat]
						end
					else
						self.actives[cat] = {}
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = 1
						self.actives[cat].icon = icon[cat]
					end
				end
			end
			needupdate = true
		end

	-- Enemy had a debuff refreshed before it faded, so fade + gain it quickly
	elseif( eventType == "SPELL_AURA_REFRESH" ) then
		if( auraType == "DEBUFF" and spell[spellID] ) then
		-- if( auraType == "BUFF" and spell[spellID]) then
			if not self.actives then self.actives = {} end
			for _,cat in pairs(spell[spellID]) do
				if classCat[cat] then
					if(not self.actives[cat]) then
						self.actives[cat] = {}
						self.actives[cat].dr = 1
					end
					self.actives[cat].start = GetTime()
					self.actives[cat].dr = 2*self.actives[cat].dr
					self.actives[cat].icon = icon[cat]
				end
			end
			needupdate = true
		end

	-- Buff or debuff faded from an enemy
	elseif( eventType == "SPELL_AURA_REMOVED" ) then
		if( auraType == "DEBUFF" and spell[spellID] ) then
		-- if( auraType == "BUFF" and spell[spellID]) then
			if not self.actives then self.actives = {} end
			for _,cat in pairs(spell[spellID]) do
				if classCat[cat] then
					if self.actives[cat] then
						if(self.actives[cat].start + DRtime < GetTime()) then
							self.actives[cat].start = GetTime()
							self.actives[cat].dr = 1
							self.actives[cat].icon = icon[cat]
						else
							self.actives[cat].start = GetTime()
							self.actives[cat].dr = self.actives[cat].dr
							self.actives[cat].icon = icon[cat]
						end
					else
						self.actives[cat] = {}
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = 1
						self.actives[cat].icon = icon[cat]
					end
				end
			end
			needupdate = true
		end
	end
	if (needupdate) then DisplayDrActives(self) end
end

--Drtracker Frame
for frame, target in pairs(framelist) do
	self = _G[frame]
	local DrTracker = CreateFrame("Frame", nil, self)
	DrTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	DrTracker:SetScript("OnEvent",CombatLogCheck)
	DrTracker.target = target[1]
	DrTracker.size = target[2]
	DrTracker.anchor = target[3]
	DrTracker.anchorframe = target[4]
	DrTracker.x = target[5]
	DrTracker.y = target[6]
	DrTracker.nextanchor = target[7]
	DrTracker.nextanchorframe = target[8]
	DrTracker.nextx = target[9]
	DrTracker.nexty = target[10]
	if IsAddOnLoaded("ElvUI") then
		local E, L, V, P, G = unpack(ElvUI)
		DrTracker:SetSize(target[2]*3+4, target[2]+2)
		DrTracker:SetPoint(target[3], self, target[4], target[5], target[6])
		E:CreateMover(DrTracker, self:GetName().."DRMover", self:GetName().."DR", nil, nil, nil, 'ALL,ARENA')
	end
	self.DrTracker = DrTracker
end

local function tdr()
	-- don't allow moving while in combat
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	local testlist = {"disorient","incapacitate","ctrlroot"}
	
	for frame, target in pairs(framelist) do
		self = _G[frame].DrTracker
		if not self.actives then self.actives = {} end
		local dr = 1
		for _,cat in pairs(testlist) do
			if(not self.actives[cat]) then self.actives[cat] = {} end
			self.actives[cat].dr = dr
			self.actives[cat].start = GetTime()
			self.actives[cat].icon = icon[cat]
			dr = dr*2
		end
		DisplayDrActives(self)
	end
end

SLASH_MOVINGDRTRACKER1 = "/tdr"
SlashCmdList["MOVINGDRTRACKER"] = tdr