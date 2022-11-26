--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m4uefai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : UEF army AI for Mission 4 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local MainScript = import('/maps/X1CA_001/X1CA_001_script.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/X1CA_001/X1CA_001_CustomFunctions.lua'

-- ------
-- Locals
-- ------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local FortClarke = BaseManager.CreateBaseManager()
local UEFM4ForwardOne = BaseManager.CreateBaseManager()
local UEFM4ForwardTwo = BaseManager.CreateBaseManager()
local UEFM4ExpansionOne = BaseManager.CreateBaseManager()
--local UEFM4ExpansionTwo = BaseManager.CreateBaseManager()

function FortClarkeAI()

    -- -----------
    -- Fort Clarke
    -- -----------
    FortClarke:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Fort_Clarke_Base', 'UEF_Fort_Clarke_Marker', 210, {UEF_Fort_Clarke_Base = 150,})
    FortClarke:StartNonZeroBase({12, 10, 8})
    FortClarke:SetMaximumConstructionEngineers(12)
	FortClarke:SetConstructionAlwaysAssist(true)
	
	ScenarioFramework.AddRestriction(UEF, categories.uel0105) -- UEF T1 Engineer
	
	FortClarke:SetSupportACUCount(1)
	FortClarke:SetSACUUpgrades({'Shield', 'AdvancedCoolingUpgrade', 'HighExplosiveOrdnance'}, false)

	FortClarke:AddBuildGroup('Bridge_Defenses_D1', 95)
	FortClarke:AddBuildGroup('Fort_Clarke_Eco_Expansion', 100)
	ScenarioFramework.CreateTimerTrigger(FortClarkeExpansionRebuilds, 210)
	--ScenarioFramework.CreateTimerTrigger(FortClarkeTransportAttacks, 720)
	
    ArmyBrains[UEF]:PBMSetCheckInterval(10)

    FortClarkeLandAttacks()
	FortClarkeAirDefense()
    FortClarkeAirAttacks()
end

function FortClarkeExpansionRebuilds()
    --FortClarke:AddBuildGroup('M3_Forward_One_D1', 90)
	--FortClarke:AddBuildGroup('M3_Forward_Two_D1', 80)
	FortClarke:AddExpansionBase('M3_Forward_One', 2)
	FortClarke:AddExpansionBase('M3_Forward_Two', 2)
end

function FortClarkeLandAttacks()
    local opai = nil

    -- -------------------------------
    -- Fort Clarke Op AI, Land Attacks
    -- -------------------------------

    -- sends 2 fatboys
    opai = FortClarke:AddOpAI('UEF_Fatboy_1',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'FatBoyBehavior'},
				PlatoonData = {
					BuildTable = {
						'del0204', 	--T2 Gatling Bot
						'uel0202',	--T2 Heavy Tank
						'uel0205',	--T2 Mobile Flak
						'uel0111',	--T2 MML
						'uel0307', 	--T2 Mobile Shield
						'uel0303',	--T3 Siege Bot
						'uel0304', 	--T3 Mobile Heavy Artillery
						'xel0305',	--T3 Heavy Bot
						'xel0306',	--T3 MML
						'delk002'	--T3 Mobile AA
					},
					Formation = 'AttackFormation',
					SitDistance = 130,
					UnitCount = 8
				},
            MaxAssist = 3,
            Retry = true,
            --WaitSecondsAfterDeath = 15,
        }
    )

    -- sends [siege bots, mobile shields, mobile missile platforms]
	local template = {
        'UEF_Land_Anti_Experimental_Platoon',
        'NoPlan',
        { 'xel0305', 1, 6, 'Attack', 'GrowthFormation' },	-- Siege Bots
        { 'xel0306', 1, 4, 'Attack', 'GrowthFormation' },	-- Mobile Missile Platforms
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },	-- Mobile Shields
    }
	local builder = {
        BuilderName = 'UEF_Anti_Experimental_Platoon',
        PlatoonTemplate = template,
		InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )
	
	template = {
        'UEF_Standard_T3_Land_Platoon',
        'NoPlan',
        { 'uel0303', 1, 4, 'Attack', 'GrowthFormation' },	-- Siege Bots
		{ 'xel0305', 1, 4, 'Attack', 'GrowthFormation' },	-- Heavy Bots
        { 'uel0304', 1, 2, 'Attack', 'GrowthFormation' },	--Heavy Mobile Artillery
		{ 'delk002', 1, 2, 'Attack', 'GrowthFormation' }, 	-- Heavy Mobile AA
		{ 'xel0305', 1, 2, 'Attack', 'GrowthFormation' },	-- Mobile Missile Platforms
		{ 'uel0307', 1, 6, 'Attack', 'GrowthFormation' },	-- Mobile Shields
    }
	builder = {
        BuilderName = 'UEF_Standard_T3_Land_Platoon',
        PlatoonTemplate = template,
		InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )
	
	
	template = {
        'UEF_Light_Land_Platoon',
        'NoPlan',
        { 'uel0303', 1, 2, 'Attack', 'GrowthFormation' },	-- Siege Bots
        { 'uel0202', 1, 4, 'Attack', 'GrowthFormation' },	-- Heavy Tanks
        { 'del0204', 1, 4, 'Attack', 'GrowthFormation' },	-- Range Bots
		{ 'uel0203', 1, 4, 'Attack', 'GrowthFormation' },	-- Amphibious Tanks
		{ 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },	-- Mobile Shields
    }
	builder = {
        BuilderName = 'UEF_Light_Land_Platoon',
        PlatoonTemplate = template,
		InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )
	
	opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeLandAttack6',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity({'SiegeBots', 'HeavyTanks'}, {8, 4})
	--opai:SetLockingStyle('None')

    -- [T3 AA] patrols
    for i = 1, 2 do
		for x = 1, 2 do
			opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeLandBasePatrol_' .. i .. x,
				{
					MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
					PlatoonData = {
						PatrolChain = 'UEF_M4_BasePatrol' .. i .. '_Chain',
					},
					Priority = 120,
				}
			)
			opai:SetChildQuantity('HeavyMobileAntiAir', 3)
		end
	end

    -- [heavy bots] patrols
    for i = 1, 2 do
        opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeFrontLandBasePatrol' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_UEF_BaseFrontPatrol_Chain',
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
    end
