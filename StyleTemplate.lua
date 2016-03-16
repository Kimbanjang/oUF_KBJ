--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = ns.cfg

local fontGeneral = STANDARD_TEXT_FONT
local fontThick = [[Interface\AddOns\oUF_KBJ\Media\fontThick.ttf]]

local barTexture = [[Interface\AddOns\oUF_KBJ\Media\texture]]
local edgeTexture = [[Interface\AddOns\oUF_KBJ\Media\glowTex]]

local playerClass = select(2, UnitClass('player'))

local Loader = CreateFrame('Frame')
Loader:RegisterEvent('ADDON_LOADED')
Loader:SetScript('OnEvent', function(self, event, addon)
	if addon ~= 'oUF_KBJ' then return end

	oUFKBJAura = oUFKBJAura or {}
	UpdateAuraList()
end)


--------------------------------------
-- Function
--------------------------------------

-- Castbar
framebd = function(parent, anchor) 
	local frame = CreateFrame('Frame', nil, parent)
	frame:SetFrameStrata('BACKGROUND')
	frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
	frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)
	frame:SetBackdrop({
	edgeFile = edgeTexture, edgeSize = 3,
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	frame:SetBackdropColor(0, 0, 0)
	frame:SetBackdropBorderColor(0, 0, 0)
	return frame
end

local fixStatusbar = function(bar)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:GetStatusBarTexture():SetVertTile(false)
end
createStatusbar = function(parent, tex, layer, height, width, r, g, b, alpha)
	local bar = CreateFrame'StatusBar'
	bar:SetParent(parent)
	if height then
		bar:SetHeight(height)
	end
	if width then
		bar:SetWidth(width)
	end
	bar:SetStatusBarTexture(tex, layer)
	bar:SetStatusBarColor(r, g, b, alpha)
	fixStatusbar(bar)
	return bar
end

fs = function(parent, layer, font, fontsiz, outline, r, g, b, justify)
	local string = parent:CreateFontString(nil, layer)
	string:SetFont(font, fontsiz, outline)
	string:SetShadowOffset(0, 0)
	string:SetTextColor(r, g, b)
	if justify then
		string:SetJustifyH(justify)
	end
	return string
end

local channelingTicks = {
	-- Druid
	[GetSpellInfo(740)] = 4,	-- Tranquility
	[GetSpellInfo(16914)] = 10,	-- Hurricane
	[GetSpellInfo(106996)] = 10,	-- Astral Storm
	-- Mage
	[GetSpellInfo(5143)] = 5,	-- Arcane Missiles
	[GetSpellInfo(10)] = 8,		-- Blizzard
	[GetSpellInfo(12051)] = 4,	-- Evocation
	-- Monk
	[GetSpellInfo(115175)] = 9,	-- Soothing Mist
	-- Priest
	[GetSpellInfo(15407)] = 3,	-- Mind Flay
	[GetSpellInfo(48045)] = 5,	-- Mind Sear
	[GetSpellInfo(47540)] = 2,	-- Penance
	--[GetSpellInfo(64901)] = 4,	-- Hymn of Hope
	[GetSpellInfo(64843)] = 4,	-- Divine Hymn
	-- Warlock
	[GetSpellInfo(689)] = 6,	-- Drain Life
	[GetSpellInfo(108371)] = 6,	-- Harvest Life
	[GetSpellInfo(103103)] = 3,	-- Drain Soul
	[GetSpellInfo(755)] = 6,	-- Health Funnel
	[GetSpellInfo(1949)] = 15,	-- Hellfire
	[GetSpellInfo(5740)] = 4,	-- Rain of Fire
	[GetSpellInfo(103103)] = 3,	-- Malefic Grasp
}

local ticks = {}

local setBarTicks = function(castBar, ticknum)
	if ticknum and ticknum > 0 then
		local delta = castBar:GetWidth() / ticknum
		for k = 1, ticknum do
			if not ticks[k] then
				ticks[k] = castBar:CreateTexture(nil, 'OVERLAY')
				ticks[k]:SetTexture(barTexture)
				ticks[k]:SetVertexColor(0.6, 0.6, 0.6)
				ticks[k]:SetWidth(1)
				ticks[k]:SetHeight(21)
			end
			ticks[k]:ClearAllPoints()
			ticks[k]:SetPoint('CENTER', castBar, 'LEFT', delta * k, 0 )
			ticks[k]:Show()
		end
	else
		for k, v in pairs(ticks) do
			v:Hide()
		end
	end
end

local OnCastbarUpdate = function(self, elapsed)
	local currentTime = GetTime()
	if self.casting or self.channeling then
		local parent = self:GetParent()
		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end
		if parent.unit == 'player' then
			if self.delay ~= 0 then
				self.Time:SetFormattedText('%.1f | %.1f |cffff0000|%.1f|r', duration, self.max, self.delay )
			elseif self.Lag then
				if self.SafeZone.timeDiff >= (self.max*.5) or self.SafeZone.timeDiff == 0 then
					self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
					self.Lag:SetFormattedText('')
				else
					self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
					self.Lag:SetFormattedText('%d ms', self.SafeZone.timeDiff * 1000)
				end
			else
				self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
			end
		else
			self.Time:SetFormattedText('%.1f | %.1f', duration, self.casting and self.max + self.delay or self.max - self.delay)
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
	elseif self.fadeOut then
		self.Spark:Hide()
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

local PostCastStart = function(self, unit)
	self:SetAlpha(1.0)
	self.Spark:Show()
	self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
	if self.casting then
		self.cast = true
	else
		self.cast = false
	end
	if unit == 'vehicle' then
		self.SafeZone:Hide()
		self.Lag:Hide()
	elseif unit == 'player' then
		local sf = self.SafeZone
		if not sf then return end
		if not sf.sendTime then sf.sendTime = GetTime() end
		sf.timeDiff = GetTime() - sf.sendTime
		sf.timeDiff = sf.timeDiff > self.max and self.max or sf.timeDiff
		if sf.timeDiff >= (self.max*.5) or sf.timeDiff == 0 then
			sf:SetWidth(0.01)
		else
			sf:SetWidth(self:GetWidth() * sf.timeDiff / self.max)
		end
		if not UnitInVehicle('player') then sf:Show() else sf:Hide() end
		if self.casting then
			setBarTicks(self, 0)
		else
			local spell = UnitChannelInfo(unit)
			self.channelingTicks = channelingTicks[spell] or 0
			setBarTicks(self, self.channelingTicks)
		end
	end
	if unit ~= 'player' and self.interrupt and UnitCanAttack('player', unit) then
		self:SetStatusBarColor(0, 0, 0)
	end
end

local PostCastStop = function(self, unit)
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(self.CompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.cast and self.max or 0)
	self:Show()
end

local PostCastFailed = function(self, event, unit)
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	if not self.fadeOut then
		self.fadeOut = true
	end
	self:Show()
end

local PostCastInterruptible = function(self, event, unit)
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	if not self.fadeOut then
		self.fadeOut = true
	end
	self:Show()
end

local castbar = function(self, unit)
	local cb = createStatusbar(self, barTexture, nil, nil, nil, 1, 1, 1, 1)		
	local cbbg = cb:CreateTexture(nil, 'BACKGROUND')
	cbbg:SetAllPoints(cb)
	cbbg:SetTexture(barTexture)
	cbbg:SetVertexColor(1, 1, 1, .2)
	if self.unit == 'arena' then
		cb.Time = fs(cb, 'OVERLAY', fontThick, 10, 'THINOUTLINE', 1, 1, 1)
		cb.Text = fs(cb, 'OVERLAY', fontThick, 10, 'THINOUTLINE', 1, 1, 1, 'LEFT')
	else
		cb.Time = fs(cb, 'OVERLAY', fontGeneral, 12, 'THINOUTLINE', 1, 1, 1)
		cb.Text = fs(cb, 'OVERLAY', fontGeneral, 12, 'THINOUTLINE', 1, 1, 1, 'LEFT')
	end
	cb.Time:SetPoint('RIGHT', cb, -2, 0)		
	cb.Text:SetPoint('LEFT', cb, 2, 0)
	cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
	cb.CastingColor = {1, 0.7, 0}
	cb.CompleteColor = {0.12, 0.86, 0.15}
	cb.FailColor = {1.0, 0.09, 0}
	cb.ChannelingColor = {0.65, 0.4, 0}
	cb.Icon = cb:CreateTexture(nil, 'ARTWORK')
	cb.Icon:SetPoint('TOPRIGHT', cb, 'TOPLEFT', -1, 0)
	cb.Icon:SetTexCoord(.1, .9, .1, .9)

	if self.unit == 'player' then
		cb:SetPoint("CENTER", UIParent, cfg.playerCastbarPosition_X, cfg.playerCastbarPosition_Y)
		cb:SetSize(cfg.playerCastbarPosition_Width, cfg.playerCastbarPosition_Height)
		cb.Icon:SetSize(cfg.playerCastbarPosition_Height, cfg.playerCastbarPosition_Height)
		cb.SafeZone = cb:CreateTexture(nil, 'ARTWORK')
		cb.SafeZone:SetTexture(barTexture)
		cb.SafeZone:SetVertexColor(.8,.11,.15, .7)
		cb.Lag = fs(cb, 'OVERLAY', fontGeneral, 10, 'THINOUTLINE', 1, 1, 1)
		cb.Lag:SetPoint('TOPRIGHT', 0, 12)
		cb.Lag:SetJustifyH('RIGHT')
		self:RegisterEvent('UNIT_SPELLCAST_SENT', function(_, _, caster)
			if (caster == 'player' or caster == 'vehicle') and self.Castbar.SafeZone then
				self.Castbar.SafeZone.sendTime = GetTime()
			end
		end, true)

		local gcd = createStatusbar(self, barTexture, nil, cfg.playerCastbarPosition_Height/6, cfg.playerCastbarPosition_Width, 0.5, 0.5, 0.5, 1)
		gcd:SetPoint("CENTER", UIParent, cfg.playerCastbarPosition_X, cfg.playerCastbarPosition_Y+cfg.playerCastbarPosition_Height/1.2)
		gcd.bg = gcd:CreateTexture(nil, 'BORDER')
		gcd.bg:SetAllPoints(gcd)
		gcd.bg:SetTexture(barTexture)
		gcd.bg:SetVertexColor(0.5, 0.5, 0.5, 0.4)
		gcd.bd = framebd(gcd, gcd)	
		self.GCD = gcd
	elseif self.unit == 'target' then
		cb:SetPoint("CENTER", UIParent, cfg.targetCastbarPosition_X, cfg.targetCastbarPosition_Y)
		cb:SetSize(cfg.targetCastbarPosition_Width, cfg.targetCastbarPosition_Height)
		cb.Icon:SetSize(cfg.targetCastbarPosition_Height, cfg.targetCastbarPosition_Height)
	elseif self.unit == 'focus' then
		cb:SetPoint("CENTER", UIParent, cfg.focusCastbarPosition_X, cfg.focusCastbarPosition_Y)
		cb:SetSize(cfg.focusCastbarPosition_Width, cfg.focusCastbarPosition_Height)
		cb.Icon:SetSize(cfg.focusCastbarPosition_Height, cfg.focusCastbarPosition_Height)
	elseif self.unit == 'arena' then
		cb:SetPoint("TOPRIGHT", self, "TOPLEFT", cfg.arenaCastbarPosition_X, cfg.arenaCastbarPosition_Y)
		cb:SetSize(cfg.arenaCastbarPosition_Width, cfg.arenaCastbarPosition_Height)
		cb.Icon:SetSize(cfg.arenaCastbarPosition_Height, cfg.arenaCastbarPosition_Height)
	end
	
	cb.Spark = cb:CreateTexture(nil,'OVERLAY')
	cb.Spark:SetTexture([=[Interface\Buttons\WHITE8x8]=])
	cb.Spark:SetBlendMode('Add')
	cb.Spark:SetHeight(cb:GetHeight())
	cb.Spark:SetWidth(1)
	cb.Spark:SetVertexColor(1, 1, 1)
	
	cb.OnUpdate = OnCastbarUpdate
	cb.PostCastStart = PostCastStart
	cb.PostChannelStart = PostCastStart
	cb.PostCastStop = PostCastStop
	cb.PostChannelStop = PostCastStop
	cb.PostCastFailed = PostCastFailed
	cb.PostCastInterrupted = PostCastFailed

	cb.bg = cbbg
	cb.Backdrop = framebd(cb, cb)
	cb.IBackdrop = framebd(cb, cb.Icon)
	self.Castbar = cb
end


--------------------------------------
-- STYLE TEMPLATE
--------------------------------------

local Shared = function(self, unit)
    	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	unit = unit:match('(boss)%d?$') or unit:match('(arena)%d?$') or unit
end

local HPPPBar = function(self, unit, setSizeX, setSizeY)
    	local HPPPBarFrame = CreateFrame('Frame', nil, self)
	HPPPBarFrame:SetSize(setSizeX,setSizeY)
	HPPPBarFrame:SetPoint("CENTER", self, "CENTER", 0, 0)
	HPPPBarFrame.framebd = framebd(HPPPBarFrame, HPPPBarFrame)
	self.Health = CreateFrame('StatusBar', nil, HPPPBarFrame)
	self.Health:SetSize(setSizeX,setSizeY-3)
	self.Health:SetPoint("TOP", HPPPBarFrame, "TOP", 0, 0)
	self.Health:SetStatusBarTexture(barTexture)
	self.Health.Smooth = true
	self.HealthBG = self.Health:CreateTexture(nil, 'BORDER')
	self.HealthBG:SetAllPoints()
	self.HealthBG:SetTexture(0.2, 0.2, 0.2)
	self.Power = CreateFrame('StatusBar', nil, HPPPBarFrame)
	self.Power:SetSize(setSizeX, 2)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -1)
	self.Power:SetStatusBarTexture(barTexture)
	self.Power.colorPower = true
	self.Power.colorDisconnected = true
	self.Power.Smooth = true
	self.PowerBG = self.Power:CreateTexture(nil, 'BORDER')
	self.PowerBG:SetAllPoints()
	self.PowerBG:SetTexture(0.1, 0.1, 0.1)
end

local HPBar = function(self, unit, setSizeX, setSizeY)
    	local HPBarFrame = CreateFrame('Frame', nil, self)
	HPBarFrame:SetSize(setSizeX,setSizeY)
	HPBarFrame:SetPoint("CENTER", self, "CENTER", 0, 0)
	HPBarFrame.framebd = framebd(HPBarFrame, HPBarFrame)
	self.Health = CreateFrame('StatusBar', nil, HPBarFrame)
	self.Health:SetSize(setSizeX,setSizeY)
	self.Health:SetPoint("TOP", HPBarFrame, "TOP", 0, 0)
	self.Health:SetStatusBarTexture(barTexture)
	self.Health.Smooth = true
	self.HealthBG = self.Health:CreateTexture(nil, 'BORDER')
	self.HealthBG:SetAllPoints()
	self.HealthBG:SetTexture(0.2, 0.2, 0.2)
end

local UnitSpecific = {
	player = function(self, ...)
		local barSizeX, barSizeY = 28, 44

		Shared(self, ...)
		self.unit = 'player'
		self:SetSize(barSizeX, barSizeY)

		if cfg.playerCastbar then castbar(self) end	

		HPPPBar(self, ..., barSizeX, barSizeY)		
		self.Health:SetOrientation("VERTICAL")
		self.Health.colorHealth = true
		self.Health.colorSmooth = true		

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 14, 'THINOUTLINE')
		HPcur:SetPoint("TOP", self.Health, "TOP", 0, 0)
		self:Tag(HPcur, "[unit:perhp]")
		local PPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		PPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		PPcur:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(PPcur, "[unit:power]")
		
		local Combat = self.Health:CreateTexture(nil, "OVERLAY")
		Combat:SetSize(16, 16)
		Combat:SetPoint("CENTER", self, "CENTER",0, 2)
		self.Combat = Combat
		self.Resting = self:CreateTexture(nil, "OVERLAY")
		self.Resting:SetSize(18, 18)
		self.Resting:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 3, 0)

		-- Class Resource
		---- Combo Point
		if (playerClass == "ROGUE" or playerClass == "DRUID") then
			local comboPoints = self:CreateFontString(nil, "OVERLAY")
			comboPoints:SetFont(fontThick, 28, 'THINOUTLINE')
			comboPoints:SetPoint("LEFT", UIParent, "CENTER", 30, 0)
			self:Tag(comboPoints, "[unit:cpoints]")
		---- Warlock Resource
		elseif (playerClass == "WARLOCK") then
			local warlockResource = self:CreateFontString(nil, "OVERLAY")
			warlockResource:SetFont(fontThick, 22, 'THINOUTLINE')
			warlockResource:SetPoint("LEFT", UIParent, "CENTER", 30, 0)
			self:Tag(warlockResource, "[unit:warlockresource]")
		---- Monk Chi
		elseif (playerClass == "MONK") then
			local monkChi = self:CreateFontString(nil, "OVERLAY")
			monkChi:SetFont(fontThick, 28, 'THINOUTLINE')
			monkChi:SetPoint("LEFT", UIParent, "CENTER", 30, 0)
			self:Tag(monkChi, "[unit:monkchi]")
		end
	end,

	target = function(self, ...)
		local barSizeX, barSizeY = 72, 44

		Shared(self, ...)
		self.unit = 'target'
		self:SetSize(barSizeX, barSizeY)
		self:SetAttribute("type3", "focus")

		if cfg.targetCastbar then castbar(self) end	

		HPPPBar(self, ..., barSizeX, barSizeY)
		self.Health.colorHealth = true
		self.Health.colorSmooth = true
	
		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 14, 'THINOUTLINE')
		HPcur:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, 0)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "TOPRIGHT", 5, -5)
		unitName:SetFont(fontThick, 11, 'THINOUTLINE')
		self:Tag(unitName, "[unit:level] [unit:colorname]")

		self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')

		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self, "LEFT", 0, 0)	

		local AuraTrackParty = CreateFrame('Frame', nil, self)
		AuraTrackParty:SetAlpha(0.9)
		AuraTrackParty:SetSize(30,30)
		AuraTrackParty:SetPoint("CENTER", self.Health, "CENTER", 0, 0)		
		AuraTrackParty:SetFrameStrata('HIGH')
		AuraTrackParty.icon = AuraTrackParty:CreateTexture(nil, 'ARTWORK')
		AuraTrackParty.icon:SetAllPoints(AuraTrackParty)
		self.AuraTracker = AuraTrackParty

		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(140, 31)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('TOPLEFT', self, 'RIGHT', 5, 7)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.CustomFilter = CustomAuraFilters.party
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 3
		Debuffs.onlyShowPlayer = false
		Debuffs.size = 31
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs

		local Buffs = CreateFrame('Frame', nil, self)
		Buffs:SetSize(73, 16)
		Buffs.PostCreateIcon = ns.PostCreateAura
		Buffs.PostUpdateIcon = ns.PostUpdateBuff
		Buffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -5)
		-- Buffs.disableCooldown : Do not display the cooldown spiral		
		-- Buffs.CustomFilter = CustomAuraFilters.party
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.num = 4
		Buffs.onlyShowPlayer = false
		Buffs.size = 16
		Buffs.spacing = 3
		-- Buffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Buffs['growth-y'] = 'DOWN'
		-- Buffs['spacing-x'] : horizontal space between each debuff button (takes priority over Buffs.spacing)
		-- Buffs['spacing-y'] : vertical space between each debuff button (takes priority over Buffs.spacing)
		self.Buffs = Buffs
	end,

	focus = function(self, ...)
		local barSizeX, barSizeY = 72, 12

		Shared(self, ...)
		self.unit = 'focus'
		self:SetSize(barSizeX, barSizeY)

		if cfg.focusCastbar then castbar(self) end
		
		HPBar(self, ..., barSizeX, barSizeY)		
		self.Health.colorReaction = true
		self.Health.colorClass = true
		self.Health.colorDisconnected = true		

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		HPcur:SetPoint("RIGHT", self.Health, "RIGHT", 1, 0)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "LEFT", 1, 0)
		unitName:SetFont(fontThick, 10)
		unitName:SetShadowOffset(1, -1)
		unitName:SetTextColor(1, 1, 1)
		self:Tag(unitName, "[unit:focusname]")
	end,

	pet = function(self, ...)
		local barSizeX, barSizeY = 3, 44

		Shared(self, ...)
		self.unit = 'pet'
		self:SetSize(barSizeX, barSizeY)

		HPBar(self, ..., barSizeX, barSizeY)
		self.Health:SetOrientation("VERTICAL")
		self.Health.colorHealth = true
		self.Health.colorSmooth = true	

		self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}			
	end,

	targettarget = function(self, ...)	
		local barSizeX, barSizeY = 72, 12

		self.unit = 'targettarget'
		self:SetSize(barSizeX, barSizeY)

		HPBar(self, ..., barSizeX, barSizeY)
		self.Health.colorReaction = true
		self.Health.colorClass = true
		self.Health.colorDisconnected = true

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		HPcur:SetPoint("RIGHT", self.Health, "RIGHT", 1, 0)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "LEFT", 1, 0)
		unitName:SetFont(fontThick, 10)
		unitName:SetShadowOffset(1, -1)
		unitName:SetTextColor(1, 1, 1)
		self:Tag(unitName, "[unit:focusname]")
	end,

	party = function(self, ...)	
		local barSizeX, barSizeY = 72, 44

		Shared(self, ...)
		self.unit = 'party'
		self:SetSize(barSizeX, barSizeY)
		self:SetAttribute("type3", "focus")

		HPPPBar(self, ..., barSizeX, barSizeY)
		self.Health.colorClass = true
		self.Health.colorDisconnected = true
		
		self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		HPcur:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 1, 1)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "TOPLEFT", 1, -5)
		unitName:SetFont(fontThick, 10)
		unitName:SetShadowOffset(1, -1)
		unitName:SetTextColor(1, 1, 1)
		self:Tag(unitName, "[unit:partyname]")

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
		self.LFDRole:SetPoint("CENTER", self, "TOPRIGHT", -5, -5)
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetSize(32, 32)
		self.ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)

		local AuraTrackParty = CreateFrame('Frame', nil, self)
		AuraTrackParty:SetAlpha(0.9)
		AuraTrackParty:SetSize(30,30)
		AuraTrackParty:SetPoint("CENTER", self.Health, "CENTER", 0, 0)		
		AuraTrackParty:SetFrameStrata('HIGH')
		AuraTrackParty.icon = AuraTrackParty:CreateTexture(nil, 'ARTWORK')
		AuraTrackParty.icon:SetAllPoints(AuraTrackParty)
		self.AuraTracker = AuraTrackParty

		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(100, 30)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('TOPLEFT', self, 'RIGHT', 5, 7)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.CustomFilter = CustomAuraFilters.party
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 3
		Debuffs.onlyShowPlayer = false
		Debuffs.size = 28
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs
--[[ debug
		local Buffs = CreateFrame('Frame', nil, self)
		Buffs:SetSize(100, 30)
		Buffs.PostCreateIcon = ns.PostCreateAura
		Buffs.PostUpdateIcon = ns.PostUpdateBuff
		Buffs:SetPoint('TOPLEFT', self, 'RIGHT', 5, 7)
		-- Buffs.disableCooldown : Do not display the cooldown spiral		
		-- Buffs.CustomFilter = CustomAuraFilters.party
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.num = 3
		Buffs.onlyShowPlayer = ture
		Buffs.size = 28
		Buffs.spacing = 4
		-- Buffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Buffs['growth-y'] = 'DOWN'
		-- Buffs['spacing-x'] : horizontal space between each debuff button (takes priority over Buffs.spacing)
		-- Buffs['spacing-y'] : vertical space between each debuff button (takes priority over Buffs.spacing)
		self.Buffs = Buffs
]]--

