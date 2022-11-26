--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m4seraphimai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : Seraphim army AI for Mission 4 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ThisFile = '/maps/X1CA_001/X1CA_001_m4seraphimai.lua'
local CFFileName = '/maps/X1CA_001/X1CA_001_CustomFunctions.lua'

-- ------
-- Locals
-- ------
local Seraphim = 2
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local SeraphimM4NorthMainBase = BaseManager.CreateBaseManager()
local SeraphimM4SouthMainBase = BaseManager.CreateBaseManager()
local SeraphimM4AirMainBase = BaseManager.CreateBaseManager()
local SeraphimM4ForwardOne = BaseManager.CreateBaseManager()
local SeraphimM4ForwardTwo = BaseManager.CreateBaseManager()
local SeraphimM4NavalBase = BaseManager.CreateBaseManager()

function SeraphimM4NorthMainBaseAI()

      -----------------------------
    -- Seraphim M4 North Main Base
    -----------------------------
    SeraphimM4NorthMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_North_Base_Main', 'Seraphim_M3_North_Base_Marker', 60, {M3_North_Base_Main = 100,})
    SeraphimM4NorthMainBase:StartNonZeroBase({4, 6, 8})
	SeraphimM4NorthMainBase:SetMaximumConstructionEngineers(8)
	
    ArmyBrains[Seraphim]:PBMSetCheckInterval(15)

    SeraphimM4NorthMainBaseLandAttacks()
end

function SeraphimM4NorthMainBaseLandAttacks()
    local opai = nil
	quantity = {8, 16, 24}
	
    -- ------------------------------------------
    -- Seraphim M4 North Main Op AI, Land Attacks
    -- ------------------------------------------
	
	-- sends Ythota's
    opai = SeraphimM4NorthMainBase:AddOpAI('M4_Incarna_2',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            MaxAssist = 3,
            Retry = true,
        }
    )

    -- sends [siege bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile missiles, heavy bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'HeavyBots'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile flak, heavy bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'HeavyBots'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})
end

function SeraphimM4SouthMainBaseAI()

    -- ---------------------------
    -- Seraphim M4 South Main Base
    -- ---------------------------
	SeraphimM4SouthMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_South_Base_Main', 'Seraphim_M3_South_Base_Marker', 50, {M3_South_Base_Main = 100,})
    SeraphimM4SouthMainBase:StartNonZeroBase({4, 6, 8})
	SeraphimM4SouthMainBase:SetMaximumConstructionEngineers(8)
	SeraphimM4SouthMainBase:AddBuildGroup('M3_Middle_Defenses_D3', 90)

	SeraphimM4SouthMainBase:AddExpansionBase('M3_Seraph_Forward_One', Difficulty)
	SeraphimM4SouthMainBase:AddExpansionBase('M3_Seraph_Forward_Two', Difficulty)

    SeraphimM4SouthMainBaseLandAttacks()
end

function SeraphimM4SouthMainBaseLandAttacks()
    local opai = nil
	quantity = {8, 16, 24}
    -- ------------------------------------------
    -- Seraphim M4 South Main Op AI, Land Attacks
    -- ------------------------------------------
	
    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile missiles]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile flak, light bots]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})
end

function SeraphimM4AirMainBaseAI()

    -- -------------------------
    -- Seraphim M4 Air Main Base
    -- -------------------------
    SeraphimM4AirMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Air_Base_Main', 'Seraphim_M3_Air_Base_Marker', 55, {M3_Air_Base_Main = 100,})
    SeraphimM4AirMainBase:StartNonZeroBase({4, 8, 10})
    SeraphimM4AirMainBase:SetActive('AirScouting', true)
	
	SeraphimM4AirMainBase:SetMaximumConstructionEngineers(10)
	SeraphimM4AirMainBase:SetConstructionAlwaysAssist(true)
	
	--SeraphimM4AirMainBase:SetACUUpgrades({'T3Engineering', 'DamageStabilizationAdvanced', 'RateOfFire'}, false)
	
	SeraphimM4AirMainBase:AddExpansionBase('M3_South_Base_Main', Difficulty)
	SeraphimM4AirMainBase:AddExpansionBase('M3_North_Base_Main', Difficulty)
	SeraphimM4AirMainBase:AddExpansionBase('M3_Naval_Base', Difficulty)

    SeraphimM4AirMainBaseAirAttacks()
end