end

function FortClarkeAirDefense()
	local opai = nil
	local quantity = {24, 20, 16}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	--Maintains [24, 20, 16] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = FortClarke:AddOpAI('AirAttacks', 'M4_FortClarke_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M4_UEF_AirPatrol1_Chain',
					},
					Priority = 300 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end
end

function FortClarkeAirAttacks()
    local opai = nil

	-- --------------------------------
    -- Fort Clarke Op AI, Orbital Laser
    -- --------------------------------

	--[[opai = FortClarke:AddOpAI('Orbital_Laser',
        {
            Amount = 1,
            KeepAlive = true,
			PlatoonAIFunction = {MainScript, 'UEF_Satellite_Ping'},
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 15,
        }
    )]]
	
	--[[opai = FortClarke:AddOpAI('UEF_Mavor',
        {
            Amount = 1,
            KeepAlive = true,
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 15 * Difficulty,
        }
    )]]

    -- ------------------------------
    -- Fort Clarke Op AI, Air Attacks
    -- ------------------------------
	--sends [bombers]
	opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Bombers', 24)
	
	--sends [interceptors]
	opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Interceptors', 24)

    -- sends [gunships]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 16)
    --opai:SetLockingStyle('None')

    -- sends [combat fighters]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', 16)

    -- sends [air superiority]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 8)
	
	-- sends [heavy gunships]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', 8)
	
	--sends [strategic bombers]
	opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', 8)
end

