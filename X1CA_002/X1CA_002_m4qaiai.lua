--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_m4qaiai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : QAI army AI for Mission 4 - X1CA_002
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--local BaseManager = import('/lua/ai/opai/basemanager.lua')
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
local QAIM4MainBase = BaseManager.CreateBaseManager()
local QAIM4NavalBase = BaseManager.CreateBaseManager()
local QAIM4NorthBase = BaseManager.CreateBaseManager()
local QAIM4CenterBase = BaseManager.CreateBaseManager()
local QAIM4SouthBase = BaseManager.CreateBaseManager()

function QAIM4MainBaseAI()

    -- ----------------
    -- QAI M4 Main Base
    -- ----------------
    QAIM4MainBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M4_Main_Base', 'QAI_M4_Main_Base_Marker', 80, {M4_Main_Base = 100})
	QAIM4MainBase:StartNonZeroBase({6, 9, 12})
	QAIM4MainBase:SetMaximumConstructionEngineers(12)

	QAIM4MainBase:AddExpansionBase('M4_Naval_Base', Difficulty)
	QAIM4MainBase:AddExpansionBase('QAI_M4_North_Base', Difficulty)
	QAIM4MainBase:AddExpansionBase('QAI_M4_Middle_Base', Difficulty)
	QAIM4MainBase:AddExpansionBase('QAI_M4_South_Base', Difficulty)
	
	QAIM4MainBase:AddBuildGroup('M4_HLRA_D' .. Difficulty, 50)

    QAIM4MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIM4MainBase_ExperimentalLand')
    QAIM4MainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIM4MainBase_ExperimentalAir')
    QAIM4MainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'QAIM4MainBase_ExperimentalNaval')
    QAIM4MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIM4MainBase_Nuke')
    QAIM4MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIM4MainBase_HLRA')
	
	QAIM4MainBaseAirDefense()
    QAIM4MainBaseAirAttacks()
    QAIM4MainBaseLandAttacks()
end

function QAIM4MainBaseAirDefense()
	local opai = nil
	local quantity = {6, 12, 18}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'CombatFighters'}
	
	--Maintains [6, 12, 18] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_QAIMain_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M4_Main_Base_Air_Def_Chain',
					},
					Priority = 260 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function QAIM4MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -------------------------------
    -- QAI M4 Base Op AI, Air Attacks
    -- -------------------------------
	
	
	--quantity = {1, 1, 1}
	--opai = QAIM4MainBase:AddOpAI('M4_QAI_Soulripper4',
        --{
            --Amount = quantity[Difficulty],
            --KeepAlive = true,
            --PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            --PlatoonData = {
                --PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain',},
            --},
            --MaxAssist = 3,
            --Retry = true,
        --}
    --)

    -- sends 6, 12, 18 [strat bombers]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks_Order1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
	opai:SetChildQuantity('StratBombers', quantity[Difficulty])

    -- sends 6, 12, 16 [gunships]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks_Order2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 200,
        }
    )
	opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 6, 12, 18 [air superiority] to Player
	quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks_Order',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 200,
        }
    )
	opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 6, 12, 18 [bombers], ([gunships] on hard)
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    else
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    -- sends 6, 12, 18 [interceptors], (air superiority on hard)
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    else
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
    --opai:SetLockingStyle('None')

    -- sends 6, 12, 18 [gunships, combat fighters]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    --opai:SetLockingStyle('None')

    -- sends 8, 16, 24 [gunships] if player has >= 100, 80, 60 mobile land, ([heavy gunships] on hard)
    quantity = {8, 16, 24}
    trigger = {100, 80, 60}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Player1', 'Cybran', 'UEF'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 6, 12, 18 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {6, 12, 18}
    trigger = {60, 40, 40}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 12, 18 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {6, 12, 18}
    trigger = {50, 30, 30}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 12, 18 [combat fighters, gunships]
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 5, 10, 15 [air superiority] if player has >= 1 strat bomber
    quantity = {5, 10, 15}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 8, 16, 24 [bombers, gunships]([heavy gunships] on hard)
    quantity = {8, 16, 24}
    trigger = {450, 400, 300}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
end

function QAIM4MainBaseLandAttacks()
    local opai = nil
    local quantity = nil
    local trigger = nil

    -- ------------------------------------
    -- QAI M4 Main Base Op AI, Land Attacks
    -- ------------------------------------

    -- builds monkey defense
	quantity = {1, 2, 3}
    opai = QAIM4MainBase:AddOpAI('UNIT_666',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Main_Base_East_Def_Chain',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )
	
	-- builds Monkey attacks
	quantity = {1, 2, 3}
	opai = QAIM4MainBase:AddOpAI('UNIT_666_1',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 3,
            Retry = true,
        }
    )

    -- sends 6, 8, 12 [siege bots] to order base
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Order_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Land_Attack_Full_Chain',
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 2, 4, 6 [heavy bots] to order base
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Order_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Land_Attack_Full_Chain',
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    -- sends 6, 10, 20 [heavy tanks]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    -- sends 6, 10, 20 [mobile missiles]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    --if(Difficulty > 1) then
        --opai:SetLockingStyle('None')
    --end

    -- sends 4, 6, 8 [mobile flak] if player has >= 60, 40, 40 mobile air
    quantity = {6, 12, 18}
    trigger = {60, 40, 40}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 110,
        }
    )
	opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 12, 18 [mobile flak] if player has >= 50, 30, 30 gunships
    quantity = {6, 12, 18}
    trigger = {50, 30, 30}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 110,
        }
    )
	opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 10, 20 [heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 1, 2, 3 [mobile flak] if player has >= 1 strat bomber
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 4, 8, 12 [mobile heavy artillery]
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',}
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])

    -- Land Defense
    -- Maintains 4, 8, 12 Heavy Tanks
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Main_Base_NW_Def_Chain',
                },
                Priority = 300,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    -- Maintains 4, 8, 12 Mobile Missiles
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Main_Base_NW_Def_Chain',
                },
                Priority = 300,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[Difficulty])
    end
