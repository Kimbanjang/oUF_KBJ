local _, ns = ...
local oUF = ns.oUF or oUF

local function GetAurasCC()
	return {
		-- Spell Name			Priority (higher = more priority)
		-- Death Knight
		[GetSpellInfo(91800)] = 4,	-- Gnaw (Ghoul)
		[GetSpellInfo(91797)] = 4,	-- Monstrous Blow (Mutated Ghoul)
		[GetSpellInfo(108194)] = 4,	-- Asphyxiate
		[GetSpellInfo(115001)] = 4,	-- Remorseless Winter
		-- Druid
		[GetSpellInfo(33786)] = 4,	-- Cyclone
		[GetSpellInfo(5211)] = 4,	-- Mighty Bash
		[GetSpellInfo(22570)] = 4,	-- Maim
		[GetSpellInfo(99)] = 4,		-- Disorienting Roar
		-- Hunter
		[GetSpellInfo(3355)] = 4,	-- Freezing Trap
		[GetSpellInfo(19386)] = 4,	-- Wyvern Sting
		[GetSpellInfo(117526)] = 4,	-- Binding Shot
		[GetSpellInfo(24394)] = 4,	-- Intimidation
		-- Mage
		[GetSpellInfo(118)] = 4,	-- Polymorph
		[GetSpellInfo(44572)] = 4,	-- Deep Freeze
		[GetSpellInfo(82691)] = 4,	-- Ring of Frost
		[GetSpellInfo(31661)] = 4,	-- Dragon's Breath
		-- Monk
		[GetSpellInfo(115078)] = 4,	-- Paralysis
		[GetSpellInfo(119381)] = 4,	-- Leg Sweep
		[GetSpellInfo(120086)] = 4,	-- Fists of Fury
		[GetSpellInfo(119392)] = 4,	-- Charging Ox Wave
		-- Paladin
		[GetSpellInfo(853)] = 4,	-- Hammer of Justice
		[GetSpellInfo(105593)] = 4,	-- Fist of Justice
		[GetSpellInfo(20066)] = 4,	-- Repentance
		[GetSpellInfo(105421)] = 4,	-- Blinding Light
		-- Priest
		[GetSpellInfo(605)] = 4,	-- Dominate Mind
		[GetSpellInfo(8122)] = 4,	-- Psychic Scream
		[GetSpellInfo(64044)] = 4,	-- Psychic Horror
		-- Rogue
		[GetSpellInfo(6770)] = 4,	-- Sap
		[GetSpellInfo(2094)] = 4,	-- Blind
		[GetSpellInfo(408)] = 4,	-- Kidney Shot
		[GetSpellInfo(1833)] = 4,	-- Cheap Shot
		[GetSpellInfo(1776)] = 4,	-- Gouge
		-- Shaman
		[GetSpellInfo(51514)] = 4,	-- Hex
		[GetSpellInfo(118905)] = 4,	-- Static Charge
		-- Warlock
		[GetSpellInfo(118699)] = 4,	-- Fear
		[GetSpellInfo(30283)] = 4,	-- Shadowfury
		[GetSpellInfo(89766)] = 4,	-- Axe Toss (Felguard)
		[GetSpellInfo(5484)] = 4,	-- Howl of Terror
		[GetSpellInfo(6789)] = 4,	-- Mortal Coil
		[GetSpellInfo(6358)] = 4,	-- Seduction (Succubus)
		[GetSpellInfo(115268)] = 4,	-- Mesmerize (Shivarra)
		-- Warrior
		[GetSpellInfo(132169)] = 4,	-- Storm Bolt
		[GetSpellInfo(132168)] = 4,	-- Shockwave
		[GetSpellInfo(5246)] = 4,	-- Intimidating Shout
	
		-- Silences
		[GetSpellInfo(47476)] = 4,	-- Strangulate
		[GetSpellInfo(81261)] = 4,	-- Solar Beam
		[GetSpellInfo(102051)] = 4,	-- Frostjaw
		[GetSpellInfo(31935)] = 4,	-- Avenger's Shield
		[GetSpellInfo(15487)] = 4,	-- Silence
		[GetSpellInfo(1330)] = 4,	-- Garrote - Silence
	
		-- Roots
		[GetSpellInfo(96294)] = 3,	-- Chains of Ice
		[GetSpellInfo(339)] = 3,	-- Entangling Roots
		[GetSpellInfo(102359)] = 3,	-- Mass Entanglement
		[GetSpellInfo(45334)] = 3,	-- Immobilized
		[GetSpellInfo(135373)] = 3,	-- Entrapment
		[GetSpellInfo(136634)] = 3,	-- Narrow Escape
		[GetSpellInfo(122)] = 3,	-- Frost Nova
		[GetSpellInfo(33395)] = 3,	-- Freeze (Pet)
		[GetSpellInfo(111340)] = 3,	-- Ice Ward
		[GetSpellInfo(116706)] = 3,	-- Disable
		[GetSpellInfo(87194)] = 3,	-- Glyph of Mind Blast
		[GetSpellInfo(114404)] = 3,	-- Void Tendril's Grasp
		[GetSpellInfo(63685)] = 3,	-- Freeze (Frozen Power)
		[GetSpellInfo(64695)] = 3,	-- Earthgrab
		[GetSpellInfo(107566)] = 3,	-- Staggering Shout		

		
		[GetSpellInfo(77769)] = 1,	-- Staggering Shout
	}
