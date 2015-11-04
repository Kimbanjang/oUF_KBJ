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
targetCastbarPosition_Y = 117,
targetCastbarPosition_Width = 275,
targetCastbarPosition_Height = 30,

-- Focus Castbar
focusCastbar = true,		-- true/false
focusCastbarPosition_X = 15,
focusCastbarPosition_Y = 149,
focusCastbarPosition_Width = 275,
focusCastbarPosition_Height = 20,

-- Arena Castbar
arenaFramePosition_X = 368,
arenaFramePosition_Y = 165,

arenaCastbar = true,		-- true/false
arenaCastbarPosition_X = -161,
arenaCastbarPosition_Y = 34,
arenaCastbarPosition_Width = 159,
arenaCastbarPosition_Height = 30,

--[[ not ready
-- Raid Frame
]]

}