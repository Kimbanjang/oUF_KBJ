local _, ns = ...
local oUF = ns.oUF or oUF

local function GetAurasDEF()
	return {
		-- Spell Name			Priority (higher = more priority)
		-- Immunities
		[GetSpellInfo(19263)] = 2,	-- Deterrence
		[GetSpellInfo(45438)] = 2,	-- Ice Block
		[GetSpellInfo(642)] = 2,	-- Divine Shield
		[GetSpellInfo(46924)] = 2,	-- Bladestorm
		[GetSpellInfo(118038)] = 2,	-- Die by the Sword
		[GetSpellInfo(116849)] = 2,	-- Die by the Sword
		
		--[GetSpellInfo(115921)] = 1,	-- Die by the Sword
	
		-- Buffs
		[GetSpellInfo(1022)] = 1,	-- Hand of Protection
		[GetSpellInfo(6940)] = 1,	-- Hand of Sacrifice
		[GetSpellInfo(1044)] = 1,	-- Hand of Freedom
		[GetSpellInfo(31821)] = 1,	-- Devotion Aura
		[GetSpellInfo(33206)] = 1,	-- Pain Suppression
		[GetSpellInfo(8178)] = 1,	-- Grounding Totem
	
		-- Defense abilities
		[GetSpellInfo(48707)] = 1,	-- Anti-Magic Shell
		[GetSpellInfo(48792)] = 1,	-- Icebound Fortitude
		[GetSpellInfo(31224)] = 1,	-- Cloak of Shadows
		[GetSpellInfo(871)] = 1,	-- Shield Wall	
	}
end

local function Update(object, event, unit)
	if object.unit ~= unit then return end

	local auraList = GetAurasDEF()
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
		object.AuraTrackerDEF.icon:SetTexture(auraIcon)
		object.AuraTrackerDEF.cooldownFrame:SetCooldown(auraExpTime - GetTime(), GetTime())
		object.AuraTrackerDEF.dropFrame:Show()
	elseif not auraName then -- No aura found and one is shown? Kill it since it's no longer active!
		object.AuraTrackerDEF.icon:SetTexture("")
		object.AuraTrackerDEF.cooldownFrame:Hide()		
		object.AuraTrackerDEF.dropFrame:Hide()
	end
end

local function Enable(object)
	-- If we're not highlighting this unit return
	if not object.AuraTrackerDEF then return end
	
	if not object.AuraTrackerDEF.cooldownFrame then
		object.AuraTrackerDEF.cooldownFrame = CreateFrame("Cooldown", nil, object.AuraTrackerDEF)
		object.AuraTrackerDEF.cooldownFrame:SetAllPoints(object.AuraTrackerDEF)
		object.AuraTrackerDEF.dropFrame =  CreateFrame('Frame', nil, object.AuraTrackerDEF)
		object.AuraTrackerDEF.dropFrame:SetAllPoints(object.AuraTrackerDEF)
		object.AuraTrackerDEF.dropFrame:SetFrameStrata('MEDIUM')
		object.AuraTrackerDEF.dropFrame:SetBackdrop({
			edgeFile = "Interface\\AddOns\\oUF_KBJ\\Media\\borderTarget", edgeSize = 16,
			bgFile = nil,
			insets = {left = -1, right = -1, top = -1, bottom = -1}
		})
		object.AuraTrackerDEF.dropFrame:SetBackdropBorderColor(0, 1, 0)
	end

	-- Make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(object)
	if object.AuraTrackerDEF then
		object:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("AuraTrackerDEF", Update, Enable, Disable)