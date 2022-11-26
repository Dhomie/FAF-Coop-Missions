--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m3orderai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : Order army AI for Mission 3 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CFFileName = '/maps/X1CA_001/X1CA_001_CustomFunctions.lua'

-- ------
-- Locals
-- ------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local OrderM3MainBase = BaseManager.CreateBaseManager()
local OrderM3NavalBase = BaseManager.CreateBaseManager()
local OrderM3ExpansionBase = BaseManager.CreateBaseManager()

function OrderM3MainBaseAI()

    -- ------------------
    -- Order M3 Main Base
    -- ------------------
    OrderM3MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Main_Base', 'M2_Main_Base_Marker', 75, {M2_Main_Base = 100})
    OrderM3MainBase:StartNonZeroBase({8, 10, 12})
	OrderM3MainBase:SetMaximumConstructionEngineers(12)
    OrderM3MainBase:SetActive('AirScouting', true)
    OrderM3MainBase:SetActive('LandScouting', true)
	ArmyBrains[Order]:PBMSetCheckInterval(10)
	
	--OrderM3MainBase:SetACUUpgrades({'CrysalisBeam', 'ShieldHeavy', 'HeatSink'}, true)

	OrderM3MainAirDefense()
    OrderM3MainBaseAirAttacks()
    OrderM3MainBaseLandAttacks()
end

