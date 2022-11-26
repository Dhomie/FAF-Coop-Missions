--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_cybranai.lua
--**  Author(s): --
--**
--**  Summary  : Cybran army AI for Mission 2 - X1CA_002
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
local Cybran = 6
local Difficulty = ScenarioInfo.Options.Difficulty
local FileName = '/maps/X1CA_002/X1CA_002_cybranai.lua'
local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local CFFileName = '/maps/X1CA_002/X1CA_002_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local CybranMain = BaseManager.CreateBaseManager()
local CybranAirExpansion = BaseManager.CreateBaseManager()
local CybranNavalExpansionBase = BaseManager.CreateBaseManager()

function CybranAddAirExpansion()
	CybranMain:AddExpansionBase('Cybran_Air_Expansion_Base', 5)
end

function CybranAddNavalExpansion()
	CybranMain:AddExpansionBase('Cybran_Naval_Base', 2)
end

function CybranMainBaseAI()

	-- -----------
    -- Cybran Base
    -- -----------
    CybranMain:Initialize(ArmyBrains[Cybran], 'Cybran_Main_Base', 'Cybran_Base_Marker', 45,
		{
		Economy = 200,
		Factories = 150,
		Defenses = 130,
		Misc = 120,
		}
	)
	
	CybranMain:StartEmptyBase({6, 5, 4})
	CybranMain:AddBuildGroup('Expanded_Economy', 60)
	CybranMain:SetMaximumConstructionEngineers(4)

	ArmyBrains[Cybran]:PBMSetCheckInterval(10)
	
	CybranRandomLandAttacks()
end

function CybranAirExpansionAI()

	CybranAirExpansion:Initialize(ArmyBrains[Cybran], 'Cybran_Air_Expansion_Base', 'Cybran_AirBase_Marker', 50,
		{
		Exp_Economy = 150,
		Exp_Factories = 150,
		Exp_Defenses = 180,
		Exp_Misc = 120,
		}
	)
	
	CybranAirExpansion:StartEmptyBase({7, 6, 5})
	CybranAirExpansion:SetMaximumConstructionEngineers(5)
	
	CybranAirExpansion:SetActive('AirScouting', true)
	
	CybranRandomAirAttacks()
end

function CybranNavalExpansionAI()

	-- ---------------------------------------------------------------------
    -- Cybran naval expansion
	-- QAI's naval attacks will be buffed to balance out this new addition.
    -- ---------------------------------------------------------------------
	
    CybranNavalExpansionBase:Initialize(ArmyBrains[Cybran], 'Cybran_Naval_Expansion_Base', 'Cybran_NavalBase_Marker', 90,
	    {
	        Naval_Economy = 150,
	        Naval_Factories = 250,
	        Naval_Defenses = 200,
	        Naval_Misc = 120,
	    }
	)
	
	CybranNavalExpansionBase:StartEmptyBase({4, 3, 2})
	CybranNavalExpansionBase:SetMaximumConstructionEngineers(2)
	
	--These attacks will only start in M4, so there is no need for further conditions
	CybranNavalAttacks()
end

function CybranRandomLandAttacks()
		
	local opai = nil
		
	local Template = {
        'Cybran_Air_Expansion_Engineers',
        'NoPlan',
        { 'url0309', 1, 5, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	local Builder = {
        BuilderName = 'Cybran_Air_Expansion_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'Cybran_Main_Base',
		BuildConditions = {
                    {BMBC, 'BaseEngineersEnabled', {'Cybran_Air_Expansion_Base'}},
                    {BMBC, 'NumUnitsLessNearBase', {'Cybran_Air_Expansion_Base', categories.ENGINEER + categories.FACTORY, 1}}, -- Data --> Base name, unit category like: categories.ENGINEER, variable name, or exact number.
                    {BMBC, 'BaseActive', {'Cybran_Air_Expansion_Base'}},
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 1}},
                },
		PlatoonAIFunction = {CFFileName, 'EngineersMoveToThread'},
            PlatoonData = {
				MoveRoute = {'Cybran_AirBase_Marker'},
				DisbandAfterArrival = true,
				},
		}
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	Template = {
        'Cybran_Naval_Expansion_Engineers',
        'NoPlan',
        { 'url0309', 1, 2, 'Attack', 'AttackFormation' },	-- T3 Engineers
    }
	
	Builder = {
        BuilderName = 'Cybran_Naval_Expansion_Engineers_Builder',
        PlatoonTemplate = Template,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'Cybran_Main_Base',
		BuildConditions = {
                    {BMBC, 'BaseEngineersEnabled', {'Cybran_Naval_Expansion_Base'}},
                    {BMBC, 'NumUnitsLessNearBase', {'Cybran_Naval_Expansion_Base', categories.ENGINEER + categories.FACTORY, 1}}, -- Data --> Base name, unit category like: categories.ENGINEER, variable name, or exact number.
                    {BMBC, 'BaseActive', {'Cybran_Naval_Expansion_Base'}},
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 1}},
                },
		PlatoonAIFunction = {CFFileName, 'EngineersMoveToThread'},
            PlatoonData = {
				MoveRoute = {'Cybran_NavalBase_Marker'},
				DisbandAfterArrival = true,
				},
		}
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
		
		-- Random compositions
		opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_M1_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'CybranLandAI'},
            Priority = 150,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_M2_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'CybranLandAI'},
            Priority = 140,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_M3_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'CybranLandAI'},
            Priority = 130,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
		opai:SetChildCount(Difficulty + 3)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})
		
		opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_M4_RandomLandAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'CybranLandAI'},
            Priority = 120,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberLessOrEqual', {'default_brain', 2})

