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
	unit = unit:match('(boss)%d?$') or unit:match('(arena)%d?$') or unit

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
		self:Tag(petHpPer, "P:[unit:health]")
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
	elseif (unit == 'targettarget' or unit == 'focustarget' or unit == 'partytarget' or unit == 'arenatarget') then
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

		local t = CreateFrame('Frame', nil, self)
		t:SetSize(32, 32)
		t:SetPoint('TOPRIGHT', self, 'LEFT', -10, 17)
		t.framebd = framebd(t, t)
		self.Trinket = t		
		local at = CreateFrame('Frame', nil, self)
		at:SetAllPoints(t)
		at:SetFrameStrata('HIGH')
		at.icon = at:CreateTexture(nil, 'ARTWORK')
		at.icon:SetAllPoints(at)
		at.icon:SetTexCoord(0.07,0.93,0.07,0.93)  
		self.AuraTracker = at
	elseif (unit == 'arena') then
		local arenaHpPer = self:CreateFontString(nil, "OVERLAY")
		arenaHpPer:SetPoint("CENTER", self, "CENTER", 0, 0)
		arenaHpPer:SetFont(fontNumber, 28, 'THINOUTLINE')
		self:Tag(arenaHpPer, "[unit:arenahealth]")
		local arenaHpCur = self:CreateFontString(nil, "OVERLAY")
		arenaHpCur:SetPoint("CENTER", arenaHpPer, "TOP", 0, 6)
		arenaHpCur:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(arenaHpCur, "[unit:arenahp]")
		local arenaPpPer = self:CreateFontString(nil, "OVERLAY")
		arenaPpPer:SetPoint("CENTER", arenaHpPer, "BOTTOM", 1, -4)
		arenaPpPer:SetFont(fontNumber, 16, 'THINOUTLINE')
		self:Tag(arenaPpPer, "[unit:power]")
		local arenaName = self:CreateFontString(nil, "OVERLAY")
		arenaName:SetPoint("RIGHT", arenaHpCur, "LEFT", -5, 0)
		arenaName:SetFont(fontGeneral, 10, 'THINOUTLINE')
		self:Tag(arenaName, "[unit:name]")

		local t = CreateFrame('Frame', nil, self)
		t:SetSize(32, 32)
		t:SetPoint('TOPRIGHT', self, 'LEFT', -5, 11)
		t.framebd = framebd(t, t)
		self.Trinket = t		
		local at = CreateFrame('Frame', nil, self)
		at:SetAllPoints(t)
		at:SetFrameStrata('HIGH')
		at.icon = at:CreateTexture(nil, 'ARTWORK')
		at.icon:SetAllPoints(at)
		at.icon:SetTexCoord(0.07,0.93,0.07,0.93)  
		self.AuraTracker = at
	end

	-- Status Icons
	self.Leader = self:CreateTexture(nil, "OVERLAY")
	if (unit == 'player') then		
		self.Leader:SetPoint("LEFT", self, "LEFT", 8, 14)
		self.Leader:SetSize(12, 12)
		self.Resting = self:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("LEFT", self, "TOPLEFT", -5, -1)
		self.Resting:SetSize(20, 18)
		self.Combat = self:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("LEFT", self, "LEFT", -3, 1)
		self.Combat:SetSize(15, 15)
	elseif (unit == 'party') then
		self.Leader:SetPoint("CENTER", self, "LEFT", 1, -13)
		self.Leader:SetSize(12, 12)
	end

	-- Raid Target Icon
	self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
	if (unit == 'target') then
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 12)
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(30, 30)
	elseif (unit == 'party') then
		self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, 0)
		self.RaidIcon:SetAlpha(0.6)
		self.RaidIcon:SetSize(20, 20)
	end

	-- Role icons
	if (unit == "party") then
		self.LFDRole = self:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetPoint("CENTER", self, "LEFT", 1, 0)
		self.LFDRole:SetSize(14, 14)
	end

	-- Combo Point
	if (unit == 'player') and (playerClass == "ROGUE" or playerClass == "DRUID") then
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
	if (unit == 'target') then
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
	player:SetPoint("CENTER", UIParent, cfg.playerFramePosition_X, cfg.playerFramePosition_Y)
	local pet = oUF:Spawn("pet")
	pet:SetPoint("CENTER", player, "TOP", -1, -2)
	local target = oUF:Spawn("target")
	target:SetPoint("CENTER", player, "BOTTOMRIGHT", 36, 10)
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("CENTER", target, "BOTTOMRIGHT", 40, 13)
	local focus = oUF:Spawn("focus")
	focus:SetPoint("CENTER", UIParent, cfg.focusFramePosition_X, cfg.focusFramePosition_Y)
	local focustarget = oUF:Spawn("focustarget")
	focustarget:SetPoint("CENTER", focus, "RIGHT", 25, 2)

	local party = self:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true,
		'showPlayer', true, 'showSolo', true, -- debug
		'yOffset', -30
	)
	party:SetPoint("TOP", UIParent, "CENTER", cfg.partyFramePosition_X, cfg.partyFramePosition_Y)
	local pets = oUF:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true,
		'showPlayer', true, 'showSolo', true, -- debug
		'yOffset', -30,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'pet')
		]])
	)
	pets:SetPoint("BOTTOM", party, "BOTTOM", 0, -24)
	local partytargets = oUF:SpawnHeader(nil, nil, 'raid,party,solo', -- raid,party,solo for debug
		'showParty', true,
		'showPlayer', true, 'showSolo', true, -- debug
		'yOffset', -30,
		'oUF-initialConfigFunction', ([[
			self:SetAttribute('unitsuffix', 'target')
		]])
	)
	partytargets:SetPoint("CENTER", party, "RIGHT", 25, 2)

	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
		if i == 1 then
			arena[i]:SetPoint("CENTER", UIParent, cfg.arenaFramePosition_X, cfg.arenaFramePosition_Y)
		else
			arena[i]:SetPoint("TOP", arena[i-1], "BOTTOM", 0, -30)
		end
	end
	
	local arenatarget = {}
	for i = 1, 5 do
		arenatarget[i] = oUF:Spawn("arenatarget"..i, "oUF_Arena"..i.."target")
		if i == 1 then
			arenatarget[i]:SetPoint('TOPLEFT', arena[i], 'TOPRIGHT', 5, 0)
		else
			arenatarget[i]:SetPoint('TOP', arenatarget[i-1], 'BOTTOM', 0, -27)
		end
	end


