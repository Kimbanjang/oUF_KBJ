--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = {}


--------------------------------------
-- Config
--------------------------------------

ns.cfg = {

-- Player/Pet/Target/TargetTarget Frame/Focus Frame/FocusTarget Frame
playerFramePosition_X = 130,
playerFramePosition_Y = 10,
	-- Target's Debuff
	onlyShowMyDebuff = true,	-- true/false
	dontUsedCCTimer = false,	-- false : you used tullaCC or OmniCC / ture : you dont used tullaCC or OmniCC

	-- Player Castbar
	playerCastbar = true,		-- true/false
	playerCastbarPosition_Width = 180,
	playerCastbarPosition_Height = 20,
	playerCastbarPosition_X = 10,
	playerCastbarPosition_Y = 43,

	-- Target Castbar
	targetCastbar = true,		-- true/false
	targetCastbarPosition_Width = 210,
	targetCastbarPosition_Height = 30,
	targetCastbarPosition_X = 15,
	targetCastbarPosition_Y = 130,

	-- Focus Castbar
	focusCastbar = true,		-- true/false
	focusCastbarPosition_Width = 210,
	focusCastbarPosition_Height = 20,
	focusCastbarPosition_X = 15,
	focusCastbarPosition_Y = 163,

-- Party/PartyPet/PartyTarget Frame
partyFramePosition_X = -89,
partyFramePosition_Y = -53,

-- Raid Frame
raidFramePosition_X = -150,
raidFramePosition_Y = -53,

-- Arena Castbar
arenaFramePosition_X = 268,
arenaFramePosition_Y = -71,

arenaCastbar = true,		-- true/false
arenaCastbarPosition_X = -79,
arenaCastbarPosition_Y = 1,
arenaCastbarPosition_Width = 146,
arenaCastbarPosition_Height = 18,

--[[ not ready
-- 
]]

}