function SeraphimM4AirMainBaseAirAttacks()
    local opai = nil
    local quantity = {}

    -- --------------------------------------------
    -- Seraphim M4 Air Main Base Op AI, Air Attacks
    -- --------------------------------------------

	
	-- Attacks Land Exp and Fort Clarke Structure
	quantity = {5, 10, 15}
	opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainBomberAttack1',
        {
            MasterPlatoonFunction = {ThisFile, 'SeraphimAirBomberAI'},
            Priority = 300,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	--opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
	
    -- -- Attacks Fort Clarke

    -- sends [Air Superiority]
    quantity = {10, 20, 30}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    -- opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [gunships]
    quantity = {10, 20, 30}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    --opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [gunships]
	quantity = {10, 20, 30}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters'}, quantity[Difficulty])
    -- opai:SetLockingStyle('BuildTimer', {LockTimer = 60})

    -- sends 10, 20, 30 [gunships]
    quantity = {10, 20, 30}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_Continuous_AirMainAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
         }
    )
    opai:SetChildQuantity({'Gunships'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60 / Difficulty})

    -- -- sends 10, 20, 30 [gunships, bombers]
    quantity = {10, 20, 30}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_Continuous_AirMainAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60 / Difficulty})

    -- -- Defense Patrols

    -- [air superiority]
	for i = 1, Difficulty do
		opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMain_ASF_Defense_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'Seraph_Main_NearAirDef_Chain',
				},
				Priority = 450,
			}
		)
		opai:SetChildQuantity('AirSuperiority', 10)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end

	for i = 1, Difficulty do
		opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMain_BomberDefense_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'Seraph_Main_NearAirDef_Chain', --'Seraph_Main_MidAirDef_Chain'
				},
				Priority = 300,
			}
		)
		opai:SetChildQuantity('StratBombers', 10)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function SeraphimM4ForwardOneAI()

    -- ---------------------
    -- Seraphim M4 Forward 1
    -- ---------------------
    SeraphimM4ForwardOne:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Forward_One', 'Seraphim_M3_Forward_One_Base_Marker', 35, {M3_Seraph_Forward_One = 100,})
    SeraphimM4ForwardOne:StartNonZeroBase({1, 2, 3})

    SeraphimM4ForwardOneLandAttacks()
end

function SeraphimM4ForwardOneLandAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Seraphim M4 Foward 1 Op AI, Land Attacks
    -- ----------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile missiles, light artillery]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile flak, light bots]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'HeavyBots'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})
end

function SeraphimM4ForwardTwoAI()

    -- ---------------------
    -- Seraphim M4 Forward 2
    -- ---------------------
    SeraphimM4ForwardTwo:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Forward_Two', 'Seraphim_M3_Forward_Two_Base_Marker', 35, {M3_Seraph_Forward_Two = 100,})
    SeraphimM4ForwardTwo:StartNonZeroBase({1, 2, 3})

    SeraphimM4ForwardTwoLandAttacks()
end

function SeraphimM4ForwardTwoLandAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Seraphim M4 Foward 2 Op AI, Land Attacks
    -- ----------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile missiles, light artillery]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})

    -- sends [mobile flak, light bots]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'HeavyTanks'}, 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 45 / Difficulty})
end

function SeraphimM4NavalBaseAI()

    -- ----------------------
    -- Seraphim M4 Naval Base
    -- ----------------------
    SeraphimM4NavalBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Naval_Base', 'M3_Naval_Base_Marker', 70, {M3_Naval_Base = 100,})
    SeraphimM4NavalBase:StartNonZeroBase({2, 3, 4})
	SeraphimM4NavalBase:SetMaximumConstructionEngineers(4)

    SeraphimM4NavalBaseNavalAttacks()
end

function SeraphimM4NavalBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    -- -------------------------------------------
    -- Seraphim M4 Naval Base Op AI, Naval Attacks
    -- -------------------------------------------

    -- sends 3-9 / 4-12 frigate power of [frigates]
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 4 * Difficulty,
            MinFrigates = 3 * Difficulty,
            Priority = 100,
        }
    )

    -- sends 12 - 48 frigate power of all but T3
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 16 * Difficulty,
            MinFrigates = 4 * Difficulty,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 30 - 60 frigate power of all but T3
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttackC1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 20 * Difficulty,
            MinFrigates = 10 * Difficulty,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 24 - 60 frigate power of all but T3
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttackC2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 20 * Difficulty,
            MinFrigates = 8 * Difficulty,
            Priority = 100,
        }
    )

    -- sends 6-12 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 12 * Difficulty,
            MinFrigates = 6 * Difficulty,
            Priority = 110,
        }
    )
    --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        --{'default_brain', {'Player1', 'Aeon', 'Cybran'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 9-15 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 12 * Difficulty,
            MinFrigates = 6 * Difficulty,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainGreaterThanOrEqualNumCategory',
        --{'default_brain', {'Player1', 'Aeon', 'Cybran'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 12-18 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    trigger = {6, 5, 4}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 15 * Difficulty,
            MinFrigates = 9 * Difficulty,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        --{'default_brain', {'Player1', 'Aeon', 'Cybran'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 20 - 50 frigate power if player has >= 5, 4, 3 T3 boats
    trigger = {5, 4, 3}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 24 * Difficulty,
            MinFrigates = 12 * Difficulty,
            Priority = 140,
        }
    )
    --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        --{'default_brain', {'Player1', 'Aeon', 'Cybran'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3})

    -- Naval Defense
    for i = 1, Difficulty do
        opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Seraph_Naval_Chain',
                },
                MaxFrigates = 9 * Difficulty,
                MinFrigates = 3 * Difficulty,
                Priority = 200,
            }
        )
        opai:SetChildActive('T3', false)
    end
end

function SeraphimAirBomberAI(platoon)
    local fatboys = ArmyBrains[UEF]:GetListOfUnits(categories.uel0401, false)
    local num = table.getn(fatboys)
    if(num > 0) then
        for i = 1, num do
            IssueAttack(platoon:GetPlatoonUnits(), fatboys[i])
        end
		platoon:AggressiveMoveToLocation(ScenarioInfo.ClarkeMonument:GetPosition())
		-- IssueAttack(platoon:GetPlatoonUnits(), ScenarioInfo.ClarkeMonument)
	else
		platoon:AggressiveMoveToLocation(ScenarioInfo.ClarkeMonument:GetPosition())
		-- IssueAttack(platoon:GetPlatoonUnits(), ScenarioInfo.ClarkeMonument)
	end
end