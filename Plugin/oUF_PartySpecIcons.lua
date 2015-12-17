local _, ns = ...
local oUF = ns.oUF or oUF

local Update = function(self, event)
	if event == 'PARTY_MEMBERS_CHANGED' and unit ~= self.unit then return; end
	local pclassIcon = self.PartyClassIcon	
	local _, class = UnitClass(self.unit)

	if class and UnitIsPlayer(self.unit) then
		pclassIcon.Icon:SetTexture("Interface\\AddOns\\oUF_KBJ\\Media\\"..class..".tga")
	else
		pclassIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
	end

	if(pclassIcon.PostUpdate) then pclassIcon:PostUpdate(event) end	
end

local Enable = function(self)
	local pclassIcon = self.PartyClassIcon
	if pclassIcon then		
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
		
		if not pclassIcon.Icon then
			pclassIcon.Icon = pclassIcon:CreateTexture(nil, "OVERLAY")
			pclassIcon.Icon:SetAllPoints(pclassIcon)
			pclassIcon.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		pclassIcon:Show()
		return true
	end
end
 
local Disable = function(self)
	local pclassIcon = self.PartyClassIcon
	if pclassIcon then
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)	
		pclassIcon:Hide()
	end
end
 
oUF:AddElement('PartyClassIcon', Update, Enable, Disable)