function FortClarkeTransportAttacks()
    local opai = nil

	for i = 1, 2 do
    opai = FortClarke:AddOpAI('EngineerAttack', 'M4_UEF_TransportBuilder_' .. i,
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_UEF_Transport_AttackChain',
            LandingChain = 'M4_UEF_Transport_LandingChain',
            TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            --Categories = {'STRUCTURES'},
        },
        Priority = 250,
    })
	opai:SetChildQuantity('T3Transports', 2)
	end
 
    opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_UEF_Transport_AttackChain',
            LandingChain = 'M4_UEF_Transport_LandingChain',
            TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
        },
        Priority = 120,
    })
    opai:SetChildQuantity('SiegeBots', 6)
	
    	opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack2', -- .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M4_UEF_Transport_AttackChain',
                LandingChain = 'M4_UEF_Transport_LandingChain',
                TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            },
            Priority = 110,
        })
        opai:SetChildQuantity('HeavyTanks', 12)
		
		opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack3', -- .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M4_UEF_Transport_AttackChain',
                LandingChain = 'M4_UEF_Transport_LandingChain',
                TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            },
            Priority = 100,
        })
        opai:SetChildQuantity('MobileMissiles', 12)
end

function UEFM4ForwardOneAI()

    -- ------------------
    -- UEF Forward Base 1
    -- ------------------
    UEFM4ForwardOne:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Forward_One', 'UEF_M3_Forward_One_Base_Marker', 45, {M3_Forward_One = 100,})
    UEFM4ForwardOne:StartNonZeroBase({5, 4, 3})
	
	UEFM4ForwardOne:AddExpansionBase('UEF_M4_Expansion_One', 3)
	
    UEFM4ForwardOneLandAttacks()
    UEFM4ForwardOneAirAttacks()
end

function UEFM4ForwardOneLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- UEF M4 Forward One Op AI, Land Attacks
    -- --------------------------------------

    -- sends [heavy tanks]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)

    -- sends [mobile missiles, light artillery]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 4)

    -- sends [mobile flak]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', 4)
	
	-- sends [range bots]
	opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('RangeBots', 4)
	
	opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', 2)
	
	opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', 2)
end

function UEFM4ForwardOneAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- UEF M4 Forward One Op AI, Air Attacks
    -- -------------------------------------

    -- sends [gunships, interceptors]
    opai = UEFM4ForwardOne:AddOpAI('AirAttacks', 'UEF_ForwardOne_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 6)
	
	opai = UEFM4ForwardOne:AddOpAI('AirAttacks', 'UEF_ForwardOne_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 9)
	
	opai = UEFM4ForwardOne:AddOpAI('AirAttacks', 'UEF_ForwardOne_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 9)

end

function UEFM4ForwardTwoAI()

    -- ------------------
    -- UEF Forward Base 2
    -- ------------------
    UEFM4ForwardTwo:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Forward_Two', 'UEF_M3_Forward_Two_Base_Marker', 60, {M3_Forward_Two = 100,})
    UEFM4ForwardTwo:StartNonZeroBase({4, 3, 2})

	--UEFM4ForwardTwo:AddExpansionBase('UEF_M4_Expansion_Two', 3)
	UEFM4ForwardTwo:AddBuildGroup('M4_Northern_Defensive_Line', 90)

    UEFM4ForwardTwoLandAttacks()
end

function UEFM4ForwardTwoLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- UEF M4 Forward Two Op AI, Land Attacks
    -- --------------------------------------

    -- sends [heavy bots]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 115,
        }
    )
    opai:SetChildQuantity('HeavyBots', 4)

    -- sends [mobile flak]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', 8)

    -- sends [mobile missiles]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 8)

		-- sends [siege bots]
	opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack5',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('SiegeBots', 4)

    -- sends [heavy tanks]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 8)
	
	-- sends [range bots]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('RangeBots', 8)
	
	-- sends [heavy mobile AA]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', 4)
end

