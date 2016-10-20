local name, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF
local class = select(2, UnitClass('player'))
local powerType, powerTypeString = UnitPowerType('player')

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local Loader = CreateFrame('Frame')
Loader:RegisterEvent('ADDON_LOADED')
Loader:SetScript('OnEvent', function(self, event, addon)
	ActivityAuras = ActivityAuras or {}
	PersonalAuras = PersonalAuras or {}
	UpdateAuraList()
end)

local OnEnter = function(self)
    UnitFrame_OnEnter(self)
    self.Highlight:Show()	
end

local OnLeave = function(self)
    UnitFrame_OnLeave(self)
    self.Highlight:Hide()	
end
	
local ChangedTarget = function(self)
    if UnitIsUnit('target', self.unit) then
        self.TargetBorder:Show()
    else
        self.TargetBorder:Hide()
    end
end

local FocusTarget = function(self)
    if UnitIsUnit('focus', self.unit) then
        self.FocusHighlight:Show()
    else
        self.FocusHighlight:Hide()
    end
end

local dropdown = CreateFrame('Frame', name .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')
local menu = function(self)
	dropdown:SetParent(self)
	return ToggleDropDownMenu(1, nil, dropdown, self:GetName(), -3, 0)
end

local init = function(self)
	local unit = self:GetParent().unit
	local menu, name, id

	if(not unit) then
		return
	end

	if(UnitIsUnit(unit, 'player')) then
		menu = 'SELF'
    elseif(UnitIsUnit(unit, 'vehicle')) then
		menu = 'VEHICLE'
	elseif(UnitIsUnit(unit, 'pet')) then
		menu = 'PET'
	elseif(UnitIsPlayer(unit)) then
		id = UnitInRaid(unit)
		if(id) then
			menu = 'RAID_PLAYER'
			name = GetRaidRosterInfo(id)
		elseif(UnitInParty(unit)) then
			menu = 'PARTY'
		else
			menu = 'PLAYER'
		end
	else
		menu = 'TARGET'
		name = RAID_TARGET_ICON
	end

	if(menu) then
		UnitPopup_ShowMenu(self, menu, unit, name, id)
	end
end

UIDropDownMenu_Initialize(dropdown, init, 'MENU')

local GetTime = GetTime
local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60
local FormatTime = function(s)
    if s >= day then
        return format('%dd', floor(s/day + 0.5))
    elseif s >= hour then
        return format('%dh', floor(s/hour + 0.5))
    elseif s >= minute then
        return format('%dm', floor(s/minute + 0.5))
    end
    return format('%d', fmod(s, minute))
end

local CreateAuraTimer = function(self,elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		self.timeLeft = self.expires - GetTime()
		if self.timeLeft > 0 then
			local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
			if self.timeLeft < 6 then
				self.remaining:SetTextColor(0.69, 0.31, 0.31)
			elseif self.timeLeft < 60 then
				self.remaining:SetTextColor(1, 0.85, 0)
			else
				self.remaining:SetTextColor(1, 1, 1)
			end
		else
			self.remaining:Hide()
			self:SetScript('OnUpdate', nil)
		end
		self.elapsed = 0
	end
end

local auraIcon = function(auras, button)
    local c = button.count
    c:ClearAllPoints()
	c:SetPoint('BOTTOMRIGHT', 3, -1)
    c:SetFontObject(nil)
    c:SetFont(cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag)
    c:SetTextColor(1, 1, 1)	
	
    auras.disableCooldown = cfg.aura.disableCooldown	
	auras.showDebuffType = true
	
    button.overlay:SetTexture(nil)
	button.icon:SetTexCoord(.1, .9, .1, .9)
	button:SetBackdrop(backdrop)
	button:SetBackdropColor(0, 0, 0, 1)
	
    button.glow = CreateFrame('Frame', nil, button)
    button.glow:SetPoint('TOPLEFT', button, 'TOPLEFT', -4, 4)
    button.glow:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 4, -4)
    button.glow:SetFrameLevel(button:GetFrameLevel()-1)
    button.glow:SetBackdrop({bgFile = '', edgeFile = cfg.glow, edgeSize = 5,
	insets = {left = 3,right = 3,top = 3,bottom = 3,},
	})
	
    local remaining = fs(button, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 1, 1, 1)
    remaining:SetPoint('TOPLEFT')
    button.remaining = remaining
end

local PostUpdateIcon = function(icons, unit, icon, index, offset)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster = UnitAura(unit, index, icon.filter)
	local texture = icon.icon
	if icon.isPlayer or UnitIsFriend('player', unit) or not icon.isDebuff then
		texture:SetDesaturated(false)
	else
		texture:SetDesaturated(true)
	end
	if duration and duration > 0 then
		icon.remaining:Show()
	else
		icon.remaining:Hide()
	end
	
	local r,g,b = icon.overlay:GetVertexColor()
	if icon.isDebuff then
		icon.glow:SetBackdropBorderColor(r, g, b, 1)
	else 
		icon.glow:SetBackdropBorderColor(0, 0, 0, 1)
	end	
	
    icon.duration = duration
    icon.expires = expirationTime
    icon:SetScript('OnUpdate', CreateAuraTimer)
end

local CustomFilter = function(icons, ...)
    local _, icon, name, _, _, _, _, _, _, caster = ...
    local isPlayer
    if (caster == 'player' or caster == 'vechicle') then
        isPlayer = true
    end
    if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
        icon.isPlayer = isPlayer
        icon.owner = caster
        return true
    end
end

local PostUpdateHealth = function(health, unit)
	if(UnitIsDead(unit)) then
		health:SetValue(0)
	elseif(UnitIsGhost(unit)) then
		health:SetValue(0)
	elseif not (UnitIsConnected(unit)) then
	    health:SetValue(0)
	end
end

--[[
local PostUpdatePower = function(Power, unit, min, max)
	local h = Power:GetParent().Health
	if max == 0 then
		Power:Hide()
		h:SetHeight(cfg.player.health+cfg.player.power+1)
	else
	    Power:Show()
		h:SetHeight(cfg.player.health)
	end
end
]]

local AWIcon = function(AWatch, icon, spellID, name, self)			
	local count = fs(icon, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 1, 1, 1)
	count:SetPoint('BOTTOMRIGHT', icon, 5, -5)
	icon.count = count
	icon.cd:SetReverse(true)
end

local createAuraWatch = function(self, unit)
	if cfg.aw.enable and cfg.spellIDs[class] then
		local auras = CreateFrame('Frame', nil, self)
		auras:SetAllPoints(self.Health)
		auras.onlyShowPresent = cfg.aw.onlyShowPresent
		auras.anyUnit = cfg.aw.anyUnit
		auras.icons = {}
		auras.PostCreateIcon = AWIcon
		
		for i, v in pairs(cfg.spellIDs[class]) do
			local icon = CreateFrame('Frame', nil, auras)
			icon.spellID = v[1]
			icon:SetSize(6, 6)
			if v[3] then
			    icon:SetPoint(v[3])
			else
			    icon:SetPoint('BOTTOMRIGHT', self.Health, 'BOTTOMLEFT', 7 * i, 0)
			end
			icon:SetBackdrop(backdrop)
	        icon:SetBackdropColor(0, 0, 0, 1)
			
			local tex = icon:CreateTexture(nil, 'ARTWORK')
			tex:SetAllPoints(icon)
			tex:SetTexCoord(.1, .9, .1, .9)
			tex:SetTexture(cfg.texture)
			tex:SetVertexColor(unpack(v[2]))
			icon.icon = tex
		
			auras.icons[v[1]] = icon
		end
		self.AuraWatch = auras
	end
end

local Healcomm = function(self) 
	local myBar = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.6)
	myBar:SetPoint('TOP')
	myBar:SetPoint('BOTTOM')
	myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	   
	local otherBar = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.6)
	otherBar:SetPoint('TOP')
	otherBar:SetPoint('BOTTOM')
	otherBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')

    local absorbBar = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.6)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	
    local healAbsorbBar = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.6)
    healAbsorbBar:SetPoint('TOP')
    healAbsorbBar:SetPoint('BOTTOM')
    healAbsorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
   
	self.HealPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		frequentUpdates = true,
   }
