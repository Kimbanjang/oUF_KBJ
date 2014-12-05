--------------------------------------
--VARIABLES
--------------------------------------

local _, ns = ...

local PowerBarColor = PowerBarColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local abs, floor, format = abs, floor, format

local fontNumber = "Fonts\\DAMAGE.ttf"
local fontGeneral = STANDARD_TEXT_FONT

--------------------------------------
--COLOR LIB
--------------------------------------

--gradient color lib
local CS = CreateFrame("ColorSelect")

--get HSV from RGB color
function GetHSVColor(color)
  CS:SetColorRGB(color.r, color.g, color.b)
  local h,s,v = CS:GetColorHSV()
  return {h=h,s=s,v=v}
end

--get RGB from HSV color
function GetRGBColor(color)
  CS:SetColorHSV(color.h, color.s, color.v)
  local r,g,b = CS:GetColorRGB()
  return {r=r,g=g,b=b}
end

--input two HSV colors and a percentage
--returns new HSV color
function GetSmudgeHSVColor(colorA,colorB,percentage)
  local colorC = {}
  --check if the angle between the two H values is > 180
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

--------------------------------------
--GET RGB as HEX-Color
--------------------------------------

local function GetHexColor(color)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format("%02x%02x%02x", color.r*255, color.g*255, color.b*255)
end

--------------------------------------
--COLOR FUNCTIONS
--------------------------------------

--GetPowerColor func
local function GetPowerColor(unit)
  if not unit then return end
  local id, power, r, g, b = UnitPowerType(unit)
  local color = PowerBarColor[power]
  if color then
    r, g, b = color.r, color.g, color.b
  end
  return {r=r,g=g,b=b}
end

--GetLevelColor func
local function GetLevelColor(unit)
  if not unit then return end
  local level = UnitLevel(unit)
  return GetQuestDifficultyColor((level > 0) and level or 99)
end

--GetUnitColor func
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

--GetHealthColor func
local function GetHealthColor(unit)
  if not unit then return end
  local hcur, hmax = UnitHealth(unit), UnitHealthMax(unit)
  local hper = 0
  if hmax > 0 then hper = hcur/hmax end
  --you may need to swap red and green color
  return GetRGBColor(GetSmudgeHSVColor(redColor,greenColor,hper))
end

--------------------------------------
--CUSTOM TAGS
--------------------------------------

--unit name tag
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

--unit level tag
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

--unit health tag 
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

--unit power tag
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

--Short HP Tag
oUF.Tags.Methods["unit:shorthp"] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		local hp = UnitHealth(unit)
		return AbbreviateLargeNumbers(hp)
	end
	local color = "|cffff00ff"
end
oUF.Tags.Events["unit:shorthp"] = "UNIT_HEALTH"

--------------------------------------
--STYLE TEMPLATE
--------------------------------------

local function StyleTemplate(self, unit, isSingle)
	self:SetSize(64,32)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	-- Units
	if (unit == 'player') then
		local playerHpPer = self:CreateFontString(nil, "OVERLAY")
		playerHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		playerHpPer:SetFont(fontNumber, 18, 'THINOUTLINE')
		self:Tag(playerHpPer, "[unit:health]")
		local playerPpPer = self:CreateFontString(nil, "OVERLAY")
		playerPpPer:SetPoint("CENTER", playerHpPer, "BOTTOM", 0, -4)
		playerPpPer:SetFont(fontNumber, 10, 'THINOUTLINE')
		self:Tag(playerPpPer, "[unit:power]")
	elseif (unit == 'pet') then
		local petHpPer = self:CreateFontString(nil, "OVERLAY")
		petHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		petHpPer:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(petHpPer, "[unit:health]")
	elseif (unit == 'target') then
		local targetHpPer = self:CreateFontString(nil, "OVERLAY")
		targetHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		targetHpPer:SetFont(fontNumber, 32, 'THINOUTLINE')
		self:Tag(targetHpPer, "[unit:health]")
		local targetHpCur = self:CreateFontString(nil, "OVERLAY")
		targetHpCur:SetPoint("CENTER", targetHpPer, "TOP", 0, 5)
		targetHpCur:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(targetHpCur, "[unit:shorthp]")
		local targetPpPer = self:CreateFontString(nil, "OVERLAY")
		targetPpPer:SetPoint("CENTER", targetHpPer, "BOTTOM", 1, -8)
		targetPpPer:SetFont(fontNumber, 20, 'THINOUTLINE')
		self:Tag(targetPpPer, "[unit:power]")
		local targetName = self:CreateFontString(nil, "OVERLAY")
		targetName:SetPoint("LEFT", targetHpPer, "TOP", 40, -7)
		targetName:SetFont(fontGeneral, 12, 'THINOUTLINE')
		self:Tag(targetName, "[unit:level] [unit:name]")
	elseif (unit == 'targettarget') then
		local targettargetStat = self:CreateFontString(nil, "OVERLAY")
		targettargetStat:SetPoint("LEFT", self, "LEFT", 0, 0)
		targettargetStat:SetFont(fontGeneral, 12, 'THINOUTLINE')
		self:Tag(targettargetStat, "[unit:health] [unit:name]")
	elseif (unit == 'focus') then
		local focusHpPer = self:CreateFontString(nil, "OVERLAY")
		focusHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		focusHpPer:SetFont(fontNumber, 20, 'THINOUTLINE')
		self:Tag(focusHpPer, "[unit:health]")
		local focusName = self:CreateFontString(nil, "OVERLAY")
		focusName:SetPoint("CENTER", focusHpPer, "TOP", 0, 6)
		focusName:SetFont(fontGeneral, 9, 'THINOUTLINE')
		self:Tag(focusName, "[unit:name]")
	elseif (unit == 'focustarget') then
		local focustargetHpPer = self:CreateFontString(nil, "OVERLAY")
		focustargetHpPer:SetPoint("LEFT", self, "LEFT", 0, 0)
		focustargetHpPer:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(focustargetHpPer, "[unit:health] [unit:name]")
	end

	-- Raid Target Icon
	if (unit == 'target') then
		self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
		self.RaidIcon:SetPoint("CENTER", UIParent, 196, 12)
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(30, 30)
	end
end

--------------------------------------
--SPAWN STYLE
--------------------------------------

oUF:RegisterStyle("Style", StyleTemplate)
oUF:Factory(function(self)
	self:SetActiveStyle("Style")

	local player = oUF:Spawn("player")
	player:SetPoint("CENTER", UIParent, 130, -10)
	local pet = oUF:Spawn("pet")
	pet:SetPoint("CENTER", UIParent, 129, 5)
	local target = oUF:Spawn("target")
	target:SetPoint("CENTER", player, "BOTTOMRIGHT", 36, 10)
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("CENTER", target, "BOTTOMRIGHT", 40, 13)
	local focus = oUF:Spawn("focus")
	focus:SetPoint("CENTER", UIParent, 370, 104)
	local focustarget = oUF:Spawn("focustarget")
	focustarget:SetPoint("CENTER", focus, "RIGHT", 25, 2)
end)