--[[ Test
		self.TargetBorder = self:CreateTexture(nil, 'OVERLAY', self)
	        self.TargetBorder:SetPoint('TOPRIGHT', self, 0, 3)
	        self.TargetBorder:SetPoint('BOTTOMLEFT', self, -0, -9)
	        -- self.TargetBorder:SetAllPoints(partyHpPer)
	        self.TargetBorder:SetTexture('Interface\\Addons\\oUF_KBJ\\Media\\borderTarget')
	        self.TargetBorder:SetVertexColor(0.7, 0.7, 0.7)
	        self.TargetBorder:Hide()
	 
	        self:RegisterEvent('PLAYER_TARGET_CHANGED', function()
	            if (UnitIsUnit('target', self.unit)) then
	                self.TargetBorder:Show()
	            else
	                self.TargetBorder:Hide()
	            end
	        end)
]]--
	end,

	raid  = function(self, ...)
		local barSizeX, barSizeY = 44, 44

		Shared(self, ...)
		self.unit = 'raid'
		self:SetSize(barSizeX, barSizeY)
		self:SetAttribute("type2", "focus")

		HPPPBar(self, ..., barSizeX, barSizeY)
		self.Health:SetOrientation("VERTICAL")
		self.Health.colorClass = true
		self.Health.colorDisconnected = true
		
		self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		HPcur:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 2, 1)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "TOPLEFT", 1, -5)
		unitName:SetFont(fontThick, 10)
		unitName:SetShadowOffset(1, -1)
		unitName:SetTextColor(1, 1, 1)
		self:Tag(unitName, "[unit:raidname]")

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
		self.LFDRole:SetPoint("CENTER", self, "TOPRIGHT", -5, -5)
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetSize(32, 32)
		self.ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)

		local AuraTrackRaid = CreateFrame('Frame', nil, self)
		AuraTrackRaid:SetAlpha(0.9)
		AuraTrackRaid:SetSize(30,30)
		AuraTrackRaid:SetPoint("CENTER", self.Health, "CENTER", 0, 0)		
		AuraTrackRaid:SetFrameStrata('HIGH')
		AuraTrackRaid.icon = AuraTrackRaid:CreateTexture(nil, 'ARTWORK')
		AuraTrackRaid.icon:SetAllPoints(AuraTrackRaid)
		self.AuraTracker = AuraTrackRaid
	end,

	arena = function(self, ...)
		Shared(self, ...)
		self.unit = 'arena'
		self:SetSize(72, 44)
		self:SetAttribute("type2", "focus")

		if cfg.arenaCastbar then castbar(self) end	

		local arenaFrame = CreateFrame('Frame', nil, self)
		arenaFrame:SetSize(72,44)
		arenaFrame:SetPoint("CENTER", self, "CENTER", 0, 0)
		self.Health = CreateFrame('StatusBar', nil, arenaFrame)
		self.Health:SetSize(72,41)
		self.Health:SetPoint("TOP", arenaFrame, "TOP", 0, 0)
		self.Health:SetStatusBarTexture(barTexture)
		self.Health.Smooth = true
		self.Health.colorClass = true
		self.Health.colorDisconnected = true
		self.HealthBG = self.Health:CreateTexture(nil, 'BORDER')
		self.HealthBG:SetAllPoints()
		self.HealthBG:SetTexture(0.2, 0.2, 0.2)
		self.Power = CreateFrame('StatusBar', nil, arenaFrame)
		self.Power:SetSize(72, 2)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -1)
		self.Power:SetStatusBarTexture(barTexture)
		self.Power.colorPower = true
		self.Power.colorDisconnected = true
		self.Power.Smooth = true
		self.PowerBG = self.Power:CreateTexture(nil, 'BORDER')
		self.PowerBG:SetAllPoints()
		self.PowerBG:SetTexture(0.1, 0.1, 0.1)
		
		self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}		

		local HPcur = self.Health:CreateFontString(nil, "OVERLAY")	
		HPcur:SetFont(fontThick, 10, 'THINOUTLINE')
		HPcur:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, 1)
		self:Tag(HPcur, "[unit:perhp]")
		local unitName = self.Health:CreateFontString(nil, "OVERLAY")
		unitName:SetPoint("LEFT", self.Health, "TOPLEFT", 0, -5)
		unitName:SetFont(fontThick, 10)
		unitName:SetShadowOffset(1, -1)
		unitName:SetTextColor(1, 1, 1)
		self:Tag(unitName, "[unit:partyname]")

		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetSize(16, 16)
		self.RaidIcon:SetPoint("CENTER", self.Health, "RIGHT", 0, 0)

		local AuraTrackParty = CreateFrame('Frame', nil, self)
		AuraTrackParty:SetAlpha(0.9)
		AuraTrackParty:SetSize(30,30)
		AuraTrackParty:SetPoint("CENTER", self.Health, "CENTER", 0, 0)		
		AuraTrackParty:SetFrameStrata('HIGH')
		AuraTrackParty.icon = AuraTrackParty:CreateTexture(nil, 'ARTWORK')
		AuraTrackParty.icon:SetAllPoints(AuraTrackParty)
		self.AuraTracker = AuraTrackParty

		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(100, 30)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('TOPLEFT', self, 'RIGHT', 11, 7)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.CustomFilter = CustomAuraFilters.party
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 3
		Debuffs.onlyShowPlayer = false
		Debuffs.size = 28
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs

		local Trinket = CreateFrame("Frame", nil, self)
		Trinket:SetSize(30,30)
		Trinket:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -6, 0)
		self.Trinket = Trinket
	end,
}