end

local AuraTracker = function(self)
	self.PortraitTimer = CreateFrame('Frame', nil, self.Health)
    self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, 'BACKGROUND')
    self.PortraitTimer.Icon:SetSize(32, 32)
	self.PortraitTimer.Icon:SetPoint("CENTER", self.Health, "CENTER", 0, -1)

    self.PortraitTimer.Remaining = self.PortraitTimer:CreateFontString(nil, 'OVERLAY')
    self.PortraitTimer.Remaining:SetPoint('BOTTOM', self.PortraitTimer.Icon)
    self.PortraitTimer.Remaining:SetFont(cfg.font, 15, 'THINOUTLINE')
    self.PortraitTimer.Remaining:SetTextColor(1, 1, 1)
end

local Health = function(self) 
	local h = createStatusbar(self, cfg.texture, nil, nil, nil, 1, 1, 1, 1)
    h:SetPoint'TOP'
	h:SetPoint'LEFT'
	h:SetPoint'RIGHT'

	h.Smooth = true
	
	local hbg = h:CreateTexture(nil, 'BACKGROUND')
	h.colorClass = true
    h.colorReaction = true
    h.frequentUpdates = false
    hbg:SetAllPoints(h)
    hbg:SetTexture(cfg.texture)	
    hbg.multiplier = .4	
		
	h.bg = hbg
    self.Health	= h 
	self.Health.PostUpdate = PostUpdateHealth
end

local Power = function(self) 
    local p = createStatusbar(self, cfg.texture, nil, nil, nil, 1, 1, 1, 1)
	p:SetPoint'LEFT'
	p:SetPoint'RIGHT'
    p:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1)

    p.Smooth = true
	
	if unit == 'player' and powerType ~= 0 then p.frequentUpdates = true end	   

    local pbg = p:CreateTexture(nil, 'BACKGROUND')
    p.colorPower = true
    pbg:SetAllPoints(p)
    pbg:SetTexture(cfg.texture)		
    pbg.multiplier = .4
		
	p.bg = pbg
	self.Power = p 
end

local ph = function(self) 
	local ph = CreateFrame('Frame', nil, self.Health)
	ph:SetFrameLevel(self.Health:GetFrameLevel()+1)
	ph:SetSize(10, 10)
	ph:SetPoint('CENTER', 0,-3)
	ph:SetAlpha(0.2)
	ph.text = fs(ph, 'OVERLAY', cfg.symbol, 18, '', 1, 0, 1)
	ph.text:SetShadowOffset(1, -1)
	ph.text:SetPoint('CENTER')
	ph.text:SetText('M')
    self.PhaseIcon = ph
end

local Shared = function(self, unit)
    self.menu = menu
	
    self:SetScript('OnEnter', OnEnter)
    self:SetScript('OnLeave', OnLeave)
	
    self:RegisterForClicks'AnyUp'
	
	self:SetBackdrop({
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
	})	
	self:SetBackdropColor(0, 0, 0)
	
	Health(self)	
	
	local hl = self.Health:CreateTexture(nil, 'OVERLAY')
    hl:SetAllPoints(self)
    hl:SetTexture([=[Interface\Buttons\WHITE8x8]=])
    hl:SetVertexColor(1,1,1,.05)
    hl:SetBlendMode('ADD')
    hl:Hide()
	self.Highlight = hl
	
	self.Range = { insideAlpha = 1, outsideAlpha = 0.4 }
end

