----------------------------------------------------------------------------
--  File     : /maps/X1CA_002/X1CA_002_m1orderai.lua
--  Author(s): Jessica St. Croix
--
--  Summary  : Order army AI for Mission 1 - X1CA_002
--
--  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
----------------------------------------------------------------------------
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

--------
--Locals
--------
local Player1 = 1
local Order = 2
local Loyalist = 4
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local MexT2T3 = {
	Aeon = (categories.uab1202 + categories.uab1302),
	UEF = (categories.ueb1202 + categories.ueb1302),
	Cybran = (categories.urb1202 + categories.urb1302),
}
	

-- -------------
-- Base Managers
-- -------------
local OrderM1MainBase = BaseManager.CreateBaseManager()
local OrderM1ResourceBase = BaseManager.CreateBaseManager()

function OrderM1MainBaseAI()

    -- ------------------
    -- Order M1 Main Base
    -- ------------------
    OrderM1MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_Order_MainBase', 'Order_M1_Order_MainBase_Marker', 75, {M1_Order_MainBase = 100})
	OrderM1MainBase:StartNonZeroBase({4, 6, 8})
	OrderM1MainBase:SetMaximumConstructionEngineers(8)
    OrderM1MainBase:SetActive('AirScouting', true)
    OrderM1MainBase:SetActive('LandScouting', true)
    OrderM1MainBase:SetBuild('Shields', false)

    --OrderM1MainBaseAirAttacks()
    --OrderM1MainBaseLandAttacks()
	ScenarioFramework.CreateTimerTrigger(OrderM1MainBaseAirAttacks, 180)
	ScenarioFramework.CreateTimerTrigger(OrderM1MainBaseLandAttacks, 210)
end

function OrderM1MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

	--Air Atttacks
    -- Sends 4, 6, 8 [gunships, interceptors] Mass if Player has >= 6 T2/T3 mass extractors
	for i = 1, 2 do
    quantity = {4, 6, 8}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttackMass1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Order_MassArea_Chain',
            },
            Priority = 101,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 6, (MexT2T3.Aeon + MexT2T3.UEF + MexT2T3.Cybran), '>='})
	end
	
    -- sends 4, 6, 8 [gunships, interceptors] basic
	for i = 1, 2 do
    quantity = {4, 6, 8}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttackBasic1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 101,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, quantity[Difficulty])
	end

    -- sends 4, 6, 8 [bombers]
    quantity = {4, 6, 8}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])

    -- sends 4, 6, 8 [gunships, combat fighter]
    quantity = {4, 6, 8}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 3, 4, 6 [interceptors]
    quantity = {3, 4, 6}
    trigger = {15, 10, 10}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	
    -- sends 3, 4, 6 [bombers] if player has >= 50, 40, 30 structures
    quantity = {3, 4, 6}
    trigger = {50, 40, 30}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL, '>='})

    -- sends 3, 4, 6 [gunships] if player has >= 30, 20, 15 T2/T3 structures
    quantity = {3, 4, 6}
    trigger = {30, 20, 15}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1, '>='})

    -- sends 3, 4, 6 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {3, 4, 6}
    trigger = {75, 60, 40}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 4, 6, 8 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {4, 6, 8}
    trigger = {75, 60, 40}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 6, 8 [combat fighter, gunships] if player has >= 40, 30, 20 T2/T3 air units
    quantity = {4, 6, 8}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.AIR) - categories.TECH1 , '>='})

    -- sends 4, 8, 12 [gunships]
    quantity = {4, 8, 12}
    trigger = {50, 40, 30}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 4, 6, 8 [combat fighter] if player has >= 1 strat bomber
    quantity = {4, 8, 12}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 4, 6, 9 [gunships] if player has >= 300, 250, 200 units
    quantity = {4, 6, 10}
    trigger = {300, 250, 200}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense
        opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirDefense',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Order_BasePatrol_Air_Chain',
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('Interceptors', 12)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		
        opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirDefense2',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Order_BasePatrol_Air_Chain',
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('CombatFighters', 12)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function OrderM1MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -----------------------------------
    -- Order Main Base Op AI, Land Attacks
    -- -----------------------------------
	
    -- sends [random]
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttackBasic1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')

    -- sends 4, 6, 8 [light bots]
    quantity = {4, 6, 8}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    --opai:SetChildQuantity('LightBots', quantity[Difficulty])
	opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    -- sends [random]

    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttackBasic2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
   
    -- sends 4, 5, 10 [light artillery]
    quantity = {4, 6, 10}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
	
    -- sends 4, 5, 10 [mobile aa]
    quantity = {4, 6, 10}
	
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])

    -- sends 4, 4, 10 [light tanks, heavy tanks]
    quantity = {4, 8, 12}
    trigger = {20, 15, 10}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])

    -- sends 4, 6, 10 [light artillery, mobile missiles]
    quantity = {4, 6, 10}
    trigger = {12, 10, 8}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    -- sends 4, 6, 10 [light artillery, mobile missiles]
    quantity = {4, 6, 10}
    trigger = {90, 80, 70}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack8',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    -- sends 10, 12, 14 [mobile aa, mobile shields]
    quantity = {10, 12, 14}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileAntiAir', 'MobileShields'}, quantity[Difficulty])

    -- sends 10, 12, 14 [mobile flak, mobile shields]
    quantity = {10, 12, 14}
    trigger = {60, 50, 40}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])

    -- sends 6, 8, 10 [amphibious tanks, light tanks]
    quantity = {6, 8, 10}
	
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])

    -- sends 10, 12, 14 [mobile flak, mobile shields]
    quantity = {10, 12, 14}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])

    -- sends 10, 12, 14 [mobile missiles, light artillery]
    quantity = {10, 12, 14}
    trigger = {300, 250, 200}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])

    -- sends 1, 2, 3 [Siege Bots]
    quantity = {2, 4, 6}
    trigger = {150, 125, 75}		-- {90, 55, 35}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, quantity[Difficulty])

    -- Land Defense
	-- Changed to attack
    for i = 1, 2 do
        opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'}, --PatrolChain = {'M1_Order_BasePatrol_' .. i .. '_Chain'},
                },
                Priority = 100,
            }
        )
		opai:SetChildQuantity('HeavyTanks', 8)
    end
	
	quantity = {3, 6, 9}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_OrderFrontLandDefenseHeavy',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Order_BasePatrol_2_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
end

function OrderM1ResourceBaseAI()

    -- ----------------------
    -- Order M1 Resource Base
    -- ----------------------
    OrderM1ResourceBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_Order_ResourceBase', 'Order_M1_Resource_Base_Marker', 45, {M1_Order_ResourceBase = 100})
    OrderM1ResourceBase:StartNonZeroBase({1, 2, 3})
	OrderM1ResourceBase:SetMaximumConstructionEngineers(3)
	
	OrderM1ResourceBaseAirDefenses()
end

function OrderM1ResourceBaseAirDefenses()
    local opai = nil

    -- ----------------------------------------
    -- Order Resource Base Air Defenses
    -- ----------------------------------------
	for i = 1, Difficulty do
	opai = OrderM1ResourceBase:AddOpAI('AirAttacks', 'M1_Order_Resource_Air_Defense_' .. i,
		{
			MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
				PatrolChain = 'M1_Resource_Base_Air_Defense_Chain',
            },
			Priority = 120,
		}
    )
	opai:SetChildActive('All', false)
	opai:SetChildCount(Difficulty + 1)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'CombatFighters', 'Gunships'})
	end

end

function M1S1Response()
    OrderM1MainBase:SetActive('Shields', false)
end