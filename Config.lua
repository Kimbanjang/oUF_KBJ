--------------------------------------
-- VARIABLES
--------------------------------------

local _, ns = ...
local cfg = {}


--------------------------------------
-- Config
--------------------------------------

ns.cfg = {

-- Player/Pet/Target/TargetTarget Frame
playerFramePosition_X = 130,
playerFramePosition_Y = -10,

-- Target's Debuff
onlyShowMyDebuff = true,	-- true/false
dontUsedCCTimer = false,	-- ture : dont used tullaCC, OmniCC / false : used tullaCC, OmniCC

-- Focus Frame
focusFramePosition_X = 367,
focusFramePosition_Y = 100,

-- Party/PartyPet/PartyTarget Frame
partyFramePosition_X = 280,
partyFramePosition_Y = -75,

-- Arena Frame
arenaFramePosition_X = -225,
arenaFramePosition_Y = -85,

--[[ not ready
-- Party's Debuff
-- Raid Frame

-- Player Castbar
playerCastbar = true,		-- true/false
playerCastbarPosition_X = 130,
playerCastbarPosition_Y = 130,
playerCastbarPosition_Width,
playerCastbarPosition_Height,

-- Target Castbar
targetCastbar = true,		-- true/false
targetCastbarPosition_X = 130,
targetCastbarPosition_Y = 130,
targetCastbarPosition_Width,
targetCastbarPosition_Height,

-- Focus Castbar
targetCastbar = true,		-- true/false
focusCastbarPosition_X = 130,
focusCastbarPosition_Y = 130,
focusCastbarPosition_Width,
focusCastbarPosition_Height,

arenaCasrbar = true,
]]

}