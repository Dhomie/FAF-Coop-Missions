----------------------------------------------------------------------------
--  File     : /maps/X1CA_002/X1CA_002_m1loyalistai.lua
--  Author(s): Jessica St. Croix
--
--  Summary  : Loyalist army AI for Mission 1 - X1CA_002
--
--  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
----------------------------------------------------------------------------
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

--------
--Locals
--------
local Loyalist = 4
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local FileName = '/maps/X1CA_002/X1CA_002_m1loyalistai.lua'
local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local CFFileName = '/maps/X1CA_002/X1CA_002_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local LoyalistM1MainBase = BaseManager.CreateBaseManager()
local LoyalistNavalExpansionBase = BaseManager.CreateBaseManager()

function LoyalistM1MainBaseAI()
    -- ---------------------
    -- Loyalist M1 Main Base
    -- ---------------------	
    ScenarioUtils.CreateArmyGroup('Loyalist', 'Starting_Units')
    LoyalistM1MainBase:InitializeDifficultyTables(ArmyBrains[Loyalist], 'M1_Loy_StartBase', 'Loyalist_M1_Pinned_Base', 75, {M1_Loy_StartBase = 110})
	LoyalistM1MainBase:StartNonZeroBase({6, 5, 4})
	
	LoyalistM1MainBase:SetMaximumConstructionEngineers(6)
	
    LoyalistM1MainBase:SetActive('AirScouting', true)

    ArmyBrains[Loyalist]:PBMSetCheckInterval(10)

    LoyalistM1MainBaseLandAttacks()
    LoyalistM1MainBaseAirAttacks()
    --LoyalistM4TransportAttacks()
end

function LoyalistM1MainBaseAirAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Loyalist M1 Main Base Op AI, Air Attacks
    -- ----------------------------------------
	
	opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack_General1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 120,
		}
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Gunships', 'CombatFighters'})
	opai:SetChildCount(Difficulty + 1)
	opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	    {0, categories.uab1301, false})
		
	opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack_General2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 120,
		}
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Gunships', 'CombatFighters'})
	opai:SetChildCount(Difficulty + 1)
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		
	opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack_General3',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 120,
		}
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'AirSuperiority', 'StratBombers', 'HeavyGunships', 'Gunships', 'CombatFighters'})
	opai:SetChildCount(Difficulty + 2)
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})

    for i = 1, 2 do
        opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirDef_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
		        PlatoonData = {
		            PatrolChain = 'M1_Loyalist_AirPatrol_Chain',
		        },
                Priority = 110,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'Gunships', 'CombatFighters'})
		opai:SetChildCount(2)
    end

end

function LoyalistM1MainBaseLandAttacks()

    local opai = nil
    local platoons = {}

    -- -----------------------------------------
    -- Loyalist M1 Main Base Op AI, Land Attacks
    -- -----------------------------------------
	
	local Template = {
        'Loyalist_Reclaim_Engineers',
        'NoPlan',
        { 'ual0309', 1, 2, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	local Builder = {
        BuilderName = 'Loyalist_Reclaim_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 175,
        PlatoonType = 'Air',
        RequiresConstruction = true,
		LocationType = 'M1_Loy_StartBase',
		PlatoonAIFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Loy_StartBase_EngineerChain',
                },
            },
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( Builder )
	
	Template = {
        'Loyalist_Naval_Expansion_Engineers',
        'NoPlan',
        { 'ual0309', 1, 3, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	Builder = {
        BuilderName = 'Loyalist_Naval_Expansion_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 175,
        PlatoonType = 'Air',
        RequiresConstruction = true,
		LocationType = 'M1_Loy_StartBase',
		BuildConditions = {
                    {BMBC, 'BaseEngineersEnabled', {'Loyalist_Naval_Expansion_Base'}},
                    {BMBC, 'NumUnitsLessNearBase', {'Loyalist_Naval_Expansion_Base', ParseEntityCategory('ENGINEER'), 1}}, -- Data --> Base name, unit category like: categories.ENGINEER, variable name, or exact number.
                    {BMBC, 'BaseActive', {'Loyalist_Naval_Expansion_Base'}},
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
                },
		PlatoonAIFunction = {CFFileName, 'EngineersMoveToThread'},
            PlatoonData = {
				MoveRoute = {'Loyalist_NavalBase_Marker'},
				DisbandAfterArrival = true,
		},
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( Builder )

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 115,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 105,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M4_BasicLandAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 90,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

end

function LoyalistM1MainLandAttacksAI(platoon)
	local moveNum = false
    while(ArmyBrains[Loyalist]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 1) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'Guerrillas_M1_Attack_' .. Random(1, 2) .. '_Chain')
            end
        elseif(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'Guerrillas_M2_Attack_Chain' )
            end
		elseif(ScenarioInfo.MissionNumber == 4) then
            if(not moveNum or moveNum ~= 4) then
                moveNum = 4
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_LoyalistMain_LandAttack_Chain')
            end
		end	
		WaitSeconds(3)
	end
end

function M1P1Response()
    LoyalistM1MainBase:AddBuildGroup('M1_Loy_WreckedBase', 100)
    LoyalistM1MainBase:AddBuildGroup('T3PowerGen_AirStaging', 90)
    LoyalistM1MainBase:AddBuildGroup('ShieldsADD', 85)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Land', 70)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Air', 60)
end

function LoyalistM4TransportAttacks()
    local opai = nil
	
	--T2 Transports
    local template = {
        'AirTemplateTRANSPORTS',
        'NoPlan',
        { 'uaa0104', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local builder = {
        BuilderName = 'AirTRANSPORTS',
        PlatoonTemplate = template,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.uaa0104}},
        },
        LocationType = 'M1_Loy_StartBase',
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( builder )

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 200,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
	opai:SetChildCount(Difficulty + 3)

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 210,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks'})
	opai:SetChildCount(Difficulty + 3)

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 220,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks'})
	opai:SetChildCount(Difficulty + 3)
end

function LoyalistNavalExpansionAI()
	----------------------------
    -- Loyalist naval expansion
    ----------------------------
    LoyalistNavalExpansionBase:Initialize(ArmyBrains[Loyalist], 'Loyalist_Naval_Expansion_Base', 'Loyalist_NavalBase_Marker', 105,
	    {
	        Naval_Economy = 150,
	        Naval_Factories = 250,
	        Naval_Defenses = 200,
	        Naval_Misc = 120,
	    }
	)
	
	LoyalistNavalExpansionBase:StartEmptyBase({5, 4, 3})
	LoyalistNavalExpansionBase:SetMaximumConstructionEngineers(5)
	
	--These attacks will only start in M4, so there is no need for further conditions
	LoyalistNavalAttacks()
end

function LoyalistNavalAttacks()
    local opai = nil

    -- -------------------------------------------------
    -- Loyalist Naval Attacks
	-- 1st attack will go to QAI's main base
	-- 2nd and 3rd attacks will target the small naval base
    -- -------------------------------------------------
	
	opai = LoyalistNavalExpansionBase:AddNavalAI('Loyalist_MainFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M4_NavalChain',
            },
            MaxFrigates = 36,
            MinFrigates = 18,
            Priority = 110,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	
	opai = LoyalistNavalExpansionBase:AddNavalAI('Loyalist_SecondaryFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 24,
            MinFrigates = 12,
            Priority = 100,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)
	
	opai = LoyalistNavalExpansionBase:AddNavalAI('Loyalist_ThirdFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 18,
            MinFrigates = 9,
            Priority = 90,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)
end