end

local function Update(object, event, unit)
	if object.unit ~= unit then return end

	local auraList = GetAurasCC()
	local priority = 0
	local auraName, auraIcon, auraExpTime
	local index = 1

	-- Buffs
	while true do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, "HELPFUL")
		if not name then break end

		if auraList[name] and auraList[name] >= priority then
			priority = auraList[name]
			auraName = name
			auraIcon = icon
			auraExpTime = expirationTime
		end

		index = index + 1
	end

	index = 1

	-- Debuffs
	while true do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, "HARMFUL")
		if not name then break end

		if auraList[name] and auraList[name] >= priority then
			priority = auraList[name]
			auraName = name
			auraIcon = icon
			auraExpTime = expirationTime
		end

		index = index + 1
	end

	if auraName then -- If an aura is found, display it and set the time left!
		object.AuraTrackerCC.icon:SetTexture(auraIcon)
		object.AuraTrackerCC.cooldownFrame:SetCooldown(auraExpTime - GetTime(), GetTime())
		object.AuraTrackerCC.dropFrame:Show()
	elseif not auraName then -- No aura found and one is shown? Kill it since it's no longer active!
		object.AuraTrackerCC.icon:SetTexture("")
		object.AuraTrackerCC.cooldownFrame:Hide()		
		object.AuraTrackerCC.dropFrame:Hide()
	end
end

local function Enable(object)
	-- If we're not highlighting this unit return
	if not object.AuraTrackerCC then return end
	
	if not object.AuraTrackerCC.cooldownFrame then
		object.AuraTrackerCC.cooldownFrame = CreateFrame("Cooldown", nil, object.AuraTrackerCC)
		object.AuraTrackerCC.cooldownFrame:SetAllPoints(object.AuraTrackerCC)
		object.AuraTrackerCC.dropFrame =  CreateFrame('Frame', nil, object.AuraTrackerCC)
		object.AuraTrackerCC.dropFrame:SetAllPoints(object.AuraTrackerCC)
		object.AuraTrackerCC.dropFrame:SetFrameStrata('MEDIUM')
		object.AuraTrackerCC.dropFrame:SetBackdrop({
			edgeFile = "Interface\\AddOns\\oUF_KBJ\\Media\\borderTarget", edgeSize = 16,
			bgFile = nil,
			insets = {left = -1, right = -1, top = -1, bottom = -1}
		})
		object.AuraTrackerCC.dropFrame:SetBackdropBorderColor(1, 0, 0)
	end

	-- Make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(object)
	if object.AuraTrackerCC then
		object:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("AuraTrackerCC", Update, Enable, Disable)