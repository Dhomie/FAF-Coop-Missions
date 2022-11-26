--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_m3qaiai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : QAI army AI for Mission 3 - X1CA_002
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local QAI = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local QAIM3NavalBase = BaseManager.CreateBaseManager()

function QAIM3NavalBaseAI()

    -- -----------------
    -- QAI M3 Naval Base
    -- -----------------
    QAIM3NavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Naval_Base', 'M3_QAI_Naval_Base_Marker', 75, {M3_QAI_Naval_Base = 100})
	QAIM3NavalBase:StartNonZeroBase({2, 3, 4})
	QAIM3NavalBase:SetMaximumConstructionEngineers(4)

    QAIM3NavalBaseNavalAttacks()
end

function QAIM3NavalBaseNavalAttacks()
    local opai = nil

    -- --------------------------------------
    -- QAI M3 Naval Base Op AI, Naval Attacks
    -- --------------------------------------
	
	opai = QAIM3NavalBase:AddNavalAI('M3_NavalFleet_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M3_QAI_NavalAttack_2_Chain'},
            },
            MaxFrigates = 30 * Difficulty,
            MinFrigates = 15 * Difficulty,
            Priority = 100,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	
	opai = QAIM3NavalBase:AddNavalAI('M3_NavalFleet_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M3_QAI_NavalAttack_2_Chain'},
            },
            MaxFrigates = 20 * Difficulty,
            MinFrigates = 10 * Difficulty,
            Priority = 110,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})

end