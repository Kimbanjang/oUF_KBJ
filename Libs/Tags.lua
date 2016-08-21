local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local class = select(2, UnitClass('player'))

-- Custom Power Color
oUF.colors.power['MANA'] = { 0.37, 0.6, 1 }
oUF.colors.power['RAGE'] = { 0.9,  0.3,  0.23 }
oUF.colors.power['RUNIC_POWER'] = { 0, 0.81, 1 }

local function healthColor(value)    
    local r, g, b;
    local min, max = 0, 100

    if ( (max - min) > 0 ) then
        value = (value - min) / (max - min)
    else
        value = 0
    end

    if(value > 0.5) then
        r = (1.0 - value) * 2
        g = 1.0
    else
        r = 1.0
        g = value * 2
    end
    b = 0.0

    return r, g, b
end

local function powerColor(unit)
    if not unit then return end
    local id, power, r, g, b = UnitPowerType(unit)
    local color = PowerBarColor[power]
    if color then
        r, g, b = color.r, color.g, color.b
    end
    return r, g, b
end

local sValue = function(val)
	if (val >= 1e6) then
        return ('%.fm'):format(val / 1e6)
    elseif (val >= 1e3) then
        return ('%.fk'):format(val / 1e3)
    else
        return ('%d'):format(val)
    end
end

local function hex(r, g, b)
    if not r then return '|cffFFFFFF' end
    if(type(r) == 'table') then
        if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

oUF.Tags.Methods['color'] = function(u, r)
    local reaction = UnitReaction(u, 'player')
    if (UnitIsTapDenied(u)) then
        return hex(oUF.colors.tapped)
    elseif (UnitIsPlayer(u)) then
		local _, class = UnitClass(u)
        return hex(oUF.colors.class[class])
    elseif reaction and not (UnitIsPlayer(u)) then
        return hex(oUF.colors.reaction[reaction])
    else
        return hex(1, 1, 1)
    end
end
oUF.Tags.Events['color'] = 'UNIT_REACTION UNIT_HEALTH'

local function utf8sub(string, i, dots)
    local bytes = string:len()
    if bytes <= i then
        return string
    else
        local len, pos = 0, 1
        while pos <= bytes do
            len = len + 1
            local c = string:byte(pos)
            if c > 0 and c <= 127 then
                pos = pos + 1
            elseif c >= 194 and c <= 223 then
                pos = pos + 2
            elseif c >= 224 and c <= 239 then
                pos = pos + 3
            elseif c >= 240 and c <= 244 then
                pos = pos + 4
            end
            if len == i then break end
        end
        if len == i and pos <= bytes then
            return string:sub(1, pos - 1)..(dots and '*' or '')
        else
            return string
        end
    end
end