function OrderM3MainAirDefense()
    local opai = nil
	local quantity = {10, 20, 30}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers'}
	
	--Maintains [10, 20, 30] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_OrderMain_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_Order_AirDefCombined_Chain',
					},
					Priority = 260 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function OrderM3MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- --------------------------------------
    -- Order M3 Main Base Op AI - Air Attacks
    -- --------------------------------------
	
	opai = OrderM3MainBase:AddOpAI('M3_Order_Czar',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 1,
            Retry = true,
            --WaitSecondsAfterDeath = 120 / Difficulty,
        }
    )

    -- sends 10, 20, 30 [bombers]
    quantity = {10, 20, 30}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 10, 20, 30 [combat fighters]
    quantity = {10, 20, 30}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

    -- sends 10, 20, 30 [gunships]
    quantity = {10, 20, 30}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 10, 20, 20 [gunships, combat fighter] if player has >= 15, 10, 5 T2/T3 AA
    quantity = {10, 20, 30}
    trigger = {15, 10, 5}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], (categories.ANTIAIR * categories.STRUCTURE) - categories.TECH1, '>='})

    -- sends 10, 20, 30 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {10, 20, 30}
    trigger = {100, 80, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack5',
        {
            MasterPlatoonFunction = {CFFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {categories.LAND * categories.MOBILE},
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 10, 20, 30 [combat fighters, air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {10, 20, 30}
    trigger = {100, 80, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack6',
        {
            MasterPlatoonFunction = {CFFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {categories.AIR * categories.MOBILE},
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 10, 20, 30 [combat fighters, air superiority] if player has >= 60, 50, 40 gunships
    quantity = {10, 20, 30}
    trigger = {80, 70, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack7',
        {
            MasterPlatoonFunction = {CFFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {categories.uaa0203 + categories.uea0203 + categories.ura0203 + categories.uea0305 + categories.xaa0305},
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203 + categories.uea0305 + categories.xaa0305, '>='})

    -- sends 10, 20, 30 [torpedo bombers] if player has >= 30, 20, 10 boats
    quantity = {10, 20, 30}
    trigger = {30, 20, 10}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 10, 20, 30 [heavy gunships] if player has >= 80, 70, 60 T3 units
    quantity = {10, 20, 30}
    trigger = {80, 70, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'HeavyGunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 10, 20, 30 [air superiority] if player has >= 15, 10, 5 strat bomber
    quantity = {10, 20, 30}
    trigger = {15, 10, 5}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack10',
        {
            MasterPlatoonFunction = {CFFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {categories.uaa0304 + categories.uea0304 + categories.ura0304},
			},
            Priority = 140,
        }
    )
	opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 10, 20, 30 [bombers, heavy gunships, air superiority] if player has >= 800, 700, 600 units
    quantity = {10, 20, 30}
    trigger = {800, 700, 600}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Bombers', 'HeavyGunships', 'AirSuperiority'}, quantity[Difficulty])
    --if (Difficulty == 3) then
		--opai:SetLockingStyle('None')
    --end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
end

function OrderM3MainBaseLandAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M3 Main Base Op AI - Land Attacks
    -- ---------------------------------------

    -- sends 5, 10, 15 [light tanks, amphibious tanks, mobile flak]
    quantity = {5, 10, 15}
    opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_LandAttack_Chain', 'M3_Order_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
	--opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
    --opai:SetLockingStyle('None')

    -- sends engineers --> Disabled due to usage of T2 Engineers, some of which end up inserted as (T2) base manager Engineers
	-- TODO: Rework this
    --[[opai = OrderM3MainBase:AddOpAI('EngineerAttack', 'M3_EngAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Order_M2_IslandLand_Chain',
                LandingChain = 'Order_M2_IslandLand_Chain',
               TransportReturn = 'M2_Main_Base_Marker',
               Categories = {'STRUCTURE'},
            },
            Priority = 110,
      }
	)
    opai:SetChildActive('T1Transports', false)]]

    -- Rear Beach Land Patrols
    for i = 1, Difficulty do
        opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_Defense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_IslandLand_Chain',
                },
                Priority = 120,
            }
        )
		opai:SetChildQuantity('SiegeBots', 15)
    end

    -- Beach AA Patrols
    for i = 1, Difficulty do
        opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_Defense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_IslandLand_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'MobileFlak', 'HeavyBots'}, 10)
    end
end

function OrderM3NavalBaseAI()

    -- -------------------
    -- Order M3 Naval Base
    -- -------------------
	OrderM3MainBase:AddExpansionBase('M2_Naval_Base', Difficulty)
    OrderM3NavalBase:Initialize(ArmyBrains[Order], 'M2_Naval_Base', 'Order_M2_Naval_Base_Marker', 65, {M2_Naval_Base = 100})
    OrderM3NavalBase:StartNonZeroBase({3, 4, 5})
	OrderM3NavalBase:SetMaximumConstructionEngineers(5)

    OrderM3NavalBaseNavalAttacks()
end

function OrderM3NavalBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    -- ----------------------------------------
    -- Order M3 Naval Base Op AI, Naval Attacks
    -- ----------------------------------------
	
	--sends 1/2/3 Tempests
	opai = OrderM3NavalBase:AddOpAI('M3_Order_Tempest',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            MaxAssist = 1,
            Retry = true,
            --WaitSecondsAfterDeath = 120 / Difficulty,
        }
    )

    -- sends 3/9 - 9/27 frigate power of [frigates] if player has >= 5, 4, 3 boats
    trigger = {5, 4, 3}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 9 * Difficulty,
            MinFrigates = 3 * Difficulty,
            Priority = 100,
        }
    )
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 6/18 - 12/36 frigate power of [frigates, subs] if player has >= 20, 15, 10 boats
    trigger = {20, 15, 10}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 12 * Difficulty,
            MinFrigates = 6 * Difficulty,
            Priority = 110,
        }
    )
   opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 9-15 frigate power of [all] if player has >= 10, 8, 6 T2/T3 boats
    trigger = {10, 8, 6}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            MaxFrigates = 18 * Difficulty,
            MinFrigates = 9 * Difficulty,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 12/36 - 21/63 frigate power of [all but T3] if player has >= 20, 16, 12 T2/T3 boats
	trigger = {20, 16, 12}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            MaxFrigates = 21 * Difficulty,
            MinFrigates = 12 * Difficulty,
            Priority = 130,
        }
    )
    --opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Cybran', 'Aeon', 'UEF'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- Naval Defense
    for i = 1, Difficulty do
        opai = OrderM3NavalBase:AddNavalAI('M2_NavalDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'Order_M2_NavalBasePatrol_Chain', 'Order_M2_NavalBasePatrol2_Chain'},
                },
                MaxFrigates = 9 * Difficulty,
                MinFrigates = 6 * Difficulty,
                Priority = 150,
            }
        )
        opai:SetChildActive('T3', false)
    end