--[[
	local arenaprep = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame('Frame', 'oUF_ArenaPrep'..i, UIParent)
		arenaprep[i]:SetAllPoints(_G['oUF_Arena'..i])
		arenaprep[i]:SetFrameStrata('BACKGROUND')
		arenaprep[i].framebd = framebd(arenaprep[i], arenaprep[i])

		arenaprep[i].Health = CreateFrame('StatusBar', nil, arenaprep[i])
		arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetStatusBarTexture(cfg.texture)

		arenaprep[i].Spec = fs(arenaprep[i].Health, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		arenaprep[i].Spec:SetPoint('CENTER')
		arenaprep[i].Spec:SetJustifyH'CENTER'

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
		elseif event == 'ARENA_OPPONENT_UPDATE' then
			for i = 1, 5 do
				arenaprep[i]:Hide()
			end
		else
			local numOpps = GetNumArenaOpponentSpecs()
			if numOpps > 0 then
				for i = 1, 5 do
					local f = arenaprep[i]
					if i <= numOpps then
						local s = GetArenaOpponentSpec(i)
						local _, spec, class = nil, 'UNKNOWN', 'UNKNOWN'
	
						if s and s > 0 then
							_, spec, _, _, _, _, class = GetSpecializationInfoByID(s)
						end
	
						if class and spec then
							if cfg.class_colorbars then
								f.Health:SetStatusBarColor(class_color.r, class_color.g, class_color.b)
							else
								f.Health:SetStatusBarColor(cfg.Color.Health.r, cfg.Color.Health.g, cfg.Color.Health.b)
							end
							f.Spec:SetText(spec..'  -  '..LOCALIZED_CLASS_NAMES_MALE[class])
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
--]]--
end)



----------------------------------------------------------------------------------------
--	Test UnitFrames(by community)
----------------------------------------------------------------------------------------
SlashCmdList.TEST_UF = function(msg)
	if msg == "hide" then
		for _, frames in pairs({"oUF_Target", "oUF_TargetTarget", "oUF_Pet", "oUF_Focus", "oUF_FocusTarget"}) do
			_G[frames].Hide = nil
		end
		
			for i = 1, 5 do
				_G["oUF_Arena"..i].Hide = nil
				_G["oUF_Arena"..i.."Target"].Hide = nil
			end
		
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_Boss"..i].Hide = nil
			end		
	else
			for i = 1, 5 do
				_G["oUF_Arena"..i].Hide = function() end
				_G["oUF_Arena"..i].unit = "player"
				_G["oUF_Arena"..i]:Show()
				_G["oUF_Arena"..i]:UpdateAllElements()
				_G["oUF_Arena"..i].Trinket.Icon:SetTexture("Interface\\Icons\\INV_Jewelry_Necklace_37")

				_G["oUF_Arena"..i.."target"].Hide = function() end
				_G["oUF_Arena"..i.."target"].unit = "player"
				_G["oUF_Arena"..i.."target"]:Show()
				_G["oUF_Arena"..i.."target"]:UpdateAllElements()			
				_G["oUF_Arena"..i].Talents:SetText(TALENTS)
							
			end
		
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_Boss"..i].Hide = function() end
				_G["oUF_Boss"..i].unit = "player"
				_G["oUF_Boss"..i]:Show()
				_G["oUF_Boss"..i]:UpdateAllElements()
			end		
	end
end
SLASH_TEST_UF1 = "/qwer"
SLASH_TEST_UF2 = "/kbjui"


-- For testing /run oUFAbu.TestArena()
function TAA()
	oUF_Arena1:Show(); oUF_Arena1.Hide = function() end oUF_Arena1.unit = "target"
	oUF_Arena2:Show(); oUF_Arena2.Hide = function() end oUF_Arena2.unit = "target"
	oUF_Arena3:Show(); oUF_Arena3.Hide = function() end oUF_Arena3.unit = "target"
	oUF_Arena4:Show(); oUF_Arena4.Hide = function() end oUF_Arena4.unit = "target"
	oUF_Arena5:Show(); oUF_Arena5.Hide = function() end oUF_Arena5.unit = "target"
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