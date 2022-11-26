--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_UEFAI.lua
--**  Author(s): --
--**
--**  Summary  : UEF army AI for Mission 2 - X1CA_002
--****************************************************************************
--local BaseManager = import('/lua/ai/opai/basemanager.lua')
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
--local Script = import('/maps/X1CA_002/X1CA_002_script.lua')

-- ------
-- Locals
-- ------
local UEF = 7
local Difficulty = ScenarioInfo.Options.Difficulty
local FileName = '/maps/X1CA_002/X1CA_002_uefai.lua'
local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local CFFileName = '/maps/X1CA_002/X1CA_002_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local UEFBase = BaseManager.CreateBaseManager()
local UEFAirExpansionBase = BaseManager.CreateBaseManager()
local UEFNavalExpansionBase = BaseManager.CreateBaseManager()

function UEFAddAirExpansion()
	UEFBase:AddExpansionBase('UEF_Air_Expansion_Base', 3)
end

function UEFAddNavalExpansion()
	UEFBase:AddExpansionBase('UEF_Naval_Base', 3)
end

function UEFBaseAI()

    -- ----------------
    -- UEF "main base"
    -- ----------------
    UEFBase:Initialize(ArmyBrains[UEF], 'UEF_Main_Base', 'UEF_Base_Marker', 60,
	    {
	        Economy = 250,
	        Factories = 200,
	        Defenses = 150,
	        Misc = 120,
	    }
	)
	UEFBase:StartEmptyBase({7, 6, 5})
	UEFBase:AddBuildGroup('Expanded_Economy', 60)
	UEFBase:SetMaximumConstructionEngineers(5)

	UEFBaseRandomLandAttacks()
	ArmyBrains[UEF]:PBMSetCheckInterval(10)
end

function UEFAirExpansionAI()

	-- ------------------------
    -- UEF airbase, expansion
    -- ------------------------

	UEFAirExpansionBase:Initialize(ArmyBrains[UEF], 'UEF_Air_Expansion_Base', 'UEF_AirBase_Marker', 50,
		{
		Exp_Economy = 175,
		Exp_Factories = 200,
		Exp_Defenses = 250,
		Exp_Misc = 150,
		}
	)
	
	UEFAirExpansionBase:StartEmptyBase({5, 4, 3})
	UEFAirExpansionBase:SetMaximumConstructionEngineers(3)
	
	UEFAirExpansionBase:SetActive('AirScouting', true)
	
	--UEFMainAirAttacks()
	UEFRandomAirAttacks()
	
end

function UEFNavalExpansionAI()

	-- ------------------------------------------------------------------------------------------------
    -- UEF naval expansion
	-- QAI's naval attacks will be buffed to balance out this new addition --> M3 Naval base is now T3
    -- ------------------------------------------------------------------------------------------------
	
    UEFNavalExpansionBase:Initialize(ArmyBrains[UEF], 'UEF_Naval_Expansion_Base', 'UEF_NavalBase_Marker', 90,
	    {
	        Naval_Economy = 250,
	        Naval_Factories = 200,
	        Naval_Defenses = 150,
	        Naval_Misc = 120,
	    }
	)
	
	UEFNavalExpansionBase:StartEmptyBase({5, 4, 3})
	UEFNavalExpansionBase:SetMaximumConstructionEngineers(3)
	
	--These attacks will only start in M4, so there is no need for further conditions
	UEFNavalAttacks()
	
end

