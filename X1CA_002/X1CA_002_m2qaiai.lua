--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_m2qaiai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : QAI army AI for Mission 2 - X1CA_002
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
local QAIM2SouthBase = BaseManager.CreateBaseManager()

function QAIM2SouthBaseAI()

    -- -----------------
    -- QAI M2 South Base
    -- -----------------
    QAIM2SouthBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M2_South_Base', 'M2_QAI_Base_Marker', 75, {M2_South_Base = 100})
	QAIM2SouthBase:StartNonZeroBase({4, 6, 8})
	QAIM2SouthBase:SetMaximumConstructionEngineers(8)
    QAIM2SouthBase:SetActive('AirScouting', true)
	
	QAIM2SouthBase:AddBuildGroup('M2_South_Base_Additional', 60)
	QAIM2SouthBase:AddBuildGroup('M2_QAI_OuterDef_D' .. Difficulty, 50)

    QAIM2SouthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalLand')
    QAIM2SouthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalAir')
    QAIM2SouthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalNaval')
    QAIM2SouthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIM2SouthBase_Nuke')
    QAIM2SouthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIM2SouthBase_HLRA')

    QAIM2SouthBaseAirAttacks()
    QAIM2SouthBaseLandAttacks()
end

function QAIM2SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- QAI M2 South Base Op AI, Air Attacks
    -- ------------------------------------

    -- sends 6, 12, 18 [bombers]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 6, 12, 18 [interceptors]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 6, 12, 18 [gunships, combat fighters]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 6, 12, 18 [gunships, combat fighters]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 6, 12, 18 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
		
    -- sends 6, 12, 18 [combat fighters, gunships]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 6, 12, 18 [air superiority] if hostiles have >= 6, 4, 2 strat bomber
    quantity = {6, 12, 18}
	trigger = {6, 4, 2}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 6, 9, 12 [heavy gunships]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])


	-- sends random [T2 + T3]
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildCount(Difficulty + 2)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	
	-- Maintains 1, 4, 9 [air superiority]
	for i = 1, Difficulty do
    quantity = {2, 4, 6}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_QAI_AirDefense' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_QAI_AirDef1_Chain',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
end

function QAIM2SouthBaseLandAttacks()
    local opai = nil

    -- -------------------------------------
    -- QAI M2 South Base Op AI, Land Attacks
    -- -------------------------------------
	
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyEast1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'LoyEastSiege'},
        }
    )
	opai:SetChildQuantity('MobileFlak', 8)
	
	opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyEast2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'LoyEastSiege'},
        }
    )
	opai:SetChildQuantity('HeavyTanks', 8)

	opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyWest1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'LoyWestSiege'},
        }
    )
	opai:SetChildQuantity('AmphibiousTanks', 8)
	
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyWest2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'LoyWestSiege'},
            Priority = 100,
        }
    )
	opai:SetChildQuantity('HeavyTanks', 8)

-------------------------------------------------------------------------------------------------------------------

    -- sends 6, 8, 12 [mobile missiles]
    quantity = {8, 16, 24}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    --opai:SetLockingStyle('None')

    -- sends 6, 8, 12 [amphibious tanks]
    quantity = {8, 16, 24}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    --opai:SetLockingStyle('None')

    -- sends random [T2 + T3]
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
	opai:SetChildCount(Difficulty + 3)
	opai:SetFormation('AttackFormation')

    -- sends 6, 8, 12 [heavy tanks]
    quantity = {8, 16, 24}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    -- sends random [T2 + T3]

    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
	opai:SetChildCount(Difficulty + 3)
	opai:SetFormation('AttackFormation')

    -- sends 6, 8, 10 [mobile flak]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    -- sends 6, 8, 12 [mobile flak, mobile shields]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    -- sends 6, 8, 12 [siege bots]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
		
	-- sends 6, 8, 12 [heavy bots]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    -- sends 6, 8, 10 [mobile flak]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])

    -- sends 4, 6, 8 [mobile heavy artillery]
    quantity = {6, 12, 18}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
end