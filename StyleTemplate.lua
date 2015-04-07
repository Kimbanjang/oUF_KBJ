--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = ns.cfg

local fontNumber = "Interface\\AddOns\\oUF_KBJ\\Media\\DAMAGE.ttf"
local fontGeneral = STANDARD_TEXT_FONT
local playerClass = select(2, UnitClass("player"))


--------------------------------------
-- STYLE TEMPLATE
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
	elseif (unit == 'pet' or unit == 'partypet') then
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
	elseif (unit == 'targettarget' or unit == 'focustarget' or unit == 'partytarget') then
		local targettargetStat = self:CreateFontString(nil, "OVERLAY")
		targettargetStat:SetPoint("LEFT", self, "LEFT", 0, 0)
		targettargetStat:SetFont(fontGeneral, 12, 'THINOUTLINE')
		self:Tag(targettargetStat, "[unit:health] [unit:name]")
	elseif (unit == 'focus') then
		local focusHpPer = self:CreateFontString(nil, "OVERLAY")
		focusHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		focusHpPer:SetFont(fontNumber, 18, 'THINOUTLINE')
		self:Tag(focusHpPer, "[unit:health]")
		local focusName = self:CreateFontString(nil, "OVERLAY")
		focusName:SetPoint("CENTER", focusHpPer, "TOP", 0, 6)
		focusName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(focusName, "[unit:name]")
	elseif (unit == 'party') then
		local partyHpPer = self:CreateFontString(nil, "OVERLAY")
		partyHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		partyHpPer:SetFont(fontNumber, 18, 'THINOUTLINE')
		self:Tag(partyHpPer, "[unit:health]")
		local partyPpPer = self:CreateFontString(nil, "OVERLAY")
		partyPpPer:SetPoint("CENTER", partyHpPer, "BOTTOM", 0, -4)
		partyPpPer:SetFont(fontNumber, 10, 'THINOUTLINE')
		self:Tag(partyPpPer, "[unit:power]")
		local partyName = self:CreateFontString(nil, "OVERLAY")
		partyName:SetPoint("CENTER", partyHpPer, "TOP", 0, 7)
		partyName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(partyName, "[unit:name]")
	end

	-- Status Icons --
	if (unit == 'player') then
		self.Resting = self:CreateTexture(nil, 'OVERLAY')
		self.Resting:SetPoint("LEFT", self, "TOPLEFT", -5, -1)
		self.Resting:SetSize(20, 18)
		self.Combat = self:CreateTexture(nil, 'OVERLAY')
		self.Combat:SetPoint("LEFT", self, "LEFT", -3, 1)
		self.Combat:SetSize(15, 15)
	end

	-- Raid Target Icon
	self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
	self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
	if (unit == 'target') then
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 12)
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(30, 30)
	elseif (unit == 'party') then
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 5)
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(20, 20)
	end

	-- Combo Point
	if (unit == 'player') and (playerClass == 'ROGUE' or playerClass == 'DRUID') then
		local comboPoints = self:CreateFontString(nil, "OVERLAY")
		comboPoints:SetFont(fontNumber, 18, 'THINOUTLINE')
		comboPoints:SetPoint("CENTER", self, "BOTTOM", 0, -13)
		self:Tag(comboPoints, "[unit:cpoints]")
	end

	-- Warlock Resource
	if (unit == 'player') and (playerClass == "WARLOCK") then
		local warlockResource = self:CreateFontString(nil, "OVERLAY")
		warlockResource:SetFont(fontNumber, 14, 'THINOUTLINE')
		warlockResource:SetPoint("CENTER", self, "BOTTOM", 0, -12)
		self:Tag(warlockResource, "[unit:warlockresource]")
	end

	-- Monk Chi
	if (unit == 'player') and (playerClass == "MONK") then
		local monkChi = self:CreateFontString(nil, "OVERLAY")
		monkChi:SetFont(fontNumber, 18, 'THINOUTLINE')
		monkChi:SetPoint("CENTER", self, "BOTTOM", 0, -13)
		self:Tag(monkChi, "[unit:monkchi]")
	end

	-- Auras (for Target Debuff)
	if (unit == "target") then
		local Debuffs = CreateFrame('Frame', nil, self)
		Debuffs:SetSize(150, 30)
		Debuffs.PostCreateIcon = ns.PostCreateAura
		Debuffs.PostUpdateIcon = ns.PostUpdateDebuff		
		Debuffs:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 11, -25)
		-- Debuffs.disableCooldown : Do not display the cooldown spiral
		-- Debuffs.filter : custom filter list for debuffs to display
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.num = 5
		Debuffs.onlyShowPlayer = cfg.onlyShowMyDebuff
		Debuffs.size = 26
		Debuffs.spacing = 4
		-- Debuffs['growth-x'] : horizontal growth direction (default is 'RIGHT')
		Debuffs['growth-y'] = 'DOWN'
		-- Debuffs['spacing-x'] : horizontal space between each debuff button (takes priority over Debuffs.spacing)
		-- Debuffs['spacing-y'] : vertical space between each debuff button (takes priority over Debuffs.spacing)
		self.Debuffs = Debuffs
	end
end


--------------------------------------
-- SPAWN STYLE
--------------------------------------

oUF:RegisterStyle("Style", StyleTemplate)
oUF:Factory(function(self)
	self:SetActiveStyle("Style")
	local player = oUF:Spawn("player")
	player:SetPoint("CENTER", UIParent, cfg.playerFramePotion_X, cfg.playerFramePotion_Y)
	local pet = oUF:Spawn("pet")
	pet:SetPoint("CENTER", player, "TOP", -1, -1)
	local target = oUF:Spawn("target")
	target:SetPoint("CENTER", player, "BOTTOMRIGHT", 36, 10)
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("CENTER", target, "BOTTOMRIGHT", 40, 13)
	local focus = oUF:Spawn("focus")
	focus:SetPoint("CENTER", UIParent, cfg.focusFramePotion_X, cfg.focusFramePotion_Y)
	local focustarget = oUF:Spawn("focustarget")
	focustarget:SetPoint("CENTER", focus, "RIGHT", 25, 2)

        --local party = oUF:SpawnHeader('party', nil, (config.units.party.hideInRaid and 'party') or 'party,raid',
	local party = self:SpawnHeader(nil, nil, 'raid,party,solo',
		'showParty', true,
		'showPlayer', true,
		'showSolo', true, -- debug
		'yOffset', -15
	)
	party:SetPoint("TOP", UIParent, "CENTER", cfg.PartyFramePotion_X, cfg.PartyFramePotion_Y)
	local pets = oUF:SpawnHeader(nil, nil, 'raid,party,solo',
		'showParty', true,
		'showPlayer', true,
		'showSolo', true, -- debug
		'yOffset', -15,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'pet')
		]])
	)
	pets:SetPoint("CENTER", party, "LEFT", 0, -2)
	local partytargets = oUF:SpawnHeader(nil, nil, 'raid,party,solo',
		'showParty', true,
		'showPlayer', true,
		'showSolo', true, -- debug
		'yOffset', -15,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'target')
		]])
	)
	partytargets:SetPoint("CENTER", party, "RIGHT", 25, 2)
end)
