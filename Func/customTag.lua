-- base source : http://www.wowinterface.com/downloads/info22575-oUF_Ascii.html by zork

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

local redColor = GetHSVColor({r=1,g=0,b=0})
local greenColor = GetHSVColor({r=0,g=1,b=0})

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

-- GetHealthColor func
local function GetHealthColor(unit)
	if not unit then return end

	local hcur, hmax = UnitHealth(unit), UnitHealthMax(unit)
	local hper = 0
	if hmax > 0 then hper = hcur/hmax end
	--you may need to swap red and green color
	return GetRGBColor(GetSmudgeHSVColor(redColor,greenColor,hper))
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