end

function QAIM4NavalBaseAI()

    -- -----------------
    -- QAI M4 Naval Base
    -- -----------------
    QAIM4NavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M4_Naval_Base', 'QAI_M4_Naval_Marker', 80, {M4_Naval_Base = 100})
	QAIM4NavalBase:StartNonZeroBase({4, 6, 8})
	
	QAIM4NavalBase:SetMaximumConstructionEngineers(8)

    QAIM4NavalBaseNavalAttacks()
end

function QAIM4NavalBaseNavalAttacks()
    local opai = nil

    -- --------------------------------------
    -- QAI M4 Naval Base Op AI, Naval Attacks
    -- --------------------------------------

    -- sends [frigates]
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            --EnableTypes = {'Frigate'},
            MaxFrigates = 16 * Difficulty,
            MinFrigates = 8 * Difficulty,
            Priority = 100,
        }
    )

    -- sends [frigates, subs] if player has >= 8 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            --EnableTypes = {
                --'Frigate',
                --'Submarine',
            --},
            MaxFrigates = 24 * Difficulty,
            MinFrigates = 12 * Difficulty,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua','BrainsCompareNumCategory', 
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, 12, categories.NAVAL * categories.MOBILE, '>='})

    -- sends all but T3 if player has >= 2 T2/T3 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            MaxFrigates = 30 * Difficulty,
            MinFrigates = 15 * Difficulty,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory', 
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, 3, (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends all but T3 if player has >= 6 T2/T3 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            MaxFrigates = 48 * Difficulty,
            MinFrigates = 24 * Difficulty,
            Priority = 130,
        }
    )
    --opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory', 
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, 6, (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})
end

function QAIM4NorthBaseAI()

    -- -----------------
    -- QAI M4 North Base
    -- -----------------
    QAIM4NorthBase:Initialize(ArmyBrains[QAI], 'QAI_M4_North_Base', 'QAI_M4_North_Base', 50, {M4_QAI_North_Base = 100})
    QAIM4NorthBase:StartNonZeroBase(4)
	QAIM4NorthBase:SetMaximumConstructionEngineers(4)
	
    QAIM4NorthBaseLandAttacks()
	QAIM4NorthBaseAirAttacks()
end

function QAIM4NorthBaseLandAttacks()
    local opai = nil
	local quantity = {6, 9, 12}

    -- -------------------------------------
    -- QAI M4 North Base Op AI, Land Attacks
    -- -------------------------------------

    -- Land Attack
    opai = QAIM4NorthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_North_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_QAI_AttackOrder_Land1_Chain', 'M4_QAI_AttackOrder_Land2_Chain',},
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end

function QAIM4NorthBaseAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- QAI M4 Center Base Op AI, Air Attacks
    -- -------------------------------------

    -- Air Attack	
	opai = QAIM4NorthBase:AddOpAI('AirAttacks', 'M4_AirAttack_North1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildCount(Difficulty + 1)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end

function QAIM4CenterBaseAI()

    -- ------------------
    -- QAI M4 Center Base
    -- ------------------
    QAIM4CenterBase:Initialize(ArmyBrains[QAI], 'QAI_M4_Middle_Base', 'QAI_M4_Middle_Base', 45, {M4_QAI_Middle_Base = 100})
    QAIM4CenterBase:StartNonZeroBase(4)
	
	QAIM4CenterBase:SetMaximumConstructionEngineers(4)

    QAIM4CenterBaseAirAttacks()
    QAIM4CenterBaseLandAttacks()
end

function QAIM4CenterBaseAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- QAI M4 Center Base Op AI, Air Attacks
    -- -------------------------------------

    -- Air Attack	
	opai = QAIM4CenterBase:AddOpAI('AirAttacks', 'M4_AirAttack_Center1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildCount(Difficulty + 1)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end

function QAIM4CenterBaseLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- QAI M4 Center Base Op AI, Land Attacks
    -- --------------------------------------

     -- Land Attack
	opai = QAIM4CenterBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Center_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_QAI_AttackOrder_Land1_Chain', 'M4_QAI_AttackOrder_Land2_Chain',},
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end

function QAIM4SouthBaseAI()

    -- -----------------
    -- QAI M4 South Base
    -- -----------------
    QAIM4SouthBase:Initialize(ArmyBrains[QAI], 'QAI_M4_South_Base', 'QAI_M3_South_Base', 45, {M4_QAI_South_Base = 100})
    QAIM4SouthBase:StartNonZeroBase(4)
	QAIM4SouthBase:SetMaximumConstructionEngineers(4)
	
	--QAIM4SouthBase:AddBuildGroup('M4_QAI_Middle_Base', 90)

    QAIM4SouthBaseAirAttacks()
    QAIM4SouthBaseLandAttacks()
end

function QAIM4SouthBaseAirAttacks()
    local opai = nil

    -- ------------------------------------
    -- QAI M4 South Base Op AI, Air Attacks
    -- ------------------------------------

    -- Air Attack
    opai = QAIM4SouthBase:AddOpAI('AirAttacks', 'M4_AirAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildCount(Difficulty + 1)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end

function QAIM4SouthBaseLandAttacks()
    local opai = nil

    -- -------------------------------------
    -- QAI M4 South Base Op AI, Land Attacks
    -- -------------------------------------

    -- Land Attack
    opai = QAIM4SouthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain',},
            },
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetLockingStyle('BuildTimer', {LockTimer = 36 / Difficulty})
end