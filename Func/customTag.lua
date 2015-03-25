-- base source : http://www.wowinterface.com/downloads/info22575-oUF_Ascii.html by Zork

--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...

local PowerBarColor = PowerBarColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local abs, floor, format = abs, floor, format


--------------------------------------
-- Color Lib
--------------------------------------

-- Gradient Color Lib
local CS = CreateFrame("ColorSelect")

-- Get HSV from RGB Color
function GetHSVColor(color)
	CS:SetColorRGB(color.r, color.g, color.b)
	local h,s,v = CS:GetColorHSV()
	return {h=h,s=s,v=v}
end

-- Get RGB from HSV Color
function GetRGBColor(color)
	CS:SetColorHSV(color.h, color.s, color.v)
	local r,g,b = CS:GetColorRGB()
	return {r=r,g=g,b=b}
end

-- Input Two HSV Colors And a Percentage
-- Returns New HSV Color
function GetSmudgeHSVColor(colorA,colorB,percentage)
	local colorC = {}
	-- check if the angle between the two H values is > 180
	if abs(colorA.h-colorB.h) > 180 then
		local angle = (360-abs(colorA.h-colorB.h))*percentage
		if colorA.h < colorB.h then
			colorC.h = floor(colorA.h-angle)
			if colorC.h < 0 then
				colorC.h = 360+colorC.h
			end
		else
			colorC.h = floor(colorA.h+angle)
			if colorC.h > 360 then
				colorC.h = colorC.h-360
			end
		end
	else
		colorC.h = floor(colorA.h-(colorA.h-colorB.h)*percentage)
	end
	colorC.s = colorA.s-(colorA.s-colorB.s)*percentage
	colorC.v = colorA.v-(colorA.v-colorB.v)*percentage
	return colorC
end

-- GET RGB as HEX-Color
local function GetHexColor(color)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format("%02x%02x%02x", color.r*255, color.g*255, color.b*255)
end

-- GetPowerColor func
local function GetPowerColor(unit)
	if not unit then return end
	local id, power, r, g, b = UnitPowerType(unit)
	local color = PowerBarColor[power]
	if color then
		r, g, b = color.r, color.g, color.b
	end
	return {r=r,g=g,b=b}
end

-- GetLevelColor func
local function GetLevelColor(unit)
	if not unit then return end
	local level = UnitLevel(unit)
	return GetQuestDifficultyColor((level > 0) and level or 99)
end

-- GetUnitColor func
local function GetUnitColor(unit)
	if not unit then return end
	local color
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		color = {r = 0.5, g = 0.5, b = 0.5}
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = {r = 0.5, g = 0.5, b = 0.5}
	elseif UnitIsPlayer(unit) then
		color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	else
		color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
	end
	return color
end

local redColor = GetHSVColor({r=1,g=0,b=0})
local greenColor = GetHSVColor({r=0,g=1,b=0})
local whiteColor = GetHSVColor({r=1,g=1,b=1})
local comboPointColor = GetHSVColor({r=1,g=0.3,b=0.3})
local warlockSpecColor = GetHSVColor({r=0.9,g=0.37,b=0.37})
local chiColor = GetHSVColor({r=0.52,g=1,b=0.52})

-- GetHealthColor func
local function GetHealthColor(unit)
	if not unit then return end
	local hcur, hmax = UnitHealth(unit), UnitHealthMax(unit)
	local hper = 0
	if hmax > 0 then hper = hcur/hmax end
	--you may need to swap red and green color
	return GetRGBColor(GetSmudgeHSVColor(redColor,greenColor,hper))
end

-- GetCPointColor func
local function GetCPointColor(unit)
	if not unit then return end
	local cpcur = oUF.Tags.Methods["cpoints"](unit)
	if cpcur == null then cpcur = 0 end
	local cpmax = MAX_COMBO_POINTS
	local cpper = 0
	if cpmax > 0 then cpper = cpcur/cpmax end
	return GetRGBColor(GetSmudgeHSVColor(whiteColor,comboPointColor,cpper))
end

-- GetWarlockSSColor func
local function GetWarlockSSColor(unit)
	if not unit then return end
	local wlsscur = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
	local wlssmax = UnitPowerMax(unit, SPELL_POWER_SOUL_SHARDS)
	local wlssper = 0
	if wlssmax > 0 then wlssper = wlsscur/wlssmax end
	return GetRGBColor(GetSmudgeHSVColor(whiteColor,warlockSpecColor,wlssper))
end

-- GetWarlockDFColor func
local function GetWarlockDFColor(unit)
	if not unit then return end
	local wldfcur = UnitPower(unit, SPELL_POWER_DEMONIC_FURY)
	local wldfmax = UnitPowerMax(unit, SPELL_POWER_DEMONIC_FURY)
	local wldfper = 0
	if wldfmax > 0 then wldfper = wldfcur/wldfmax end
	return GetRGBColor(GetSmudgeHSVColor(whiteColor,warlockSpecColor,wldfper))
end

-- GetWarlockBEColor func
local function GetWarlockBEColor(unit)
	if not unit then return end
	local wlbecur = UnitPower(unit, POWER_BURNING_EMBERS)
	local wlbemax = UnitPowerMax(unit, POWER_BURNING_EMBERS)
	local wlbeper = 0
	if wlbemax > 0 then wlbeper = wlbecur/wlbemax end
	return GetRGBColor(GetSmudgeHSVColor(whiteColor,warlockSpecColor,wlbeper))
end

