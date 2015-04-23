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
focusFramePosition_X = 265,
focusFramePosition_Y = 95,

-- Party/PartyPet/PartyTarget Frame
partyFramePosition_X = 265,
partyFramePosition_Y = -80,

-- Player Castbar
playerCastbar = true,		-- true/false
playerCastbarPosition_X = 10,
playerCastbarPosition_Y = -140,
playerCastbarPosition_Width = 200,
playerCastbarPosition_Height = 20,

-- Target Castbar
targetCastbar = true,		-- true/false
targetCastbarPosition_X = 15,
targetCastbarPosition_Y = 100,
targetCastbarPosition_Width = 300,
targetCastbarPosition_Height = 30,

-- Focus Castbar
focusCastbar = true,		-- true/false
focusCastbarPosition_X = 15,
focusCastbarPosition_Y = 128,
focusCastbarPosition_Width = 300,
focusCastbarPosition_Height = 16,

-- Arena Castbar
arenaFramePosition_X = 368,
arenaFramePosition_Y = 173,

arenaCastbar = true,		-- true/false
arenaCastbarPosition_X = -5,
arenaCastbarPosition_Y = 20,
arenaCastbarPosition_Width = 327,
arenaCastbarPosition_Height = 6,

--[[ not ready
-- Raid Frame
]]

}