end

function OrderM3ExpansionBaseLandAttacks()
    local opai = nil
    local quantity = {}

    -- ---------------------------------------
	-- Order M3 Expansion Base Op AI - Land Attacks
    -- ---------------------------------------

	opai = OrderM3ExpansionBase:AddOpAI('M3_Order_GC',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 1,
            Retry = true,
			--WaitSecondsAfterDeath = 120 / Difficulty,
        }
    )

    --sends 4, 6, 8 [heavy bots]
    quantity = {4, 6, 8}
    opai = OrderM3ExpansionBase:AddOpAI('BasicLandAttack', 'M3_Town_Assault1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M3_SouthEastTown_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

	quantity = {2, 4, 8}
    opai = OrderM3ExpansionBase:AddOpAI('BasicLandAttack', 'M3_Town_Assault2',
		{
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
            PatrolChain = 'Order_M3_SouthEastTown_Chain',
            },
            Priority = 130,
        }
    )
	opai:SetChildQuantity({'MobileFlak', 'SiegeBots'}, quantity[Difficulty])

	quantity = {2, 4, 8}
    opai = OrderM3ExpansionBase:AddOpAI('BasicLandAttack', 'M3_Town_Assault3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M3_SouthEastTown_Chain',
            },
            Priority = 100,
		}
    )
    opai:SetChildQuantity({'MobileFlak', 'HeavyBots'}, quantity[Difficulty])
	opai:SetLockingStyle('None')
	
	quantity = {4, 8, 12}
    opai = OrderM3ExpansionBase:AddOpAI('BasicLandAttack', 'M3_Town_Assault4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M3_SouthEastTown_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
end

function OrderM3ExpansionBaseAI()

    -- -----------------------
    -- Order M3 Expansion Base
    -- -----------------------
    -- TODO: make sure this is working
	local EngineerCount = {3, 4, 5}
    OrderM3MainBase:AddExpansionBase('OrderM3ExpansionBase', 3)
    OrderM3ExpansionBase:InitializeDifficultyTables(ArmyBrains[Order], 'OrderM3ExpansionBase', 'Order_M2_Expansion_One_Marker', 55,
        {
			--M2_Main_Adapt_Lines = 110,
			M2_EOne_First = 100,
			M2_EOne_Second = 90,
			M2_EOne_Third = 80,
        }
    )
    OrderM3ExpansionBase:StartDifficultyBase({'M2_EOne_First'}, EngineerCount[Difficulty])
	OrderM3ExpansionBase:SetMaximumConstructionEngineers(5)
	--OrderM3ExpansionBaseLandAttacks()
	ScenarioFramework.CreateTimerTrigger(OrderM3ExpansionBaseLandAttacks, 420)
end

function M3DisableOrderBases()
    if(OrderM3MainBase) then
        OrderM3MainBase:SetBuild('Engineers', false)
        OrderM3MainBase:SetBuildAllStructures(false)
        OrderM3MainBase:SetActive('AirScouting', false)
        OrderM3MainBase:SetActive('LandScouting', false)
        OrderM3MainBase:BaseActive(false)
    end
	
	if(OrderM3NavalBase) then
        OrderM3NavalBase:SetBuild('Engineers', false)
        OrderM3NavalBase:SetBuildAllStructures(false)
        OrderM3NavalBase:BaseActive(false)
    end
	
	if(OrderM3ExpansionBase) then
        OrderM3ExpansionBase:SetBuild('Engineers', false)
        OrderM3ExpansionBase:SetBuildAllStructures(false)
        OrderM3ExpansionBase:BaseActive(false)
    end
end