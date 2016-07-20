local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local class = select(2, UnitClass('player'))

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
    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

oUF.colors.power['MANA'] = {0.37, 0.6, 1}
oUF.colors.power['RAGE']  = {0.9,  0.3,  0.23}
oUF.colors.power['FOCUS']  = {1, 0.81,  0.27}
oUF.colors.power['RUNIC_POWER']  = {0, 0.81, 1}
oUF.colors.power['AMMOSLOT'] = {0.78,1, 0.78}
oUF.colors.power['FUEL'] = {0.9,  0.3,  0.23}
oUF.colors.power['POWER_TYPE_STEAM'] = {0.55, 0.57, 0.61}
oUF.colors.power['POWER_TYPE_PYRITE'] = {0.60, 0.09, 0.17}	
oUF.colors.power['POWER_TYPE_HEAT'] = {0.55,0.57,0.61}
oUF.colors.power['POWER_TYPE_OOZE'] = {0.76,1,0}
oUF.colors.power['POWER_TYPE_BLOOD_POWER'] = {0.7,0,1}
--oUF.colors.runes = { {196/255, 30/255, 58/255}; {173/255, 217/255, 25/255}; {35/255, 127/255, 255/255}; {178/255, 53/255, 240/255}; }

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

oUF.Tags.Methods['unit:hp'] = function(u)
    local min, max = UnitHealth(u), UnitHealthMax(u)

    if UnitIsDead(u) then
        return '|cff666666Dead|r'
    elseif UnitIsGhost(u) then
        return '|cff666666Ghost|r'
    elseif not UnitIsConnected(u) then
        return '|cffe50000Offline|r'           
    elseif (min < max) then
        local healthValue = math.floor(min/max*100+.5)
        return hex(healthColor(healthValue))..healthValue
    else
        return sValue(min)
    end
end
oUF.Tags.Events['unit:hp'] = "UNIT_HEALTH UNIT_CONNECTION"

oUF.Tags.Methods['unit:perhp'] = function(u)
    local min, max = UnitHealth(u), UnitHealthMax(u)

    if UnitIsDead(u) then
        return '|cff666666Dead|r'
    elseif UnitIsGhost(u) then
        return '|cff666666Ghost|r'
    elseif not UnitIsConnected(u) then
        return '|cffe50000Offline|r'           
    else
        local healthValue = math.floor(min/max*100+.5)
        return hex(healthColor(healthValue))..healthValue
    end
end
oUF.Tags.Events['unit:perhp'] = "UNIT_HEALTH UNIT_CONNECTION"

oUF.Tags.Methods['unit:perhealth'] = function(u)
    local min = UnitHealth(u)
    return sValue(min)
end
oUF.Tags.Events['unit:perhealth'] = "UNIT_HEALTH UNIT_CONNECTION"

oUF.Tags.Methods['unit:pp'] = function(u)
    local min, max = UnitPower(u), UnitPowerMax(u)
    local powerValue = math.floor(min/max*100+.5)
    
    if powerColor(u) then        
        return hex(powerColor(u))..powerValue
    else
        return "|cffff00ff"..powerValue.."|r"
    end
end
oUF.Tags.Events['unit:pp'] = "UNIT_POWER UNIT_MAXPOWER PLAYER_SPECIALIZATION_CHANGED"

oUF.Tags.Methods['altpower'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)
    local per = math.floor(cur/max*100+.5)
	return ('|cffCDC5C2'..sValue(cur))..('|cffCDC5C2 || ')..sValue(max)
end
oUF.Tags.Events['altpower'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags.Methods['EclipseDirection'] = function(u)
    local direction = GetEclipseDirection()
	if direction == 'sun' then
		return '  '..' |cff4478BC>>|r'
	elseif direction == 'moon' then
		return '|cffE5994C<<|r '..'  '
	end
end
oUF.Tags.Events['EclipseDirection'] = 'UNIT_POWER ECLIPSE_DIRECTION_CHANGE'

-- Warlock Resource Tag
oUF.Tags.Methods['resource:warlock'] = function(u)
    local warlockSpec
    if IsPlayerSpell(WARLOCK_METAMORPHOSIS) then warlockSpec = 2
    elseif IsPlayerSpell(WARLOCK_BURNING_EMBERS) then warlockSpec = 3
    else warlockSpec = 1 end

    if warlockSpec == 2 then
        return UnitPower(u, SPELL_POWER_DEMONIC_FURY)
    elseif warlockSpec == 3 then
        return UnitPower(u, SPELL_POWER_BURNING_EMBERS)
    else
        return UnitPower(u, SPELL_POWER_SOUL_SHARDS)
    end
end
oUF.Tags.Events["resource:warlock"] = "UNIT_POWER SPELLS_CHANGED"

-- Shaman Resource Tag
oUF.Tags.Methods['resource:shaman'] = function(u)
    local shamanSpec
    if IsPlayerSpell(17364) then shamanSpec = 3 end
    if shamanSpec == 3 then
        local aura = GetSpellInfo(53817)
        local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura('player', aura, nil, 'HELPFUL')
        return count
    end
end
oUF.Tags.Events["resource:shaman"] = "UNIT_AURA PLAYER_TALENT_UPDATE"

--[[
oUF.Tags.Methods['player:power'] = function(u)
    local spec = GetSpecialization()
    local fury = UnitPower('player', SPELL_POWER_DEMONIC_FURY)
    local mana = UnitPower('player', SPELL_POWER_MANA)
    local stagger = UnitStagger('player')
    if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
        return nil 
    elseif class == 'WARLOCK' and spec == SPEC_WARLOCK_DEMONOLOGY then
        local r, g, b = 0.9, 0.37, 0.37
        return ('|cff559655 || ')..hex(r, g, b)..sValue(fury) 
    elseif class == 'DRUID' and not UnitPowerType('player') == SPELL_POWER_MANA then
        local r, g, b = oUF.colors.power['MANA']
        return ('|cff559655 || ')..hex(r, g, b)..sValue(mana)
    elseif class == 'MONK' and stagger > 0 then
        local r, g, b = 0.52, 1.0, 0.52
        return ('|cff559655 || ')..hex(r, g, b)..sValue(stagger)
    else 
        return nil  
    end
end
oUF.Tags.Events['player:power'] = 'UNIT_POWER PLAYER_SPECIALIZATION_CHANGED PLAYER_TALENT_UPDATE UNIT_HEALTH UNIT_CONNECTION'
]]
