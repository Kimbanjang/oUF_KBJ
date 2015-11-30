--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = ns.cfg

local fontGeneral = STANDARD_TEXT_FONT
local fontNumber = [[Interface\AddOns\oUF_KBJ\Media\DAMAGE.ttf]]
local playerClass = select(2, UnitClass('player'))

local Loader = CreateFrame('Frame')
Loader:RegisterEvent('ADDON_LOADED')
Loader:SetScript('OnEvent', function(self, event, addon)
	if addon ~= 'oUF_KBJ' then return end

	oUFLanAura = oUFKBJAura or {}
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
	edgeFile = "Interface\\AddOns\\oUF_KBJ\\Media\\glowTex", edgeSize = 3,
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
				ticks[k]:SetTexture("Interface\\AddOns\\oUF_KBJ\\Media\\texture")
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
	local cb = createStatusbar(self, "Interface\\AddOns\\oUF_KBJ\\Media\\texture", nil, nil, nil, 1, 1, 1, 1)		
	local cbbg = cb:CreateTexture(nil, 'BACKGROUND')
	cbbg:SetAllPoints(cb)
	cbbg:SetTexture("Interface\\AddOns\\oUF_KBJ\\Media\\texture")
	cbbg:SetVertexColor(1, 1, 1, .2)
	cb.Time = fs(cb, 'OVERLAY', fontGeneral, 12, 'THINOUTLINE', 1, 1, 1)
	cb.Time:SetPoint('RIGHT', cb, -2, 0)		
	cb.Text = fs(cb, 'OVERLAY', fontGeneral, 12, 'THINOUTLINE', 1, 1, 1, 'LEFT')
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
		cb.SafeZone:SetTexture("Interface\\AddOns\\oUF_KBJ\\Media\\texture")
		cb.SafeZone:SetVertexColor(.8,.11,.15, .7)
		cb.Lag = fs(cb, 'OVERLAY', fontGeneral, 10, 'THINOUTLINE', 1, 1, 1)
		cb.Lag:SetPoint('BOTTOMRIGHT', 0, -12)
		cb.Lag:SetJustifyH('RIGHT')
		self:RegisterEvent('UNIT_SPELLCAST_SENT', function(_, _, caster)
			if (caster == 'player' or caster == 'vehicle') and self.Castbar.SafeZone then
				self.Castbar.SafeZone.sendTime = GetTime()
			end
		end, true)

		local gcd = createStatusbar(self, "Interface\\AddOns\\oUF_KBJ\\Media\\texture", nil, cfg.playerCastbarPosition_Height/6, cfg.playerCastbarPosition_Width, 0.5, 0.5, 0.5, 1)
		gcd:SetPoint("CENTER", UIParent, cfg.playerCastbarPosition_X, cfg.playerCastbarPosition_Y-cfg.playerCastbarPosition_Height/1.2)
		gcd.bg = gcd:CreateTexture(nil, 'BORDER')
		gcd.bg:SetAllPoints(gcd)
		gcd.bg:SetTexture("Interface\\AddOns\\oUF_KBJ\\Media\\texture")
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
		cb:SetPoint("RIGHT", self, "LEFT",cfg.arenaCastbarPosition_X, cfg.arenaCastbarPosition_Y)
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

local UnitSpecific = {
	player = function(self, ...)
		Shared(self, ...)
		if cfg.playerCastbar then castbar(self) end
		self.unit = 'player'
		self:SetSize(64,32)

		local playerHpPer = self:CreateFontString(nil, "OVERLAY")
		playerHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		playerHpPer:SetFont(fontNumber, 18, 'THINOUTLINE')
		self:Tag(playerHpPer, "[unit:health]")
		local playerPpPer = self:CreateFontString(nil, "OVERLAY")
		playerPpPer:SetPoint("CENTER", playerHpPer, "BOTTOM", 0, -4)
		playerPpPer:SetFont(fontNumber, 10, 'THINOUTLINE')
		self:Tag(playerPpPer, "[unit:power]")

		self.Leader = self:CreateTexture(nil, "OVERLAY")
		self.Leader:SetSize(12, 12)
		self.Leader:SetPoint("LEFT", self, "LEFT", 8, 14)
		self.Assistant = self:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetSize(12, 12)
		self.Assistant:SetPoint("LEFT", self, "LEFT", 8, 14)		
		self.Resting = self:CreateTexture(nil, "OVERLAY")
		self.Resting:SetSize(20, 18)
		self.Resting:SetPoint("LEFT", self, "TOPLEFT", -5, -1)		
		self.Combat = self:CreateTexture(nil, "OVERLAY")
		self.Combat:SetSize(15, 15)
		self.Combat:SetPoint("LEFT", self, "LEFT", -3, 1)

		-- Class Resource
		---- Combo Point
		if (playerClass == "ROGUE" or playerClass == "DRUID") then
			local comboPoints = self:CreateFontString(nil, "OVERLAY")
			comboPoints:SetFont(fontNumber, 18, 'THINOUTLINE')
			comboPoints:SetPoint("CENTER", self, "BOTTOM", 0, -13)
			self:Tag(comboPoints, "[unit:cpoints]")
		---- Warlock Resource
		elseif (playerClass == "WARLOCK") then
			local warlockResource = self:CreateFontString(nil, "OVERLAY")
			warlockResource:SetFont(fontNumber, 14, 'THINOUTLINE')
			warlockResource:SetPoint("CENTER", self, "BOTTOM", 0, -12)
			self:Tag(warlockResource, "[unit:warlockresource]")
		---- Monk Chi
		elseif (playerClass == "MONK") then
			local monkChi = self:CreateFontString(nil, "OVERLAY")
			monkChi:SetFont(fontNumber, 18, 'THINOUTLINE')
			monkChi:SetPoint("CENTER", self, "BOTTOM", 0, -13)
			self:Tag(monkChi, "[unit:monkchi]")
		end
	end,

	target = function(self, ...)
		Shared(self, ...)
		self.unit = 'target'
		self:SetSize(64,32)
		
		if cfg.targetCastbar then castbar(self) end

		local targetHpPer = self:CreateFontString(nil, "OVERLAY")
		targetHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		targetHpPer:SetFont(fontNumber, 32, 'THINOUTLINE')
		self:Tag(targetHpPer, "[unit:health]")
		local targetHpCur = self:CreateFontString(nil, "OVERLAY")
		targetHpCur:SetPoint("CENTER", targetHpPer, "TOP", 0, 5)
		targetHpCur:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(targetHpCur, "[unit:shorthp]")
		local targetPpPer = self:CreateFontString(nil, "OVERLAY")
		targetPpPer:SetPoint("CENTER", targetHpPer, "BOTTOM", 1, -5)
		targetPpPer:SetFont(fontNumber, 20, 'THINOUTLINE')
		self:Tag(targetPpPer, "[unit:power]")
		local targetName = self:CreateFontString(nil, "OVERLAY")
		targetName:SetPoint("LEFT", targetHpPer, "TOP", 40, -7)
		targetName:SetFont(fontGeneral, 12, 'THINOUTLINE')
		self:Tag(targetName, "[unit:level] [unit:name]")

		self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(30, 30)
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 12)

		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(150, 20)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 10, -12)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.filter : custom filter list for debuffs to display
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 8
		Debuffs.onlyShowPlayer = false --cfg.onlyShowMyDebuff
		Debuffs.size = 16
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs
	end,

	focus = function(self, ...)
		Shared(self, ...)		
		self.unit = 'focus'
		self:SetSize(64,32)

		if cfg.focusCastbar then castbar(self) end

		local focusHpPer = self:CreateFontString(nil, "OVERLAY")
		focusHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		focusHpPer:SetFont(fontNumber, 18, 'THINOUTLINE')
		self:Tag(focusHpPer, "[unit:health]")
		local focusName = self:CreateFontString(nil, "OVERLAY")
		focusName:SetPoint("CENTER", focusHpPer, "TOP", 0, 7)
		focusName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(focusName, "[unit:name]")
	end,

	pet = function(self, ...)
		Shared(self, ...)
		self.unit = 'pet'
		self:SetSize(64,32)

		local petHpPer = self:CreateFontString(nil, "OVERLAY")
		petHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		petHpPer:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(petHpPer, "[unit:health]")
	end,

	targettarget = function(self, ...)
		Shared(self, ...)
		self.unit = 'targettarget'
		self:SetSize(64,32)

		local targettargetStat = self:CreateFontString(nil, "OVERLAY")
		targettargetStat:SetPoint("LEFT", self, "LEFT", 0, 0)
		targettargetStat:SetFont(fontGeneral, 12, 'THINOUTLINE')
		self:Tag(targettargetStat, "[unit:health] [unit:name]")
	end,

	party = function(self, ...)
		Shared(self, ...)
		self.unit = 'party'
		self:SetSize(64,32)
		self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}

		local partyHpPer = self:CreateFontString(nil, "OVERLAY")
		partyHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		partyHpPer:SetFont(fontNumber, 24, 'THINOUTLINE')
		self:Tag(partyHpPer, "[unit:classcolorhealth]")
		local partyPpPer = self:CreateFontString(nil, "OVERLAY")
		partyPpPer:SetPoint("CENTER", partyHpPer, "BOTTOM", 1, -4)
		partyPpPer:SetFont(fontNumber, 14, 'THINOUTLINE')
		self:Tag(partyPpPer, "[unit:power]")
		local partyName = self:CreateFontString(nil, "OVERLAY")
		partyName:SetPoint("CENTER", partyHpPer, "TOP", 0, 6)
		partyName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(partyName, "[unit:name]")

		self.Leader = self:CreateTexture(nil, "OVERLAY")
		self.Leader:SetSize(12, 12)
		self.Leader:SetPoint("CENTER", self, "TOPLEFT", -30, 1)
		self.Assistant = self:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetSize(12, 12)
		self.Assistant:SetPoint("CENTER", self, "TOPLEFT", -30, 1)
		self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetAlpha(0.7)
		self.RaidIcon:SetSize(22, 22)
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 4)
		self.LFDRole = self:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetSize(14, 14)
		self.LFDRole:SetPoint("CENTER", self, "LEFT", -5, -19)
		self.ReadyCheck = self:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetSize(32, 32)
		self.ReadyCheck:SetPoint("CENTER", self, "LEFT", -19, -5)

		local PartyClassIcon = CreateFrame("Frame", nil, self)
		PartyClassIcon:SetSize(31,31)
		PartyClassIcon:SetPoint("TOPRIGHT", self, "LEFT", -3, 10)		
		PartyClassIcon:SetFrameStrata("LOW")
		PartyClassIcon.framebd = framebd(PartyClassIcon, PartyClassIcon)
		self.PartyClassIcon = PartyClassIcon
		
		local TrackingPartyCC = CreateFrame('Frame', nil, self)
		TrackingPartyCC:SetAllPoints(PartyClassIcon)
		TrackingPartyCC:SetFrameStrata("MEDIUM")
		TrackingPartyCC.icon = TrackingPartyCC:CreateTexture(nil, 'ARTWORK')
		TrackingPartyCC.icon:SetAllPoints(TrackingPartyCC)
		TrackingPartyCC.icon:SetTexCoord(0.07,0.93,0.07,0.93)  
		self.AuraTracker = TrackingPartyCC

		local Buffs = CreateFrame('Frame', nil, self)
		Buffs:SetSize(140, 30)
		Buffs.PostCreateIcon = ns.PostCreateAura
		Buffs.PostUpdateIcon = ns.PostUpdateBuff
		Buffs:SetPoint('TOPLEFT', self, 'RIGHT', 1, 10)
		-- Buffs.disableCooldown : Do not display the cooldown spiral		
		Buffs.CustomFilter = CustomAuraFilters.party
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.num = 4
		Buffs.onlyShowPlayer = ture
		Buffs.size = 28
		Buffs.spacing = 4
		-- Buffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Buffs['growth-y'] = 'DOWN'
		-- Buffs['spacing-x'] : horizontal space between each debuff button (takes priority over Buffs.spacing)
		-- Buffs['spacing-y'] : vertical space between each debuff button (takes priority over Buffs.spacing)
		self.Buffs = Buffs

		--[[
		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(160, 30)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('TOPLEFT', self, 'RIGHT', -2, 4)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.filter : custom filter list for debuffs to display
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 7
		Debuffs.onlyShowPlayer = false
		Debuffs.size = 19
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs
		]]--
	end,	

	arena = function(self, ...)
		Shared(self, ...)		
		self.unit = 'arena'
		self:SetSize(64,32)
		-- self.Range = {insideAlpha = 1, outsideAlpha = 0.4,}

		if cfg.arenaCastbar then castbar(self) end

		local arenaHpPer = self:CreateFontString(nil, "OVERLAY")
		arenaHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		arenaHpPer:SetFont(fontNumber, 24, 'THINOUTLINE')
		self:Tag(arenaHpPer, "[unit:classcolorhealth]")
		local arenaHpCur = self:CreateFontString(nil, "OVERLAY")
		arenaHpCur:SetPoint("CENTER", arenaHpPer, "TOP", -49, 6)
		arenaHpCur:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(arenaHpCur, "[unit:classcolorhp]")
		local arenaPpPer = self:CreateFontString(nil, "OVERLAY")
		arenaPpPer:SetPoint("CENTER", arenaHpPer, "BOTTOM", 1, -4)
		arenaPpPer:SetFont(fontNumber, 14, 'THINOUTLINE')
		self:Tag(arenaPpPer, "[unit:power]")
		local arenaName = self:CreateFontString(nil, "OVERLAY")
		arenaName:SetPoint("CENTER", arenaHpPer, "TOP", 0, 6)
		arenaName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(arenaName, "[unit:name]")

		local Trinket = CreateFrame("Frame", nil, self)
		Trinket:SetSize(31,31)
		Trinket:SetPoint("TOPRIGHT", self, "LEFT", -3, 10)
		self.Trinket = Trinket