local UnitSpecific = {
    player = function(self, ...)
		Shared(self, ...)

		self.unit = 'player'
		
		Power(self)

		self.framebd = framebd(self, self)		
		self.DebuffHighlight = cfg.dh.player

	    if cfg.player_cb.enable then
            castbar(self)
	        PetCastingBarFrame:UnregisterAllEvents()
	        PetCastingBarFrame.Show = function() end
	        PetCastingBarFrame:Hide()
        end
		if cfg.options.healcomm then Healcomm(self) end

		self:SetSize(cfg.player.width, cfg.player.health+cfg.player.power+1)	
		self.Health:SetHeight(cfg.player.health)
		self.Health:SetOrientation("VERTICAL")
	    self.Power:SetHeight(cfg.player.power)

        local htext = fs(self.Health, 'OVERLAY', cfg.font, 15, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('TOP', self.Health, 'TOP', 1.5, -1)        
        htext:SetJustifyH('CENTER')
        self:Tag(htext, '[unit:HPpercent]')
        local ptext = fs(self.Power, 'OVERLAY', cfg.font, 10, cfg.fontflag, 1, 1, 1)
        ptext:SetPoint('CENTER', self.Power, 'CENTER', 1, 0)        
        ptext:SetJustifyH('CENTER')
        self:Tag(ptext, '[unit:PPflex]')
        local classResource = fs(self, 'OVERLAY', cfg.font, 34, cfg.fontflag)
		classResource:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -2, 4)
		classResource:SetAlpha(.8)
		self:Tag(classResource, '[color][unit:Resource]')		
		local subMana = fs(self.Power, 'OVERLAY', cfg.font, 10, cfg.fontflag)
		subMana:SetPoint('RIGHT', self.Power, 'LEFT', -1, 0)        
        subMana:SetJustifyH('CENTER')
        self:Tag(subMana, '[unit:SubMana]')

        -- Class Special Bar
		if class == 'DEATHKNIGHT'
		and not UnitHasVehicleUI'player'
			then
			local runes = CreateFrame('Frame', nil, self)
            runes:SetPoint('BOTTOMRIGHT', self.Power, 'BOTTOMLEFT', -4, 0)
            runes:SetSize(12, cfg.player.health+cfg.player.power+1)
            runes.bg = framebd(runes, runes)
			local i = 6
            for index = 1, 6 do
                runes[i] = createStatusbar(runes, cfg.texture, nil, (cfg.player.health+cfg.player.power+2)/6-1, 12, 0.21, 0.6, 0.7, 1)
			    if i == 6 then
                    runes[i]:SetPoint('BOTTOM', runes)
                else
                    runes[i]:SetPoint('BOTTOMRIGHT', runes[i+1], 'TOPRIGHT', 0, 1)
                end
                runes[i].bg = runes[i]:CreateTexture(nil, 'BACKGROUND')
                runes[i].bg:SetAllPoints(runes[i])
                runes[i].bg:SetTexture(cfg.texture)
                runes[i].bg.multiplier = .3

                i=i-1
            end
            self.Runes = runes
		elseif class == 'MONK' then
			-- Stagger? like Runebar
		elseif class == 'DRUID' then
			-- MushroomBar?
		elseif class == 'SHAMAN' then
			-- TotemBar? like Runebar
		end

        self.Combat = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Combat:SetSize(16, 16)
		self.Combat:SetPoint('CENTER', self, 'CENTER',0, 2)
		self.Resting = self:CreateTexture(nil, 'OVERLAY')
		self.Resting:SetSize(18, 18)
		self.Resting:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT', 3, 0)

		-- GCD Bar
		if cfg.gcd.enable then
			local class_color = RAID_CLASS_COLORS[class]
		    local gcd = createStatusbar(self, cfg.texture, nil, cfg.player_cb.height/4, cfg.player_cb.width-2, class_color.r, class_color.g, class_color.b, 1)
		    gcd:SetPoint(unpack(cfg.gcd.pos))
			gcd.bg = gcd:CreateTexture(nil, 'BORDER')
            gcd.bg:SetAllPoints(gcd)
            gcd.bg:SetTexture(cfg.texture)
            gcd.bg:SetVertexColor(class_color.r, class_color.g, class_color.b, 0.4)
			gcd.bd = framebd(gcd, gcd)	
			self.GCD = gcd
		end		
        
        -- Treat Bar
	    if cfg.treat.enable then
		    local treat = createStatusbar(UIParent, cfg.texture, nil, cfg.treat.height, cfg.treat.width, 1, 1, 1, 1)
			treat:SetFrameStrata('LOW')
	        treat:SetPoint(unpack(cfg.treat.pos))
			treat.useRawThreat = false
			treat.usePlayerTarget = false	
			treat.bg = treat:CreateTexture(nil, 'BACKGROUND')
            treat.bg:SetAllPoints(treat)
            treat.bg:SetTexture(cfg.texture)
            treat.bg:SetVertexColor(1, 1, 1, 0.3)
			if cfg.treat.text then
				treat.Title = fs(treat, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 0.8, 0.8, 0.8)
				treat.Title:SetText('Threat:')
				treat.Title:SetPoint('RIGHT', treat, 'CENTER')
				treat.Text = fs(treat, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 0.8, 0.8, 0.8)
				treat.Text:SetPoint('LEFT', treat, 'CENTER')
			end
	        treat.bg = framebd(treat, treat)
			self.ThreatBar = treat
		end

        -- EXP Bar
        local Experience = CreateFrame('StatusBar', nil, self)
		Experience:SetPoint('TOP', UIParent, 'TOP',0, -5)
		Experience:SetSize(300, 8)
		Experience:SetStatusBarTexture(cfg.texture)
		Experience.framebd = framebd(Experience, Experience)

		local Rested = CreateFrame('StatusBar', nil, Experience)
		Rested:SetAllPoints()
		Rested:SetStatusBarTexture(cfg.texture)
		Rested:SetAlpha(0.7)
		Rested:SetBackdrop(backdrop)
		Rested:SetBackdropColor(0, 0, 0)

		local ExperienceLv = fs(Experience, 'OVERLAY', cfg.font, 11, cfg.fontflag, 1, 1, 1)
		ExperienceLv:SetPoint('RIGHT', Experience, 'LEFT', -1, 0)        
        ExperienceLv:SetJustifyH('CENTER')
        self:Tag(ExperienceLv, 'Lv [level]')

		local ExperienceInfo = fs(Experience, 'OVERLAY', cfg.font, 9, cfg.fontflag, 1, 1, 1)
		ExperienceInfo:SetPoint('CENTER', Experience, 'CENTER', 0, 0)        
        ExperienceInfo:SetJustifyH('CENTER')
        self:Tag(ExperienceInfo, '[perxp]% / TNL : [tnlxp] (Rest : [perrested]%)')

		local ExperienceBG = Rested:CreateTexture(nil, 'BORDER')
		ExperienceBG:SetAllPoints()
		ExperienceBG:SetColorTexture(1/3, 1/3, 1/3)

        self.Experience = Experience
		self.Experience.Rested = Rested

		--if cfg.aura.target_buffs then
			local personalBuff = CreateFrame('Frame', nil, self)
			personalBuff.size = 43
			personalBuff.spacing = 4
		    personalBuff.num = 6
            personalBuff:SetSize((personalBuff.size+personalBuff.spacing)*personalBuff.num-personalBuff.spacing, personalBuff.size)
            -- personalBuff:SetPoint('CENTER', UIParent, 'CENTER', -118, 23)
		    personalBuff:SetPoint('CENTER', UIParent, 'CENTER', -150, 0)
            personalBuff.initialAnchor = 'CENTER'            
            personalBuff['growth-x'] = 'LEFT' 
            personalBuff['growth-y'] = 'DOWN'
            personalBuff.PostCreateIcon = auraIcon
            personalBuff.PostUpdateIcon = PostUpdateIcon
            personalBuff.CustomFilter = CustomAuraFilters.personal            
            --personalBuff.CustomFilter = ns.DefensiveCustomFilter
            self.Auras = personalBuff
		--end
            local activityBuff = CreateFrame('Frame', nil, self)
			activityBuff.size = 32
			activityBuff.spacing = 4
		    activityBuff.num = 7
            activityBuff:SetSize((activityBuff.size+activityBuff.spacing)*activityBuff.num-activityBuff.spacing, activityBuff.size)
		    activityBuff:SetPoint('BOTTOM', personalBuff, 'TOP', 0, 8)
            activityBuff.initialAnchor = 'CENTER'
            activityBuff['growth-x'] = 'LEFT'
            activityBuff['growth-y'] = 'UP'
            activityBuff.PostCreateIcon = auraIcon
            activityBuff.PostUpdateIcon = PostUpdateIcon
            activityBuff.CustomFilter = CustomAuraFilters.activity
            --activityBuff.CustomFilter = ns.OffensiveCustomFilter
            self.Buffs = activityBuff
    end,

    target = function(self, ...)
		Shared(self, ...)

		self.unit = 'target'
		
		Power(self)
		AuraTracker(self)
		ph(self)

		self.framebd = framebd(self, self)
		self.DebuffHighlight = cfg.dh.target

		if cfg.target_cb.enable then castbar(self) end
		if cfg.options.healcomm then Healcomm(self) end

		self:SetSize(cfg.target.width, cfg.target.health+cfg.target.power+1)
		self.Health:SetHeight(cfg.target.health)
	    self.Power:SetHeight(cfg.target.power)

	    local name = fs(self.Health, 'OVERLAY', cfg.krfont, 11, cfg.krfontflag, 1, 1, 1)
        name:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', 4, 0)        
        name:SetJustifyH('LEFT')
		self:Tag(name, '[unit:lv] [color][name]')
        local htext = fs(self.Health, 'OVERLAY', cfg.font, 15, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('TOPLEFT', 1, -1)
        htext:SetJustifyH('LEFT')
        self:Tag(htext, '[unit:HPpercent]')
        local htextsub = fs(self.Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htextsub:SetPoint('BOTTOMRIGHT', 1, 1)
        htextsub:SetJustifyH('RIGHT')
        self:Tag(htextsub, '[unit:HPstring]')

        self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self, "LEFT", 0, 0)

		if cfg.aura.target_buffs then
            local b = CreateFrame('Frame', nil, self)
			b.size = 16
			b.spacing = 3
		    b.num = 8
            b:SetSize(cfg.target.width, b.size)
		    b:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -5)
            b.initialAnchor = 'BOTTOMLEFT' 
            b['growth-y'] = 'DOWN'
            b.PostCreateIcon = auraIcon
            b.PostUpdateIcon = PostUpdateIcon
            self.Buffs = b
		end
		
        if cfg.aura.target_debuffs then
            local d = CreateFrame('Frame', nil, self)
			d.size = 28
			d.spacing = 5
		    d.num = 4
            d:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 5, 0)
			d:SetSize(d.size*d.num+d.spacing*(d.num/2-1), d.size)
            d.initialAnchor = 'BOTTOMLEFT'
            d.onlyShowPlayer = cfg.aura.onlyShowPlayer
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            d.CustomFilter = CustomFilter
            self.Debuffs = d       
        end
    end,

    focus = function(self, ...)
		Shared(self, ...)

		self.unit = 'focus'
		
		Power(self)
		ph(self)

		self.framebd = framebd(self, self)
		self.DebuffHighlight = cfg.dh.focus

		if cfg.focus_cb.enable then castbar(self) end
		if cfg.options.healcomm then Healcomm(self) end

		self:SetSize(cfg.focus.width, cfg.focus.health+cfg.focus.power+1)
		self.Health:SetHeight(cfg.focus.health)
		self.Power:SetHeight(cfg.focus.power)
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, cfg.krfontflag, 1, 1, 1)
        name:SetPoint('TOPLEFT', -1, 12)
        name:SetJustifyH('LEFT')
		self:Tag(name, '[unit:name10]')
		local htext = fs(self.Health, 'OVERLAY', cfg.font, 15, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('LEFT', 1, 0)
        htext:SetJustifyH('LEFT')
        self:Tag(htext, '[unit:HPpercent]')

        self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("RIGHT", self, "LEFT", -3, 0)
    end,

    pet = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(cfg.player.width, 3)
		self.framebd = framebd(self, self)

		self.Health.colorClass = false
    	self.Health.colorReaction = false
		self.Health.colorHealth = true
		self.Health.colorSmooth = true
    end,

	targettarget = function(self, ...)
	    Shared(self, ...)

	    self.unit = 'targettarget'
		
		self.framebd = framebd(self, self)		
		self.DebuffHighlight = cfg.dh.targettarget

		self:SetSize(cfg.ttarget.width, cfg.ttarget.height)
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, 'none', 1, 1, 1)
        name:SetPoint('LEFT', 2, 0)
        name:SetJustifyH('LEFT')
		name:SetShadowOffset(1, -1)
		self:Tag(name, '[unit:name8]')
		local htext = fs(self.Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('RIGHT', self.Health, 'RIGHT', 1, 0)
        htext:SetJustifyH('RIGHT')
        self:Tag(htext, '[color][unit:HPpercent]')
    end,
	
	party = function(self, ...)
		Shared(self, ...)		

		self.unit = 'party'
		self:SetAttribute("type3", "focus")
		
		Power(self)
		AuraTracker(self)
		--createAuraWatch(self)
		ph(self)
		
		self.framebd = framebd(self, self)	
		self.DebuffHighlight = cfg.dh.party
		
		if cfg.options.healcomm then Healcomm(self) end

		self:SetSize(cfg.target.width, cfg.target.health+cfg.target.power+1)
		self.Health:SetHeight(cfg.target.health)
		self.Health:SetReverseFill(true)
		self.Power:SetHeight(cfg.target.power)
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, 'none', 1, 1, 1)
		name:SetPoint('TOPLEFT', 1, 0)
	    name:SetJustifyH('LEFT')
	    name:SetShadowOffset(1, -1)
		self:Tag(name, '[unit:name10]')
        local htext = fs(self.Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('BOTTOMRIGHT', 2, 0)
		htext:SetJustifyH('RIGHT')
        self:Tag(htext, '[unit:HPcombo]')

        self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetSize(11, 11)
		self.Leader:SetPoint("CENTER", self, "TOPLEFT", 4, 5)
		self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetSize(11, 11)
		self.Assistant:SetPoint("CENTER", self, "TOPLEFT", 4, 5)
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self, "LEFT", 0, 0)
		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetSize(10, 10)
		self.LFDRole:SetPoint("CENTER", self, "TOPRIGHT", -6, -6)
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetSize(32, 32)
		self.ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)		
		
		if cfg.aura.party_buffs then			
            local d = CreateFrame('Frame', nil, self)
			d.size = 26
			d.spacing = 5
			d.num = cfg.aura.party_buffs_num
            d:SetSize(d.num*d.size+d.spacing*(d.num-1), d.size)
            d:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 5, 0)
            d.initialAnchor = 'BOTTOMLEFT'
			d['growth-x'] = 'RIGHT'
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            self.Debuffs = d
	    end

	    local tborder = CreateFrame('Frame', nil, self)
        tborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        tborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        tborder:SetBackdrop(backdrop)
        tborder:SetBackdropColor(.8, .8, .8, 1)
        tborder:SetFrameLevel(1)
        tborder:Hide()
        self.TargetBorder = tborder
		
		local fborder = CreateFrame('Frame', nil, self)
        fborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        fborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        fborder:SetBackdrop(backdrop)
        fborder:SetBackdropColor(.6, .8, 0, 1)
        fborder:SetFrameLevel(1)
        fborder:Hide()
        self.FocusHighlight = fborder
	    
		self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
		self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    end,

    partypet = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(3, cfg.target.health+cfg.target.power+1)
		self.framebd = framebd(self, self)

		self.Health:SetOrientation("VERTICAL")
		self.Health.colorClass = false
    	self.Health.colorReaction = false
		self.Health.colorHealth = true
		self.Health.colorSmooth = true
    end,

    raid = function(self, ...)
		Shared(self, ...)

		self.unit = 'raid'
		self:SetAttribute("type2", "focus")
		
		Power(self)
		AuraTracker(self)
		--createAuraWatch(self)
		ph(self)
		
		self.framebd = framebd(self, self)
		self.DebuffHighlight = cfg.dh.raid

		self:SetSize(cfg.raid.width, cfg.raid.health+cfg.raid.power+1)	
		self.Health:SetHeight(cfg.raid.health)
		self.Health:SetOrientation("VERTICAL")
		self.Power:SetHeight(cfg.raid.power)
		
		if cfg.options.healcomm then Healcomm(self) end
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, 'none', 1, 1, 1)
		name:SetPoint('TOPLEFT', 1, 0)		
		name:SetShadowOffset(1, -1)
	    name:SetJustifyH('LEFT')
		self:Tag(name, '[unit:name4]')
        local htext = fs(self.Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('BOTTOMRIGHT', 2, 0)
		htext:SetJustifyH('RIGHT')
        self:Tag(htext, '[unit:HPpercent]')

        self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetSize(11, 11)
		self.Leader:SetPoint("CENTER", self, "TOPLEFT", 4, 5)
		self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetSize(11, 11)
		self.Assistant:SetPoint("CENTER", self, "TOPLEFT", 4, 5)
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self, "LEFT", 0, 0)
		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetSize(10, 10)
		self.LFDRole:SetPoint("CENTER", self, "TOPRIGHT", -6, -6)
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetSize(32, 32)
		self.ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)
		
		if cfg.options.ResurrectIcon then
			local r = CreateFrame('Frame', nil, self)
			r:SetSize(20, 20)
			r:SetPoint('CENTER')
			r:SetFrameStrata'HIGH'
			r:SetBackdrop(backdrop)
			r:SetBackdropColor(.2, .6, 1)
			r.icon = r:CreateTexture(nil, 'OVERLAY')
			r.icon:SetTexture[[Interface\Icons\Spell_Holy_Resurrection]]
			r.icon:SetTexCoord(.1, .9, .1, .9)
			r.icon:SetAllPoints(r)
			self.ResurrectIcon	= r
		end
		
	    if cfg.RaidDebuffs.enable then
	       local d = CreateFrame('Frame', nil, self)
	       d:SetSize(cfg.RaidDebuffs.size, cfg.RaidDebuffs.size)
	       d:SetPoint(unpack(cfg.RaidDebuffs.pos))
	       d:SetFrameStrata'HIGH'
	       d:SetBackdrop(backdrop)
	       d.icon = d:CreateTexture(nil, 'OVERLAY')
	       d.icon:SetTexCoord(.1,.9,.1,.9)
	       d.icon:SetAllPoints(d)
	       d.time = fs(d, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 0.8, 0.8, 0.8)
	       d.time:SetPoint('TOPLEFT', d, 'TOPLEFT', 0, 0)
		   d.count = fs(d, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 0.8, 0.8, 0.8)
	       d.count:SetPoint('BOTTOMRIGHT', d, 'BOTTOMRIGHT', 2, 0)
		   self.RaidDebuffs = d
	    end

		local tborder = CreateFrame('Frame', nil, self)
        tborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        tborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        tborder:SetBackdrop(backdrop)
        tborder:SetBackdropColor(.8, .8, .8, 1)
        tborder:SetFrameLevel(1)
        tborder:Hide()
        self.TargetBorder = tborder
		
		local fborder = CreateFrame('Frame', nil, self)
        fborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        fborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        fborder:SetBackdrop(backdrop)
        fborder:SetBackdropColor(.6, .8, 0, 1)
        fborder:SetFrameLevel(1)
        fborder:Hide()
        self.FocusHighlight = fborder
	    
		self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
		self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    end,

	boss = function(self, ...)
		Shared(self, ...)

		self.unit = 'boss'
		
		Power(self)
		ph(self) 

		self.framebd = framebd(self, self)

		if cfg.boss_cb.enable then castbar(self) end

		self:SetSize(cfg.focus.width, cfg.focus.health+cfg.focus.power+1)	
		self.Health:SetHeight(cfg.focus.health)
		self.Health.frequentUpdates = true
	    self.Power:SetHeight(cfg.focus.power)
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, cfg.krfontflag, 1, 1, 1)
        name:SetPoint('TOPLEFT', -1, 12)
        name:SetJustifyH('LEFT')
		self:Tag(name, '[color][unit:name10]')
		local htext = fs(self.Health, 'OVERLAY', cfg.font, 15, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('LEFT', 1, 0)
        name:SetJustifyH('LEFT')
        self:Tag(htext, '[unit:HPcombo]')

        self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(14, 14)
		self.RaidIcon:SetPoint("CENTER", self, "LEFT", 0, 0)
		
	    --[[
	    local altp = createStatusbar(self, cfg.texture, nil, cfg.AltPowerBar.boss.height, cfg.AltPowerBar.boss.width, 1, 1, 1, 1)
        altp:SetPoint(unpack(cfg.AltPowerBar.boss.pos))
		altp.bd = framebd(altp, altp) 
        altp.bg = altp:CreateTexture(nil, 'BORDER')
        altp.bg:SetAllPoints(altp)
        altp.bg:SetTexture(cfg.texture)
        altp.bg:SetVertexColor(1, 1, 1, 0.3)
        altp.Text = fs(altp, 'OVERLAY', cfg.aura.font, cfg.aura.fontsize, cfg.aura.fontflag, 1, 1, 1)
        altp.Text:SetPoint('CENTER')
        self:Tag(altp.Text, '[altpower]') 
		altp:EnableMouse(true)
		altp.colorTexture = true
        self.AltPowerBar = altp
        ]]
		
		if cfg.aura.boss_buffs then 
            local b = CreateFrame('Frame', nil, self)
			b.size = 21
			b.spacing = 4
			b.num = cfg.aura.boss_buffs_num
            b:SetSize(b.num*b.size+b.spacing*(b.num-1), b.size)	
			b:SetPoint('TOPRIGHT', self, 'TOPLEFT', -5, 0)
            b.initialAnchor = 'TOPRIGHT'
			b['growth-x'] = 'LEFT'
            b.PostCreateIcon = auraIcon
            b.PostUpdateIcon = PostUpdateIcon
            self.Buffs = b
		end
		
        if cfg.aura.boss_debuffs then
            local d = CreateFrame('Frame', nil, self)
			d.size = 21
			d.spacing = 4
			d.num = cfg.aura.boss_debuffs_num
			d:SetSize(d.num*d.size+d.spacing*(d.num-1), d.size)
            d:SetPoint('TOPLEFT', self, 'TOPRIGHT', 5, 0)
            d.initialAnchor = 'TOPLEFT'
			d.onlyShowPlayer = true
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            self.Debuffs = d			
        end
    end,
	
	arena = function(self, ...)
		Shared(self, ...)		

		self.unit = 'arena'
		self:SetAttribute("type2", "focus")
		
		Power(self)
		AuraTracker(self)
		ph(self)
		
		self.framebd = framebd(self, self)	
		--self.DebuffHighlight = cfg.dh.arena
		
		self:SetSize(cfg.target.width, cfg.target.health+cfg.target.power+1)
		self.Health:SetHeight(cfg.target.health)
		self.Power:SetHeight(cfg.target.power)

		if cfg.arena_cb.enable then castbar(self) end		
		if cfg.options.healcomm then Healcomm(self) end
		
		local name = fs(self.Health, 'OVERLAY', cfg.krfont, cfg.krfontsize, 'none', 1, 1, 1)
		name:SetPoint('TOPLEFT', 1, 0)
	    name:SetJustifyH('LEFT')
	    name:SetShadowOffset(1, -1)
		self:Tag(name, '[unit:name10]')
        local htext = fs(self.Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint('BOTTOMLEFT', -1, 0)
		htext:SetJustifyH('LEFT')
        self:Tag(htext, '[unit:HPcombo]')

		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self, "RIGHT", 0, 0)

		local t = CreateFrame('Frame', nil, self)
		t:SetSize(30, 30)
		t:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -6, 0)
		--t.framebd = framebd(t, t)	
		self.Trinket = t

		local tborder = CreateFrame('Frame', nil, self)
        tborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        tborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        tborder:SetBackdrop(backdrop)
        tborder:SetBackdropColor(.8, .8, .8, 1)
        tborder:SetFrameLevel(1)
        tborder:Hide()
        self.TargetBorder = tborder
		
		local fborder = CreateFrame('Frame', nil, self)
        fborder:SetPoint('TOPLEFT', self, 'TOPLEFT')
        fborder:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
        fborder:SetBackdrop(backdrop)
        fborder:SetBackdropColor(.6, .8, 0, 1)
        fborder:SetFrameLevel(1)
        fborder:Hide()
        self.FocusHighlight = fborder
	    
		self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
		self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    end,
}
UnitSpecific.focustarget = UnitSpecific.targettarget