UnitSpecific.focustarget = UnitSpecific.targettarget


--------------------------------------
-- SPAWN STYLE
--------------------------------------

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
	spawnHelper(self, 'player', "CENTER", UIParent, cfg.playerFramePosition_X, cfg.playerFramePosition_Y)
	spawnHelper(self, 'target', "LEFT", oUF_KBJPlayer, "RIGHT", 10, 0)
	spawnHelper(self, 'focus', "BOTTOM", oUF_KBJTarget, "TOP", 0, 32)
	spawnHelper(self, 'pet', "RIGHT", oUF_KBJPlayer, "LEFT", -4, 0)
	spawnHelper(self, 'targettarget', "BOTTOM", oUF_KBJTarget, "TOP", 0, 5)
	spawnHelper(self, 'focustarget', "LEFT", oUF_KBJFocus, "RIGHT", 5, 0)

	self:SetActiveStyle'KBJ - Party'
	local party = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug		
		'yOffset', -12,
		'oUF-initialConfigFunction', ([[
			self:SetHeight(%d)
			self:SetWidth(%d)
		]]):format(72, 44)
	)
	party:SetPoint("TOP", UIParent, "CENTER", cfg.partyFramePosition_X, cfg.partyFramePosition_Y)
	self:SetActiveStyle'KBJ - Pet'
	local pets = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug	
		'yOffset', -12,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'pet')
		]])
	)
	pets:SetPoint("TOPRIGHT", party, "TOPLEFT", -4, 0)
	self:SetActiveStyle'KBJ - Targettarget'
	local partytargets = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug		
		'yOffset', -44,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'target')
		]])
	)
	partytargets:SetPoint("TOPLEFT", party, "TOPRIGHT", 5, 0)

	self:SetActiveStyle'KBJ - Raid'
	local raid = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, 'showRaid', true,-- debug
		'xOffset', 5,
		'yOffset', -12,	    
		'point', 'TOP',
		'groupFilter', '1,2,3,4,5,6,7,8',	
	    'groupingOrder', '1,2,3,4,5,6,7,8',
		'groupBy', 'GROUP',
		-- 'sortMethod', 'GROUP',
		'maxColumns', 8,
	    'unitsPerColumn', 5,
		'columnSpacing', 5,
		'columnAnchorPoint', 'RIGHT',
		'oUF-initialConfigFunction', ([[
			self:SetHeight(%d)
			self:SetWidth(%d)
		]]):format(44, 44)
	)
	raid:SetPoint("TOPRIGHT", UIParent, "CENTER", cfg.raidFramePosition_X, cfg.raidFramePosition_Y)

	local arena = {}
	self:SetActiveStyle'KBJ - Arena'
	for i = 1, 5 do
		arena[i] = self:Spawn('arena'..i, "oUF_Arena"..i)
		arena[i]:SetPoint("TOP", UIParent, "CENTER", cfg.arenaFramePosition_X, (cfg.arenaFramePosition_Y+56-(56*i)))
	end
	local arenapet = {}
	self:SetActiveStyle'KBJ - Pet'
	for i = 1, 5 do
		arenapet[i] = self:Spawn("arena"..i.."pet", "oUF_Arena"..i.."pet")
		arenapet[i]:SetPoint("LEFT", arena[i], "RIGHT", 4, 0)
	end
	local arenatarget = {}
	self:SetActiveStyle'KBJ - Targettarget'
	for i = 1, 5 do
		arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
		arenatarget[i]:SetPoint("TOPLEFT", arena[i], "TOPRIGHT", 11, 0)
	end
	local arenaprep = {}
	local arenaprepspec = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame('Frame', 'oUF_ArenaPrep'..i, UIParent)		
		arenaprep[i]:SetSize(72, 44)
		arenaprep[i]:SetPoint("TOPLEFT", arena[i], "TOPLEFT", 0, 0)
		arenaprep[i].framebd = framebd(arenaprep[i], arenaprep[i])

		arenaprep[i].Health = CreateFrame('StatusBar', nil, arenaprep[i])
		-- arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetSize(72, 41)
		arenaprep[i].Health:SetPoint("TOP", arenaprep[i], "TOP", 0, 0)
		arenaprep[i].Health:SetStatusBarTexture(barTexture)
		arenaprep[i].Health:SetStatusBarColor(0, 0, 0)
		arenaprep[i].Power = CreateFrame('StatusBar', nil, arenaprep[i])
		arenaprep[i].Power:SetSize(72, 2)
		arenaprep[i].Power:SetPoint("TOP", arenaprep[i].Health, "BOTTOM", 0, -1)
		arenaprep[i].Power:SetStatusBarTexture(barTexture)
		arenaprep[i].Power:SetStatusBarColor(0, 0, 0)

		arenaprep[i].SpecIcon = arenaprep[i]:CreateTexture(nil, 'OVERLAY')
		arenaprep[i].SpecIcon.BG = CreateFrame('Frame', nil, arenaprep[i])
		arenaprep[i].SpecIcon.BG:SetSize(30,30)
		arenaprep[i].SpecIcon.BG:SetPoint("TOPRIGHT", arena[i], "LEFT", -6, 8)
		arenaprep[i].SpecIcon.BG.framebd = framebd(arenaprep[i].SpecIcon.BG, arenaprep[i].SpecIcon.BG)
		arenaprep[i].SpecIcon:SetSize(32, 32)
		arenaprep[i].SpecIcon:SetPoint("TOPRIGHT", arena[i], "LEFT", -5, 9)		
		-- arenaprep[i].SpecIcon:SetTexture([[INTERFACE\AddOns\oUF_KBJ\Media\Mage.tga]]) -- debug

		arenaprep[i]:Hide()
	end
	local arenaprepupdate = CreateFrame('Frame')
	arenaprepupdate:RegisterEvent('PLAYER_LOGIN')
	arenaprepupdate:RegisterEvent('PLAYER_ENTERING_WORLD')
	arenaprepupdate:RegisterEvent('ARENA_OPPONENT_UPDATE')
	--arenaprepupdate:RegisterEvent("UNIT_NAME_UPDATE")
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
]]--
		else
			local numOpps = GetNumArenaOpponentSpecs()
			if numOpps > 0 then
				for i = 1, 5 do
					local f = arenaprep[i]
					if i <= numOpps then
						local s = GetArenaOpponentSpec(i)
						local _, spec, texture, class
	
						if s and s > 0 then
							_, spec, _, texture, _, _, class = GetSpecializationInfoByID(s)
						end
	
						if class and spec then
							local class_color = RAID_CLASS_COLORS[class]
							f.Health:SetStatusBarColor(class_color.r, class_color.g, class_color.b)
							f.Power:SetStatusBarColor(class_color.r, class_color.g, class_color.b)
							f.SpecIcon:SetTexture(texture or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
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