--[[
		local SpecIcon = CreateFrame("Frame", nil, self)
		SpecIcon:SetSize(31,31)
		SpecIcon:SetPoint("TOPRIGHT", self, "LEFT", -41, 10)
		SpecIcon:SetFrameStrata("LOW")
		SpecIcon.framebd = framebd(SpecIcon, SpecIcon)
		self.PVPSpecIcon = SpecIcon
]]--
		local TrackingArenaCC = CreateFrame('Frame', nil, self)
		TrackingArenaCC:SetSize(31,31)
		TrackingArenaCC:SetPoint("TOPRIGHT", self, "LEFT", -41, 10)
		--TrackingArenaCC:SetAllPoints(SpecIcon)
		TrackingArenaCC:SetFrameStrata("MEDIUM")
		TrackingArenaCC.icon = TrackingArenaCC:CreateTexture(nil, 'ARTWORK')
		TrackingArenaCC.icon:SetAllPoints(TrackingArenaCC)
		TrackingArenaCC.icon:SetTexCoord(0.07,0.93,0.07,0.93)  
		self.AuraTracker = TrackingArenaCC

		local Buffs = CreateFrame('Frame', nil, self)
		Buffs:SetSize(140, 30)
		Buffs.PostCreateIcon = ns.PostCreateAura
		Buffs.PostUpdateIcon = ns.PostUpdateBuff
		Buffs:SetPoint('TOPLEFT', self, 'RIGHT', 1, 10)
		-- Buffs.disableCooldown : Do not display the cooldown spiral		
		Buffs.CustomFilter = CustomAuraFilters.party
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.num = 4
		Buffs.onlyShowPlayer = ture
		Buffs.size = 28
		Buffs.spacing = 4
		-- Buffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Buffs['growth-y'] = 'DOWN'
		-- Buffs['spacing-x'] : horizontal space between each debuff button (takes priority over Buffs.spacing)
		-- Buffs['spacing-y'] : vertical space between each debuff button (takes priority over Buffs.spacing)
		self.Buffs = Buffs
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
	spawnHelper(self, 'target', "CENTER", oUF_KBJPlayer, "BOTTOMRIGHT", 36, 10)
	spawnHelper(self, 'focus', "CENTER", UIParent, cfg.focusFramePosition_X, cfg.focusFramePosition_Y)
	spawnHelper(self, 'pet', "CENTER", oUF_KBJPlayer, "TOP", -1, -2)
	spawnHelper(self, 'targettarget', "CENTER", oUF_KBJTarget, "BOTTOMRIGHT", 40, 13)
	spawnHelper(self, 'focustarget', "CENTER", oUF_KBJFocus, "RIGHT", 26, 1)

	self:SetActiveStyle'KBJ - Party'
	local party = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug		
		'yOffset', -24
	)
	party:SetPoint("TOP", UIParent, "CENTER", cfg.partyFramePosition_X, cfg.partyFramePosition_Y)
	self:SetActiveStyle'KBJ - Pet'
	local pets = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug		
		'yOffset', -24,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'pet')
		]])
	)
	pets:SetPoint("CENTER", party, "LEFT", -9, 18)
	self:SetActiveStyle'KBJ - Targettarget'
	local partytargets = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true, 'showPlayer', true, 'showSolo', true, -- debug		
		'yOffset', -24,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'target')
		]])
	)
	partytargets:SetPoint("LEFT", party, "RIGHT", 0, 18)

	local arena = {}
	self:SetActiveStyle'KBJ - Arena'
	for i = 1, 5 do
		arena[i] = self:Spawn('arena'..i, "oUF_Arena"..i)
		arena[i]:SetPoint("CENTER", UIParent, cfg.arenaFramePosition_X, (cfg.arenaFramePosition_Y+56-(56*i)))
	end
	local arenapet = {}
	self:SetActiveStyle'KBJ - Pet'
	for i = 1, 5 do
		arenapet[i] = self:Spawn("arena"..i.."pet", "oUF_Arena"..i.."pet")
		arenapet[i]:SetPoint("CENTER", arena[i], "LEFT", -55, 18)
	end
	local arenatarget = {}
	self:SetActiveStyle'KBJ - Targettarget'
	for i = 1, 5 do
		arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
		arenatarget[i]:SetPoint("LEFT", arena[i], "RIGHT", 0, 18)
	end
	local arenaprep = {}
	local arenaprepspec = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame('Frame', 'oUF_ArenaPrep'..i, UIParent)		
		arenaprep[i]:SetSize(31,31)
		arenaprep[i]:SetPoint("TOPRIGHT", arena[i], "LEFT", -3, 10)
		arenaprep[i]:SetFrameStrata('BACKGROUND')
		arenaprep[i].framebd = framebd(arenaprep[i], arenaprep[i])

		arenaprep[i].Health = CreateFrame('StatusBar', nil, arenaprep[i])
		arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetStatusBarTexture("Interface\\AddOns\\oUF_KBJ\\Media\\texture")

		arenaprep[i].SpecIcon = arenaprep[i]:CreateTexture(nil, 'LOW')
		arenaprep[i].SpecIcon:SetSize(35, 35)
		arenaprep[i].SpecIcon:SetPoint("TOPRIGHT", arena[i], "LEFT", -39, 12)		

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