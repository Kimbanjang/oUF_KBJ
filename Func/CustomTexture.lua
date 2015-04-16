-- base source : http://www.wowinterface.com/downloads/info8455-oUFP3lim.html by p3lim

--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = ns.cfg

local FONT = [[Interface\AddOns\oUF_KBJ\Media\semplice.ttf]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = { bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1} }


--------------------------------------
-- Functions
--------------------------------------

local function UpdateAura(self, elapsed)
	if(self.expiration) then
		self.expiration = math.max(self.expiration - elapsed, 0)

		if(self.expiration > 0 and self.expiration < 60) then
			self.Duration:SetFormattedText('%d', self.expiration)
		else
			self.Duration:SetText()
		end
	end
end

local function PostUpdateBuff(element, unit, button, index)
	local _, _, _, _, _, duration, expiration = UnitAura(unit, index, button.filter)

	if(duration and duration > 0) then
		button.expiration = expiration - GetTime()
	else
		button.expiration = math.huge
	end
end

local function PostUpdateCast(element, unit)
	local Spark = element.Spark
	if(not element.interrupt and UnitCanAttack('player', unit)) then
		Spark:SetTexture(1, 0, 0)
	else
		Spark:SetTexture(1, 1, 1)
	end
end

ns.PostCreateAura = function(element, button)
	button:SetBackdrop(BACKDROP)
	button:SetBackdropColor(0, 0, 0)
	button.cd:SetReverse()
	button.cd:SetHideCountdownNumbers(true)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer('ARTWORK')

	local StringParent = CreateFrame('Frame', nil, button)
	StringParent:SetFrameLevel(20)

	button.count:SetParent(StringParent)
	button.count:ClearAllPoints()
	button.count:SetPoint('BOTTOMRIGHT', button, 2, 1)
	button.count:SetFont(FONT, 8, 'OUTLINEMONOCHROME')

	if (cfg.dontUsedCCTimer) then 
		local Duration = StringParent:CreateFontString(nil, 'OVERLAY')
		Duration:SetPoint('TOPLEFT', button, 1, -1)
		Duration:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		button.Duration = Duration
		button:HookScript('OnUpdate', UpdateAura)
	end
end

ns.PostUpdateDebuff = function(element, unit, button, index)
	local _, _, _, _, type, _, _, owner = UnitAura(unit, index, button.filter)

	if(owner == 'player') then
		local color = DebuffTypeColor[type or 'none']
		button:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		button.icon:SetDesaturated(false)
	else
		button:SetBackdropColor(0, 0, 0)
		button.icon:SetDesaturated(true)
	end

	PostUpdateBuff(element, unit, button, index)
end