function UEFM4ExpansionOneAI()

    -- ------------------
    -- UEF Expansion Base 1
    -- ------------------
    --UEFM4ExpansionOne:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_M4_Expansion_One', 'UEF_M4_Expansion_One_Base_Marker', 60, {M4_UEF_Expansion1 = 100,})
	UEFM4ExpansionOne:Initialize(ArmyBrains[UEF], 'UEF_M4_Expansion_One', 'UEF_M4_Expansion_One_Base_Marker', 60, {M4_UEF_Expansion1_D1 = 100,})
    UEFM4ExpansionOne:StartEmptyBase({5, 4, 3})
	
	UEFM4ExpansionOne:AddBuildGroup('M4_Southern_Defensive_Line', 90)

    UEFM4ExpansionOneLandAttacks()
	UEFM4ExpansionOneAirAttacks()
end

function UEFM4ExpansionOneLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- UEF M4 Forward One Op AI, Land Attacks
    -- --------------------------------------

    -- sends [heavy tanks]
    opai = UEFM4ExpansionOne:AddOpAI('BasicLandAttack', 'UEF_ExpOne_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 6)

    -- sends [mobile missiles]
    opai = UEFM4ExpansionOne:AddOpAI('BasicLandAttack', 'UEF_ExpOne_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 6)

    -- sends [T3 AA]
    opai = UEFM4ExpansionOne:AddOpAI('BasicLandAttack', 'UEF_ExpOne_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', 4)
	
	-- sends [siege bots]
	opai = UEFM4ExpansionOne:AddOpAI('BasicLandAttack', 'UEF_ExpOne_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', 4)
end

function UEFM4ExpansionOneAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- UEF M4 Forward One Op AI, Air Attacks
    -- -------------------------------------

    -- sends [gunships, interceptors]
    opai = UEFM4ExpansionOne:AddOpAI('AirAttacks', 'UEF_ExpOne_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 6)
	
	opai = UEFM4ExpansionOne:AddOpAI('AirAttacks', 'UEF_ExpOne_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', 6)
	
	opai = UEFM4ExpansionOne:AddOpAI('AirAttacks', 'UEF_ExpOne_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 3)

end

function UEFM4ExpansionTwoAI()

    -- ------------------
    -- UEF Expansion Base 2
    -- ------------------
    --UEFM4ExpansionTwo:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_M4_Expansion_Two', 'UEF_M4_Expansion_Two_Base_Marker', 60, {M4_UEF_Expansion2 = 100,})
	UEFM4ExpansionTwo:Initialize(ArmyBrains[UEF], 'UEF_M4_Expansion_Two', 'UEF_M4_Expansion_Two_Base_Marker', 60, {M4_UEF_Expansion2_D1 = 100,})
    UEFM4ExpansionTwo:StartEmptyBase({5, 4, 3})

    UEFM4ExpansionTwoLandAttacks()
	UEFM4ExpansionTwoAirAttacks()
end

function UEFM4ExpansionTwoLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- UEF M4 Forward One Op AI, Land Attacks
    -- --------------------------------------

    -- sends [heavy tanks]
    opai = UEFM4ExpansionTwo:AddOpAI('BasicLandAttack', 'UEF_ExpTwo_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 6)

    -- sends [mobile missiles]
    opai = UEFM4ExpansionTwo:AddOpAI('BasicLandAttack', 'UEF_ExpTwo_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 6)

    -- sends [T3 AA]
    opai = UEFM4ExpansionTwo:AddOpAI('BasicLandAttack', 'UEF_ExpTwo_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', 4)
	
	-- sends [siege bots]
	opai = UEFM4ExpansionTwo:AddOpAI('BasicLandAttack', 'UEF_ExpTwo_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', 4)
end

function UEFM4ExpansionTwoAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- UEF M4 Forward One Op AI, Air Attacks
    -- -------------------------------------

    -- sends [gunships]
    opai = UEFM4ExpansionTwo:AddOpAI('AirAttacks', 'UEF_ExpTwo_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 6)
	
	-- sends [fighter bombers]
	opai = UEFM4ExpansionTwo:AddOpAI('AirAttacks', 'UEF_ExpTwo_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', 6)
	
	-- sends [bombers]
	opai = UEFM4ExpansionTwo:AddOpAI('AirAttacks', 'UEF_ExpTwo_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_Main_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 9)
end