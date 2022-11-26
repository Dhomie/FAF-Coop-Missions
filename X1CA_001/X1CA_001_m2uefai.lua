--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m2uefai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : UEF army AI for Mission 2 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local UEFM2WesternTown = BaseManager.CreateBaseManager()

function UEFM2WesternTownAI()

    -- ----------------
    -- UEF Western Town
    -- ----------------
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Town_Init_Eng_D' .. Difficulty)
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_Town_Turrets_D' .. Difficulty)
    UEFM2WesternTown:Initialize(ArmyBrains[UEF], 'M2_Town_Defenses', 'UEF_M2_Base_Marker', 70,
	{
	    M2_Town_Defenses = 100,
	}
    )
    UEFM2WesternTown:StartNonZeroBase({6, 5, 4})
    UEFM2WesternTown:SetMaximumConstructionEngineers(6)

	UEFM2WesternTown:AddBuildGroupDifficulty('M2_Town_Turrets', 90)

    UEFM2WesternTownLandAttacks()
    UEFM2WesternTownAirAttacks()
end

function UEFM2WesternTownLandAttacks()
    local opai = nil

    -- ---------------------------------------
    -- UEF M2 Western Town Op AI, Land Defense
    -- ---------------------------------------

    -- sends [mobile missiles]
    opai = UEFM2WesternTown:AddOpAI('BasicLandAttack', 'M2_LandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 4)

    -- sends [heavy tanks]
    opai = UEFM2WesternTown:AddOpAI('BasicLandAttack', 'M2_LandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)

    -- sends [light bots]
    opai = UEFM2WesternTown:AddOpAI('BasicLandAttack', 'M2_LandDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('SiegeBots', 2)

    -- sends [light artillery]
    opai = UEFM2WesternTown:AddOpAI('BasicLandAttack', 'M2_LandDefense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', 4)

    -- sends [range bots]
    opai = UEFM2WesternTown:AddOpAI('BasicLandAttack', 'M4_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('RangeBots', 4)
end

function UEFM2WesternTownAirAttacks()
    local opai = nil

    -- ----------------------------------------
    --  UEF M2 Western Town Op AI, Air Attacks
    -- ----------------------------------------

    -- Air defense
    --for i = 1, 2 do
        opai = UEFM2WesternTown:AddOpAI('AirAttacks', 'M2_AirDefense_Gunships',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Town_Defenses_EngineerChain',
                },
            }
        )
        opai:SetChildQuantity('Gunships', 4)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		
		opai = UEFM2WesternTown:AddOpAI('AirAttacks', 'M2_AirDefense_ASFs',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Town_Defenses_EngineerChain',
                },
            }
        )
        opai:SetChildQuantity('AirSuperiority', 4)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    --end
end


function DisableBase()
    if(UEFM2WesternTown) then
        UEFM2WesternTown:BaseActive(false)
    end
end