oUF:RegisterStyle('KBJ', Shared)

for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle('KBJ - ' .. unit:gsub('^%l', string.upper), layout)
end

local spawnHelper = function(self, unit, ...)
    if(UnitSpecific[unit]) then
        self:SetActiveStyle('KBJ - ' .. unit:gsub('^%l', string.upper))
    elseif(UnitSpecific[unit:match('[^%d]+')]) then 
        self:SetActiveStyle('KBJ - ' .. unit:match('[^%d]+'):gsub('^%l', string.upper))
    else
        self:SetActiveStyle'KBJ'
    end
    local object = self:Spawn(unit)
    object:SetPoint(...)
    return object
end

oUF:Factory(function(self)
    spawnHelper(self, 'player', 'CENTER', UIParent, cfg.unit_positions.Player.x, cfg.unit_positions.Player.y)
    spawnHelper(self, 'target', 'LEFT', 'oUF_KBJPlayer', 'RIGHT', 10, 0)
    spawnHelper(self, 'targettarget', 'BOTTOM', 'oUF_KBJTarget', 'TOP', 0, 6)
    spawnHelper(self, 'focus', 'BOTTOM', 'oUF_KBJTarget', 'TOP', 0, 33)
    spawnHelper(self, 'focustarget', 'TOPLEFT', 'oUF_KBJFocus','TOPRIGHT', 6, 0)
    spawnHelper(self, 'pet', 'BOTTOM', 'oUF_KBJPlayer', 'TOP', 0, 3)

    if cfg.uf.boss then
	    for i = 1, MAX_BOSS_FRAMES do
            spawnHelper(self, 'boss' .. i, 'LEFT', cfg.unit_positions.Boss.a, 'RIGHT', cfg.unit_positions.Boss.x, cfg.unit_positions.Boss.y - (40 * i))
        end
    end

    if cfg.uf.party then
		self:SetActiveStyle'KBJ - Party'
	    local party = self:SpawnHeader('oUF_Party', nil, 'custom [group:party,nogroup:raid][@raid6,noexists,group:raid] show; hide',
		'showParty', true, 'showPlayer', true, 'showSolo', false, 'showRaid', false,
		'yOffset', -12,
		'oUF-initialConfigFunction', ([[
		self:SetHeight(%d)
		self:SetWidth(%d)
		]]):format(cfg.target.health+cfg.target.power+1,cfg.target.width)
		)
	    party:SetPoint('TOP', UIParent, 'CENTER', cfg.unit_positions.Party.x, cfg.unit_positions.Party.y)

	    self:SetActiveStyle'KBJ - Partypet'
		local pets = self:SpawnHeader('oUF_PartyPets', nil, 'custom [group:party,nogroup:raid][@raid6,noexists,group:raid] show; hide',
		'showParty', true, 'showPlayer', true, 'showSolo', false, 'showRaid', false,
		'yOffset', -12,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'pet')
		]])
		)
		pets:SetPoint("TOPRIGHT", 'oUF_Party', "TOPLEFT", -4, 0)

		self:SetActiveStyle'KBJ - Targettarget'
		local partytargets = self:SpawnHeader('oUF_PartyTargets', nil, 'custom [group:party,nogroup:raid][@raid6,noexists,group:raid] show; hide',
		'showParty', true, 'showPlayer', true, 'showSolo', false, 'showRaid', false,
		'yOffset', -43,
		'oUF-initialConfigFunction', ([[
		self:SetAttribute('unitsuffix', 'target')
		self:SetHeight(%d)
		self:SetWidth(%d)
		]]):format(cfg.ttarget.height,cfg.ttarget.width)
		)
		partytargets:SetPoint('TOPLEFT', 'oUF_Party', 'TOPRIGHT', 5, 0)
    end
	
	if cfg.options.disableRaidFrameManager then
	    if IsAddOnLoaded('Blizzard_CompactRaidFrames') then
			CompactRaidFrameManager:SetParent(Hider)
			CompactUnitFrameProfiles:UnregisterAllEvents()
		end
	end

	if cfg.uf.raid then
		self:SetActiveStyle'KBJ - Raid'
		local raid = oUF:SpawnHeader('oUF_Raid', nil, 'raid10, raid25, raid40',
		'showParty', false, 'showPlayer', true, 'showSolo', false, 'showRaid', true,
		'xoffset', 5,
		'yOffset', -12,
		'point', 'TOP',
		'groupFilter', '1,2,3,4,5,6,7,8',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'groupBy', 'GROUP',
		'maxColumns', 8,
		'unitsPerColumn', 5,
		'columnSpacing', 5,
		'columnAnchorPoint', 'LEFT',
		'oUF-initialConfigFunction', ([[
			self:SetHeight(%d)
			self:SetWidth(%d)
		]]):format(cfg.raid.health+cfg.raid.power+1, cfg.raid.width)
		)
		raid:SetPoint('TOPLEFT', cfg.unit_positions.Raid.a, 'TOPLEFT', cfg.unit_positions.Raid.x, cfg.unit_positions.Raid.y)
	end

	if cfg.uf.tank then
	    self:SetActiveStyle'KBJ - Focus'
	    local maintank = self:SpawnHeader('oUF_MainTank', nil, 'raid',
		'showRaid', true,'showSolo',false, 'groupFilter', 'MAINTANK', 'yOffset', -23,
		'oUF-initialConfigFunction', ([[
			self:SetHeight(%d)
			self:SetWidth(%d)
		]]):format(cfg.target.health+cfg.target.power+1,cfg.target.width)
		)
	    maintank:SetPoint('RIGHT', cfg.unit_positions.Tank.a, 'LEFT', cfg.unit_positions.Tank.x, cfg.unit_positions.Tank.y)
		
		if cfg.uf.tank_target then
		    self:SetActiveStyle'KBJ - Targettarget'
		    local maintanktarget = self:SpawnHeader('oUF_MainTankTargets', nil, 'raid',
		    'showRaid', true,'showSolo',false,'groupFilter','MAINTANK','yOffset', -27, 
		    'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'target')
			self:SetHeight(%d)
			self:SetWidth(%d)
			]]):format(cfg.ttarget.height,cfg.ttarget.width)
			)
		    maintanktarget:SetPoint('TOPLEFT', 'oUF_MainTank', 'TOPRIGHT', 5, 0)	
        end		
	end    
	
	if cfg.uf.arena then
		local arena = {}
		self:SetActiveStyle'KBJ - Arena'
		for i = 1, 5 do
			arena[i] = self:Spawn('arena'..i, 'oUF_Arena'..i)
			if i == 1 then
				arena[i]:SetPoint('TOP', UIParent, 'CENTER',cfg.unit_positions.Arena.x, cfg.unit_positions.Arena.y)
			else
				arena[i]:SetPoint('TOP', arena[i-1], 'BOTTOM', 0, -12)
			end
		end
		local arenapet = {}
		self:SetActiveStyle'KBJ - Pet'
		for i = 1, 5 do
			arenapet[i] = self:Spawn("arena"..i.."pet", "oUF_Arena"..i.."pet")
			arenapet[i]:SetPoint("BOTTOMLEFT", arena[i], "TOPLEFT", 0, 3)
		end
        local arenatarget = {}	
		self:SetActiveStyle'KBJ - Targettarget'
		for i = 1, 5 do
			arenatarget[i] = self:Spawn('arena'..i..'target', 'oUF_Arena'..i..'target')
			arenatarget[i]:SetPoint('TOPLEFT', arena[i], 'TOPRIGHT', 5, 0)
		end
		
		local arenaprep = {}
		local arenaprepspec = {}
	    for i = 1, 5 do
		    arenaprep[i] = CreateFrame('Frame', 'oUF_ArenaPrep'..i, UIParent)
		    arenaprep[i]:SetSize(73, 44)
		    arenaprep[i]:SetPoint("TOPLEFT", arena[i], "TOPLEFT", 0, 0)
		    arenaprep[i]:SetFrameStrata('BACKGROUND')
			arenaprep[i].framebd = framebd(arenaprep[i], arenaprep[i])

			arenaprep[i].Health = CreateFrame('StatusBar', nil, arenaprep[i])
			arenaprep[i].Health:SetSize(73, 41)
			arenaprep[i].Health:SetPoint("TOP", arenaprep[i], "TOP", 0, 0)
			arenaprep[i].Health:SetStatusBarTexture(cfg.texture)
			arenaprep[i].Health:SetStatusBarColor(0, 0, 0)
			arenaprep[i].Power = CreateFrame('StatusBar', nil, arenaprep[i])
			arenaprep[i].Power:SetSize(73, 2)
			arenaprep[i].Power:SetPoint("TOP", arenaprep[i].Health, "BOTTOM", 0, -1)
			arenaprep[i].Power:SetStatusBarTexture(cfg.texture)
			arenaprep[i].Power:SetStatusBarColor(0, 0, 0)

		    arenaprep[i].Spec = fs(arenaprep[i].Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		    arenaprep[i].Spec:SetPoint('CENTER')
			arenaprep[i].Spec:SetJustifyH'CENTER'
			arenaprep[i].SpecIcon = CreateFrame('Frame', nil, arenaprep[i])
			arenaprep[i].SpecIcon:SetSize(30,30)
			arenaprep[i].SpecIcon:SetPoint("TOPRIGHT", arena[i], "LEFT", -6, 8)
			arenaprep[i].SpecIcon.framebd = framebd(arenaprep[i].SpecIcon, arenaprep[i].SpecIcon)
			arenaprep[i].SpecIcon.i = arenaprep[i].SpecIcon.framebd:CreateTexture(nil, 'OVERLAY')
			arenaprep[i].SpecIcon.i:SetSize(32, 32)
			arenaprep[i].SpecIcon.i:SetPoint("TOPRIGHT", arena[i], "LEFT", -5, 9)
			--arenaprep[i].SpecIcon.i:SetTexture([[INTERFACE\AddOns\oUF_KBJ\Media\Mage.tga]]) -- debug		

		    arenaprep[i]:Hide()
	    end

	    local arenaprepupdate = CreateFrame('Frame')
	    arenaprepupdate:RegisterEvent('PLAYER_LOGIN')
	    arenaprepupdate:RegisterEvent('PLAYER_ENTERING_WORLD')
	    arenaprepupdate:RegisterEvent('ARENA_OPPONENT_UPDATE')
	    arenaprepupdate:RegisterEvent('ARENA_PREP_OPPONENT_SPECIALIZATIONS')
	    arenaprepupdate:SetScript('OnEvent', function(self, event)
		    if event == 'PLAYER_LOGIN' then
			    for i = 1, 5 do
				    arenaprep[i]:SetAllPoints(_G['oUF_Arena'..i])
			    end
			--[[ Used Trick
		    elseif event == 'ARENA_OPPONENT_UPDATE' then
			    for i = 1, 5 do
				    arenaprep[i]:Hide()
			    end
			]]
		    else
			    local numOpps = GetNumArenaOpponentSpecs()

			    if numOpps > 0 then
				    for i = 1, 5 do
					    local f = arenaprep[i]

					    if i <= numOpps then
						    local s = GetArenaOpponentSpec(i)
						    local _, spec, class, texture = nil, 'UNKNOWN', 'UNKNOWN', nil

						    if s and s > 0 then
							    _, spec, _, texture, _, _, class = GetSpecializationInfoByID(s)
						    end

						    if class and spec then
						    	local class_color = RAID_CLASS_COLORS[class]
								f.Health:SetStatusBarColor(class_color.r, class_color.g, class_color.b)							
								f.Power:SetStatusBarColor(class_color.r, class_color.g, class_color.b)
							    f.Spec:SetText(spec)
							    f.SpecIcon.i:SetTexture(texture or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
							    f:Show()
						    end
					    else
						    f:Hide()
					    end
				    end
			    else
				    for i = 1, 5 do
					    arenaprep[i]:Hide()
				    end
			    end
		    end
	    end)
	end
end)

----------------------------------------------------------------------------------------
--	Test UnitFrames(by community)
----------------------------------------------------------------------------------------
-- For testing /run oUFAbu.TestArena()
function TUF()
	oUF_Arena1:Show(); oUF_Arena1.Hide = function() end oUF_Arena1.unit = "target"
	oUF_Arena2:Show(); oUF_Arena2.Hide = function() end oUF_Arena2.unit = "target"
	oUF_Arena3:Show(); oUF_Arena3.Hide = function() end oUF_Arena3.unit = "target"
	oUF_Arena4:Show(); oUF_Arena4.Hide = function() end oUF_Arena4.unit = "target"
	oUF_Arena5:Show(); oUF_Arena5.Hide = function() end oUF_Arena5.unit = "target"
	oUF_Arena1target:Show(); oUF_Arena1target.Hide = function() end oUF_Arena1target.unit = "target"
	oUF_Arena2target:Show(); oUF_Arena2target.Hide = function() end oUF_Arena2target.unit = "target"
	oUF_Arena3target:Show(); oUF_Arena3target.Hide = function() end oUF_Arena3target.unit = "target"
	oUF_Arena4target:Show(); oUF_Arena4target.Hide = function() end oUF_Arena4target.unit = "target"
	oUF_Arena5target:Show(); oUF_Arena5target.Hide = function() end oUF_Arena5target.unit = "target"
	oUF_Arena1pet:Show(); oUF_Arena1pet.Hide = function() end oUF_Arena1pet.unit = "target"
	oUF_Arena2pet:Show(); oUF_Arena2pet.Hide = function() end oUF_Arena2pet.unit = "target"
	oUF_Arena3pet:Show(); oUF_Arena3pet.Hide = function() end oUF_Arena3pet.unit = "target"
	oUF_Arena4pet:Show(); oUF_Arena4pet.Hide = function() end oUF_Arena4pet.unit = "target"
	oUF_Arena5pet:Show(); oUF_Arena5pet.Hide = function() end oUF_Arena5pet.unit = "target"
	oUF_ArenaPrep1:Show(); oUF_ArenaPrep1.Hide = function() end oUF_ArenaPrep1.unit = "target"
	oUF_ArenaPrep2:Show(); oUF_ArenaPrep2.Hide = function() end oUF_ArenaPrep2.unit = "target"	
	oUF_ArenaPrep3:Show(); oUF_ArenaPrep3.Hide = function() end oUF_ArenaPrep3.unit = "target"
	oUF_ArenaPrep4:Show(); oUF_ArenaPrep4.Hide = function() end oUF_ArenaPrep4.unit = "target"
	oUF_ArenaPrep5:Show(); oUF_ArenaPrep5.Hide = function() end oUF_ArenaPrep5.unit = "target"

	local time = 0
	local f = CreateFrame("Frame")
	f:SetScript("OnUpdate", function(self, elapsed)
		time = time + elapsed
		if time > 5 then
			oUF_Arena1:UpdateAllElements("ForceUpdate")
			oUF_Arena2:UpdateAllElements("ForceUpdate")
			oUF_Arena3:UpdateAllElements("ForceUpdate")
			oUF_Arena4:UpdateAllElements("ForceUpdate")
			oUF_Arena5:UpdateAllElements("ForceUpdate")
			time = 0
		end
	end)
end