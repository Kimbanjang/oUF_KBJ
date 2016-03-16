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
playerFramePosition_X = 110,
playerFramePosition_Y = 21,
	-- Target's Debuff
	onlyShowMyDebuff = true,	-- true/false
	dontUsedCCTimer = false,	-- false : you used tullaCC or OmniCC / ture : you dont used tullaCC or OmniCC

	-- Player Castbar
	playerCastbar = true,		-- true/false
	playerCastbarPosition_Width = 180,
	playerCastbarPosition_Height = 20,
	playerCastbarPosition_X = 10,
	playerCastbarPosition_Y = 77,

	-- Target Castbar
	targetCastbar = true,		-- true/false
	targetCastbarPosition_Width = 210,
	targetCastbarPosition_Height = 30,
	targetCastbarPosition_X = 15,
	targetCastbarPosition_Y = 200,

	-- Focus Castbar
	focusCastbar = true,		-- true/false
	focusCastbarPosition_Width = 210,
	focusCastbarPosition_Height = 20,
	focusCastbarPosition_X = 15,
	focusCastbarPosition_Y = 233,

-- Party/PartyPet/PartyTarget Frame
partyFramePosition_X = -114,
partyFramePosition_Y = -53,

-- Raid Frame
raidFramePosition_X = -180,
raidFramePosition_Y = -53,

-- Arena Frame
arenaFramePosition_X = 240,
arenaFramePosition_Y = -53,

-- Arena Castbar
arenaCastbar = true,			-- true/false
arenaCastbarPosition_X = -5,		-- Sticker arenaFrame
arenaCastbarPosition_Y = 0,
arenaCastbarPosition_Width = 130,
arenaCastbarPosition_Height = 9,

--[[ not ready
-- 
]]

}