-- GetMonkChiColor func
local function GetMonkChiColor(unit)
	if not unit then return end
	local chicur = oUF.Tags.Methods["chi"](unit)
	if chicur == null then chicur = 0 end
	local chimax = UnitPowerMax('player', SPELL_POWER_CHI)
	local chiper = 0
	if chimax > 0 then chiper = chicur/chimax end
	return GetRGBColor(GetSmudgeHSVColor(whiteColor,chiColor,chiper))
end

--------------------------------------
-- Custom Tag
--------------------------------------

-- Unit Name Tag
oUF.Tags.Methods["unit:name"] = function(unit)
	local name = oUF.Tags.Methods["name"](unit)
	local color = GetUnitColor(unit)
	if color then
		return "|cff"..GetHexColor(color)..name.."|r"
	else
		return "|cffff00ff"..name.."|r"
	end
end
oUF.Tags.Events["unit:name"] = "UNIT_NAME_UPDATE UNIT_CONNECTION"

-- Unit Level Tag
oUF.Tags.Methods["unit:level"] = function(unit)
	local unit_classification = UnitClassification(unit)
	if unit_classification == "worldboss" or UnitLevel(unit) == -1 then
		cifistring = "!"
	elseif unit_classification == "rare" or unit_classification == "rareelite" then
		cifistring = "#"
		if unit_classification == "rareelite" then
			cifistring = cifistring.."+"
		end
	elseif unit_classification == "elite" then
		cifistring = "+"
	else
		cifistring = ""
	end
	local level = oUF.Tags.Methods["level"](unit)
	local color = GetLevelColor(unit)
	if color then
		return "|cff"..GetHexColor(color)..level..cifistring.."|r"
	else
		return "|cffff00ff"..level..cifistring.."|r"
	end
end
oUF.Tags.Events["unit:level"] = "UNIT_NAME_UPDATE UNIT_CONNECTION"

-- Unit Health Tag 
oUF.Tags.Methods["unit:health"] = function(unit)
	local perhp = oUF.Tags.Methods["perhp"](unit)
	local color = GetHealthColor(unit)
	if color then
		return "|cff"..GetHexColor(color)..perhp.."|r"
	else
		return "|cffff00ff"..perhp.."|r"
	end
end
oUF.Tags.Events["unit:health"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"

-- Unit Power Tag
oUF.Tags.Methods["unit:power"] = function(unit)
	local perpp = oUF.Tags.Methods["perpp"](unit)
	local color = GetPowerColor(unit)
	if color then
		return "|cff"..GetHexColor(color)..perpp.."|r"
	else
		return "|cffff00ff"..perpp.."|r"
	end
end
oUF.Tags.Events["unit:power"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER"

-- Short HP Tag
oUF.Tags.Methods["unit:shorthp"] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		local hp = UnitHealth(unit)
		return AbbreviateLargeNumbers(hp)
	end
	local color = "|cffff00ff"
end
oUF.Tags.Events["unit:shorthp"] = "UNIT_HEALTH"

-- ComboPoints Tag
oUF.Tags.Methods["unit:cpoints"] = function(unit)
	local cPs = oUF.Tags.Methods["cpoints"](unit)
	if cPs == null then cPs = "" end
	local cpcolor = GetCPointColor(unit)
	if cpcolor then
		return "|cff"..GetHexColor(cpcolor)..cPs.."|r"
	else
		return "|cffffffff"..cPs.."|r"
	end
end
oUF.Tags.Events["unit:cpoints"] = "UNIT_COMBO_POINTS PLAYER_TARGET_CHANGED"

-- Warlock Resource Tag
oUF.Tags.Methods['unit:warlockresource'] = function(unit)
	local warlockSpec
	if IsPlayerSpell(WARLOCK_METAMORPHOSIS) then warlockSpec = 2
	elseif IsPlayerSpell(WARLOCK_BURNING_EMBERS) then warlockSpec = 3
	else warlockSpec = 1 end

	if warlockSpec == 2 then
		local dfcolor = GetWarlockDFColor(unit)
		local dfcur = UnitPower(unit, SPELL_POWER_DEMONIC_FURY)
		if dfcolor then
			if(dfcur >= 0) then return "|cff"..GetHexColor(dfcolor)..dfcur.."|r" end
		else
			if(dfcur >= 0) then return "|cffffffff"..dfcur.."|r" end
		end
	elseif warlockSpec == 3 then
		local becolor = GetWarlockBEColor(unit)
		local becur = UnitPower('player', SPELL_POWER_BURNING_EMBERS)
		if becolor then
			if(becur >= 0) then return "|cff"..GetHexColor(becolor)..becur.."|r" end
		else
			if(becur >= 0) then return "|cffffffff"..becur.."|r" end
		end
	else
		local sscolor = GetWarlockSSColor(unit)
		local sscur = UnitPower('player', SPELL_POWER_SOUL_SHARDS)
		if sscolor then
			if(sscur >= 0) then return "|cff"..GetHexColor(sscolor)..sscur.."|r" end
		else
			if(sscur >= 0) then return "|cffffffff"..sscur.."|r" end
		end
	end
end
oUF.Tags.Events["unit:warlockresource"] = "UNIT_POWER SPELLS_CHANGED"

-- Monk Chi Tag
oUF.Tags.Methods["unit:monkchi"] = function(unit)
	local mChi = oUF.Tags.Methods["chi"](unit)
	if mChi == null then mChi = "" end
	local mChiColor = GetMonkChiColor(unit)
	if mChiColor then
		return "|cff"..GetHexColor(mChiColor)..mChi.."|r"
	else
		return "|cffffffff"..mChi.."|r"
	end
end
oUF.Tags.Events["unit:monkchi"] = "UNIT_POWER"