function UEFRandomAirAttacks()

		local opai = nil

		opai = UEFAirExpansionBase:AddOpAI('AirAttacks', 'UEF_M1_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
		)
		--opai:SetChildActive('StratBombers', false)
		--opai:SetChildActive('AirSuperiority', false)
		--opai:SetChildActive('HeavyGunships', false)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'CombatFighters', 'Gunships', 'Bombers', 'Interceptors'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 1})
		
		opai = UEFAirExpansionBase:AddOpAI('AirAttacks', 'UEF_M2_RandomAirAttack_1',
        {
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
		)
		--opai:SetChildActive('StratBombers', false)
		--opai:SetChildActive('AirSuperiority', false)
		--opai:SetChildActive('HeavyGunships', false)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'CombatFighters', 'Gunships'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		
		opai = UEFAirExpansionBase:AddOpAI('AirAttacks', 'UEF_M3_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
		opai:SetChildCount(Difficulty + 2)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
		
		opai = UEFAirExpansionBase:AddOpAI('AirAttacks', 'UEF_M4_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildCount(Difficulty + 2)
		opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})

end

function UEFBaseRandomLandAttacks()
	local opai = nil
		
	local Template = {
        'UEF_Air_Expansion_Engineers',
        'NoPlan',
        { 'uel0309', 1, 3, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	local Builder = {
        BuilderName = 'UEF_Air_Expansion_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'UEF_Main_Base',
		BuildConditions = {
                    {BMBC, 'BaseEngineersEnabled', {'UEF_Air_Expansion_Base'}},
                    {BMBC, 'NumUnitsLessNearBase', {'UEF_Air_Expansion_Base', categories.ENGINEER + categories.FACTORY, 1}}, -- Data --> Base name, unit category like: categories.ENGINEER, variable name, or exact number.
                    {BMBC, 'BaseActive', {'UEF_Air_Expansion_Base'}},
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
                },
		PlatoonAIFunction = {CFFileName, 'EngineersMoveToThread'},
            PlatoonData = {
				MoveRoute = {'UEF_AirBase_Marker'},
				DisbandAfterArrival = true,
				},
		}
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Template = {
        'UEF_Naval_Expansion_Engineers',
        'NoPlan',
        { 'uel0309', 1, 3, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	Builder = {
        BuilderName = 'UEF_Naval_Expansion_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'UEF_Main_Base',
		BuildConditions = {
                    {BMBC, 'BaseEngineersEnabled', {'UEF_Naval_Expansion_Base'}},
                    {BMBC, 'NumUnitsLessNearBase', {'UEF_Naval_Expansion_Base', categories.ENGINEER + categories.FACTORY, 1}}, -- Data --> Base name, unit category like: categories.ENGINEER, variable name, or exact number.
                    {BMBC, 'BaseActive', {'UEF_Naval_Expansion_Base'}},
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
                },
		PlatoonAIFunction = {CFFileName, 'EngineersMoveToThread'},
            PlatoonData = {
				MoveRoute = {'UEF_NavalBase_Marker'},
				DisbandAfterArrival = true,
				},
		}
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
		
		-- Random compositions, a total of 4 units picked by random
		opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_M1_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'UEFLandPlatoonsThread'},
            Priority = 150,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileShields'})
		opai:SetChildCount(Random(2, Difficulty + 1))
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_M2_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'UEFLandPlatoonsThread'},
            Priority = 140,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileShields'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_M3_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'UEFLandPlatoonsThread'},
            Priority = 130,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileMissilesPlatforms', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileShields'})
		opai:SetChildCount(Difficulty + 4)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_M4_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'UEFLandPlatoonsThread'},
            Priority = 120,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileMissilesPlatforms'})
		opai:SetChildCount(Difficulty + 2)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

end

function UEFLandPlatoonsThread(platoon)
    local aiBrain = platoon:GetBrain()
    local moveNum = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
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

function UEFNavalAttacks()
    local opai = nil

    -- ---------------------------------------------------
    -- UEF Naval Attacks
	-- 3 attacks will be included here
	-- These attacks will start only at M4
	-- Thus, they won't have their own platoon function
	-- 1st attack will go to QAI's main base
	-- 2nd and 3rd attacks will target the small naval base
	-- These are stronger than the UEF platoons
    -- ---------------------------------------------------
	
	opai = UEFNavalExpansionBase:AddNavalAI('UEF_MainFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M4_NavalChain',
            },
            MaxFrigates = 48,
            MinFrigates = 24,
            Priority = 110,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	
	opai = UEFNavalExpansionBase:AddNavalAI('UEF_SecondaryFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 42,
            MinFrigates = 21,
            Priority = 100,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)
	
	opai = UEFNavalExpansionBase:AddNavalAI('UEF_ThirdFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 36,
            MinFrigates = 18,
            Priority = 90,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)

end

function UEFTransportAttacks()
    local opai = nil
	
    local template = {
        'UEF_AirTransport_Builder',
        'NoPlan',
        { 'xea0306', -1, 1, 'Attack', 'GrowthFormation' },
    }
    local builder = {
        BuilderName = 'UEF_AirTransport_Builder',
        PlatoonTemplate = template,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.xea0306}},
        },
        LocationType = 'UEF_Air_Expansion_Base',
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_TransportPlatoon_1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'UEF_Base_Marker',
        },
        Priority = 200,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileMissilesPlatforms'})
	opai:SetChildCount(Difficulty + 3)
	
    opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_TransportPlatoon_2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'UEF_Base_Marker',
        },
        Priority = 210,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
	opai:SetChildCount(Difficulty + 3)

    opai = UEFBase:AddOpAI('BasicLandAttack', 'UEF_TransportPlatoon_3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'UEF_Base_Marker',
        },
        Priority = 220,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
	opai:SetChildCount(Difficulty + 3)

end