oUF.Tags.Methods['unit:name4'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 4, true)
end
oUF.Tags.Events['unit:name4'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['unit:name8'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 8, true)
end
oUF.Tags.Events['unit:name8'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['unit:name10'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 10, true)
end
oUF.Tags.Events['unit:name10'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['unit:lv'] = function(u) 
    local level = UnitLevel(u)
    local typ = UnitClassification(u)
    local color = GetQuestDifficultyColor(level)

    if level <= 0 then
        level = '??' 
    end

    if typ=='worldboss' then
        return hex(color)..level..'!'
    elseif typ=='rare' then
        return hex(color)..level..'#'
    elseif typ=='rareelite' then
        return hex(color)..level..'#+'
    elseif typ=='elite' then
        return hex(color)..level..'+'
    else
        return hex(color)..level
    end
end

oUF.Tags.Methods['unit:HPpercent'] = function(u)
    local min, max = UnitHealth(u), UnitHealthMax(u)

    if UnitIsDead(u) then
        return "|cff666666Dead|r"
    elseif UnitIsGhost(u) then
        return "|cff666666Ghost|r"
    elseif not UnitIsConnected(u) then
        return "|cffe50000Offline|r"
    else
        local healthValue = math.floor(min/max*100+.5)
        return hex(healthColor(healthValue))..healthValue
    end
end
oUF.Tags.Events['unit:HPpercent'] = 'UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags.Methods['unit:HPstring'] = function(u)
    local min = UnitHealth(u)
    return sValue(min)
end
oUF.Tags.Events['unit:HPstring'] = 'UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags.Methods['unit:HPcombo'] = function(u)
    local min, max = UnitHealth(u), UnitHealthMax(u)

    if UnitIsDead(u) then
        return "|cff666666Dead|r"
    elseif UnitIsGhost(u) then
        return "|cff666666Ghost|r"
    elseif not UnitIsConnected(u) then
        return "|cffe50000Offline|r"
    elseif (min < max) then
        local healthValue = math.floor(min/max*100+.5)
        return hex(healthColor(healthValue))..healthValue
    else
        return sValue(min)
    end
end
oUF.Tags.Events['unit:HPcombo'] = 'UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags.Methods['unit:PPflex'] = function(u)
    local min, max = UnitPower(u), UnitPowerMax(u)
    local ptype = UnitPowerType(u)
    local powerValue = math.floor(min/max*100+.5)

    if ptype == SPELL_POWER_MANA then
        return hex(powerColor(u))..powerValue
    elseif powerColor(u) then
        return hex(powerColor(u))..min
    else
        return "|cffff00ff"..min.."|r"
    end
end
oUF.Tags.Events['unit:PPflex'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'

-- Sub Mana Resource
oUF.Tags.Methods['resource:SubMana'] = function(u)
    if GetSpecializationInfo(GetSpecialization()) == 263 -- ele
    or GetSpecializationInfo(GetSpecialization()) == 262 -- enh
    or GetSpecializationInfo(GetSpecialization()) == 104 -- feral
    or GetSpecializationInfo(GetSpecialization()) == 103 -- guardian
    or GetSpecializationInfo(GetSpecialization()) == 102 -- boomkin
    then
        local min, max = UnitPower(u, SPELL_POWER_MANA), UnitPowerMax(u, SPELL_POWER_MANA)
        local powerValue = math.floor(min/max*100+.5)

        return "|cff5e99ff"..powerValue.."|r"
    end
end
oUF.Tags.Events['resource:SubMana'] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER'

-- Rouge, Cat Form Resource
oUF.Tags.Methods['resource:ComboPoints'] = function(u)
    if class == 'ROGUE'
    or GetSpecializationInfo(GetSpecialization()) == 104
    or GetSpecializationInfo(GetSpecialization()) == 103
    then
        local cp
        if (UnitHasVehicleUI'player') then
            cp = GetComboPoints('vehicle', 'target')
        else
            cp = GetComboPoints('player', 'target')
        end

        if(cp > 0) then
            return cp
        end
    -- elseif mushrooms bar
    end
end
oUF.Tags.Events['resource:ComboPoints'] = 'UNIT_POWER_FREQUENT PLAYER_TARGET_CHANGED'

-- Monk Resource
oUF.Tags.Methods['resource:ChiStagger'] = function(u)
    if GetSpecialization() == SPEC_MONK_WINDWALKER then
        local num = UnitPower('player', SPELL_POWER_CHI)
        if num > 0 then
            return num
        end
    --[[ elseif GetSpecialization() == SPEC_MONK_BREWMASTER then
        local
    ]]
    end
end
oUF.Tags.Events['resource:ChiStagger'] = 'UNIT_POWER SPELLS_CHANGED'

-- Warlock Resource
oUF.Tags.Methods['resource:SoulShards'] = function(u)
    local num = UnitPower('player', SPELL_POWER_SOUL_SHARDS)
    if(num > 0) then
        return num
    end
end
oUF.Tags.Events['resource:SoulShards'] = 'UNIT_POWER SPELLS_CHANGED'

-- Paladin Resource
oUF.Tags.Methods['resource:HolyPower'] = function(u)
    if GetSpecialization() == SPEC_PALADIN_RETRIBUTION then
        local num = UnitPower('player', SPELL_POWER_HOLY_POWER)
        if num > 0 then
            return num
        end
    end
end
oUF.Tags.Events['resource:HolyPower'] = 'UNIT_POWER SPELLS_CHANGED'

-- Mage Resource
oUF.Tags.Methods['resource:ArcaneCharges'] = function(u)
    if GetSpecialization() == SPEC_MAGE_ARCANE then
        local num = UnitPower('player', SPELL_POWER_ARCANE_CHARGES)
        if num > 0 then
            return num
        end
    end
end
oUF.Tags.Events['resource:ArcaneCharges'] = 'UNIT_POWER SPELLS_CHANGED'
