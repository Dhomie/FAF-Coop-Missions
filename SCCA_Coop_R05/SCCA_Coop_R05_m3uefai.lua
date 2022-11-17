------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R05/SCCA_Coop_R05_m3uefai.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 3 - SCCA_Coop_R05
------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local FileName = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_m3uefai.lua'
local MainScript = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_script.lua'
--Used by the UEF Main Base for transport attacks.
local T2TransportTemplate = {
    'UEF_T2_Transport_Template',
    'NoPlan',
    { 'uea0104', 1, 3, 'Attack', 'None' }, -- 3 T2 Transport
}

----------------
-- Base Managers
----------------
local UEFM3AirBase = BaseManager.CreateBaseManager()
local UEFM3MainBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M3 Air Base
-------------------
function UEFM3AirBaseAI()
	UEFM3AirBase:Initialize(ArmyBrains[UEF], 'M3_UEF_Air_Base', 'M3_UEFAirBaseArea', 90, 
		{
			M3_UEFAirBase_Production = 200,
			M3_UEFAirBase_Walls = 150,
			
		}
	)
	UEFM3AirBase:StartNonZeroBase({2, 4, 6})
	UEFM3AirBase:SetMaximumConstructionEngineers(6)
	
	ArmyBrains[UEF]:PBMSetCheckInterval(7)
	
	UEFM3AirBase:AddBuildGroupDifficulty('M3_UEFAirBase', 175, true)	--Defenses and other misc.
	
	UEFM3AirBaseAirDefense()
	UEFM3AirBaseAirAttacks()
end

function UEFM3AirBaseAirDefense()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	--Base patrols
	
	--Maintains [4, 8, 12] units defined in ChildType
	quantity = {4, 8, 12}
	for k = 1, table.getn(ChildType) do
		opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_UEFAir_AirPatrolChain',
					},
					Priority = 200 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function UEFM3AirBaseAirAttacks()
	local opai = nil
	local quantity = {}

	--Gunship attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--Heavy Gunship attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--ASF attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--StratBombers attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--Filler units when gunships are restricted, otherwise just 2 platoons of air are built
	--Bombers attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--Interceptors attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Air_Platoon_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
end

--------------------
-- UEF M3 Main Base
--------------------
function UEFM3MainBaseAI()
	UEFM3MainBase:Initialize(ArmyBrains[UEF], 'M3_UEF_Main_Base', 'M3_UEFMainBaseArea', 120, 
		{
			M3_UEFMainBase_Production = 200,
			M3_UEFMainBase_Walls = 150,
			
		}
	)
	UEFM3MainBase:StartNonZeroBase({2, 4, 6})
	UEFM3MainBase:SetMaximumConstructionEngineers(6)
	
	UEFM3MainBase:SetDefaultEngineerPatrolChain('M3_UEFMainBase_CDRPatrolChain_1')
	
	UEFM3MainBase:AddBuildGroupDifficulty('M3_UEFMainBase', 175, true)	--Defenses and other misc.
	
	UEFM3MainBaseAirDefense()
	UEFM3MainBaseLandAttacks()
	UEFM3MainBaseAirAttacks()
	UEFM3MainBaseTransportAttacks()
end

function UEFM3MainBaseAirDefense()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	--Maintains [3, 6, 9] units defined in ChildType
	quantity = {3, 6, 9}
	for k = 1, table.getn(ChildType) do
		opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_UEFMainBase_AirPatrolChain',
					},
					Priority = 200 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	--Additional ASF patrol
	quantity = {6, 9, 12}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_AirDefense_Reinforced_AirSuperiority',
		{
			MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_UEFMainBase_AirPatrolChain',
				},
				Priority = 200
		}
	)
	opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function UEFM3MainBaseLandAttacks()
	local opai = nil
	local quantity = {}
	local ChildType = {'SiegeBots', 'MobileHeavyArtillery', 'HeavyTanks', 'MobileMissiles', 'MobileFlak'}
	
	--Generic base patrols
    quantity = {2, 4, 6}
    for k = 1, table.getn(ChildType) do
		opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMainBase_LandDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
				PlatoonData = {
                PatrolChains = {'M3_UEFMainBase_LandPatrolChain_1',
								'M3_UEFMainBase_LandPatrolChain_2',},
				},
				Priority = 200, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	--Sends random [T2]
	for i = 1, Difficulty do
	opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_T2_LandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEFMain_LandAttackChain',
                },
            Priority = 150 + i, --Base gets cluttered with units too much if they all have the same priority.
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty)
	opai:SetFormation('AttackFormation')
	
    --Sends [random - T3]
    opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_T3_LandAttack_' .. i,
        {
             MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEFMain_LandAttackChain',
                },
            Priority = 160 + i, --Base gets cluttered with units too much if they all have the same priority.
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
	opai:SetChildCount(Difficulty)
	opai:SetFormation('AttackFormation')
	end
end

function UEFM3MainBaseAirAttacks()
	local opai = nil
	local quantity = {}
	
	--Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	--Heavy Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	
	--ASF attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	
	--StratBombers attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	
	--Filler units when gunships are restricted, otherwise just 2 platoons of air are built
	--Bombers attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	--Interceptors attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Air_Platoon_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
end

function UEFM3MainBaseTransportAttacks()
	local opai = nil
	local quantity = {}
	
	local Builder = {
        BuilderName = 'M3_UEFMainBase_Transport_Builder',
        PlatoonTemplate = T2TransportTemplate,
        InstanceCount = 10, -- Just in case only 1 transport remains alive from the platoons
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_Main_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.uea0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},    
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	for i = 1, Difficulty do
		--Sends random amounts of [T2]
		opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_TransportAttacks_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M3_UEFMain_Transport_LZ',
					MovePath = 'M3_UEFMain_Transport_Path',
                    TransportReturn = 'M3_UEFMain_Transport_Return'
                },
                Priority = 150 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
		opai:SetChildCount(Difficulty + 1)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})
	
		--Sends random amounts of [T3]	
		opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_TransportAttacks_T3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M3_UEFMain_Transport_LZ',
					MovePath = 'M3_UEFMain_Transport_Path',
                    TransportReturn = 'M3_UEFMain_Transport_Return'
                },
                Priority = 160 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uea0104})
	end
end