end

function CybranLandAI(platoon)
    local moveNum = false
    while(ArmyBrains[Cybran]:PlatoonExists(platoon)) do
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

function CybranRandomAirAttacks()
		
		local opai = nil
		
		opai = CybranAirExpansion:AddOpAI('AirAttacks', 'Cybran_M1_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'CombatFighters', 'Gunships', 'Bombers', 'Interceptors', 'LightGunships'})
		opai:SetChildCount(Difficulty + 2)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 1})
		
		opai = CybranAirExpansion:AddOpAI('AirAttacks', 'Cybran_M2_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'CombatFighters', 'Gunships'})
		opai:SetChildCount(Difficulty + 1)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		
		opai = CybranAirExpansion:AddOpAI('AirAttacks', 'Cybran_M3_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
		opai:SetChildCount(Difficulty + 2)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
		
		opai = CybranAirExpansion:AddOpAI('AirAttacks', 'Cybran_M4_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
		opai:SetChildCount(Difficulty + 2)
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})

end

function CybranNavalAttacks()
    local opai = nil

    -- -------------------------------------------------
    -- Cybran Naval Attacks
	-- 3 attacks will be included here
	-- These attacks will start only at M4
	-- Thus, they won't have their own platoon function
	-- 1st attack will go to QAI's main base
	-- 2nd and 3rd attacks will target the small naval base
	-- These will be weaker than the UEF naval platoons
    -- -------------------------------------------------
	
	opai = CybranNavalExpansionBase:AddNavalAI('Cybran_MainFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M4_NavalChain',
            },
            MaxFrigates = 40,
            MinFrigates = 20,
            Priority = 110,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	
	opai = CybranNavalExpansionBase:AddNavalAI('Cybran_SecondaryFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 30,
            MinFrigates = 15,
            Priority = 100,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)
	
	opai = CybranNavalExpansionBase:AddNavalAI('Cybran_ThirdFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Allied_M3_NavalChain',
            },
            MaxFrigates = 24,
            MinFrigates = 12,
            Priority = 90,
        }
    )
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:SetChildActive('T3', false)

end

function CybranTransportAttacks()
    local opai = nil
	
    local template = {
        'Cybran_AirTransport_Builder',
        'NoPlan',
        { 'ura0104', -1, 1, 'Attack', 'GrowthFormation' },
    }
    local builder = {
        BuilderName = 'Cybran_AirTransport_Builder',
        PlatoonTemplate = template,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.ura0104}},
        },
        LocationType = 'Cybran_Air_Expansion_Base',
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( builder )

    opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_TransportPlatoon_1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Cybran_Base_Marker',
        },
        Priority = 200,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
	opai:SetChildCount(Difficulty + 3)
	
    opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_TransportPlatoon_2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Cybran_Base_Marker',
        },
        Priority = 210,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
	opai:SetChildCount(Difficulty + 3)

    opai = CybranMain:AddOpAI('BasicLandAttack', 'Cybran_TransportPlatoon_3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
			MovePath = 'M4_Allied_Transport_Path',
            TransportReturn = 'Cybran_Base_Marker',
        },
        Priority = 220,
    })
	opai:SetChildActive('All', false)
    opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
	opai:SetChildCount(Difficulty + 3)

end