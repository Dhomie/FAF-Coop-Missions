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
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/scca_coop_r05/scca_coop_r05_customfunctions.lua'
local AIAttackUtils = '/maps/scca_coop_r05/scca_coop_r05_aiattackutilities.lua'
local BMBC = '/lua/editor/basemanagerbuildconditions.lua'

-- General T2 transport platoon template, the OpAI has issues with building them for some reason
local T2TransportTemplate = {
    'UEF_T2_Transport_Template',
    'NoPlan',
    { 'uea0104', 3, 3, 'Attack', 'None' }, -- T2 Transport
}

-- Land platoon template
local T2LandAssaultTemplate = {
	'UEF_T2_Land_Assault_Force_Template',
	'NoPlan',
	{'uel0202', 1, 4, 'Attack', 'AttackFormation'},	-- T2 Heavy Tank
	{'uel0111', 1, 4, 'Artillery', 'AttackFormation'},	-- T2 MML
	{'uel0205', 1, 2, 'Support', 'AttackFormation'},	-- T2 Mobile Flak
	{'uel0307', 1, 2, 'Support', 'AttackFormation'},	-- T2 Mobile Shield
}

-- Land platoon template
local T3LandAssaultTemplate = {
	'UEF_T3_Land_Assault_Force_Template',
	'NoPlan',
	{'uel0303', 1, 4, 'Attack', 'AttackFormation'},	-- T3 Siege Bot
	{'uel0304', 1, 2, 'Artillery', 'AttackFormation'},	-- T3 Mobile Heavy Artillery
}

-- Engineer platoon template for expansions
local EngineerPlatoonTemplate = {
	'UEF_T3_Expansion_Engineer_Platoon_Template',
	'NoPlan',
	{ 'uel0309', 3, 3, 'Support', 'AttackFormation' },	-- T3 Engineers
}

--Used for CategoryHunterPlatoonAI
local ConditionCategories = {
	NavalFactories = (categories.FACTORY * categories.NAVAL) - categories.TECH1,	--Tech 2 Naval Factories are the main targets
	StrategicBombers = categories.STRATEGICBOMBER,
	AirUnits = categories.AIR * categories.MOBILE - categories.TECH1,	-- We don't want these to be triggered by massed T1 air units.
}

----------------
-- Base Managers
----------------
local UEFM3AirBase = BaseManager.CreateBaseManager()
local UEFM3MainBase = BaseManager.CreateBaseManager()
local UEFM3NavalBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M3 Air Base
-------------------
function UEFM3AirBaseAI()
	UEFM3AirBase:Initialize(ArmyBrains[UEF], 'M3_UEF_Air_Base', 'M3_UEFAirBaseArea', 90, 
		{
			M3_UEFAirBase_Production_Factories = 250,
			M3_UEFAirBase_Production_Sundry = 200,
			M3_UEFAirBase_Walls = 150,
			
		}
	)
	UEFM3AirBase:StartNonZeroBase({2, 4, 6})
	UEFM3AirBase:SetMaximumConstructionEngineers(6)
	
	ArmyBrains[UEF]:PBMSetCheckInterval(10)
	
	UEFM3AirBase:AddBuildGroupDifficulty('M3_UEFAirBase', 175, true)	-- Defenses and other misc.
	
	UEFM3AirBaseAirDefense()
	UEFM3AirBaseAirAttacks()
end

function UEFM3AirBaseAirDefense()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	-- Maintains [4, 8, 12] units defined in ChildType
	quantity = {4, 8, 12}
	for k = 1, table.getn(ChildType) do
		opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_UEFAir_AirPatrolChain',
					},
					Priority = 200 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function UEFM3AirBaseAirAttacks()
	local opai = nil
	local quantity = {}

	-- Gunship attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Gunship_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:SetLockingStyle('BuildTimer', {LockTimer = 60 / Difficulty})
	
	-- Heavy Gunship attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_HeavyGunship_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:SetLockingStyle('BuildTimer', {LockTimer = 60 / Difficulty})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- ASF attack to counter players' air force
	trigger = {60, 50, 40}
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_ASF_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.AirUnits, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	
	-- StratBomber attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_StratBomber_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- StratBombers for directly taking out naval factories
	trigger = {3, 2, 1}
	quantity = {2, 3, 4}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_NavalFactory_Hunter_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.NavalFactories,}
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	if Difficulty >= 2 then
		opai:SetFormation('NoFormation')
	end
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.NavalFactories, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
		
	-- ASFs for directly taking out Strat Bombers
	trigger = {6, 4, 2}
	quantity = {2, 3, 4}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_StrategicBombers_Hunter_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.StrategicBombers,}
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	if Difficulty >= 2 then
		opai:SetFormation('NoFormation')
	end
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.StrategicBombers, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- Bombers attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Bomber_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	
	-- Interceptors attack
	quantity = {4, 8, 12}
	opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_UEFAirBase_Interceptor_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
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
	
	UEFM3MainBaseTMLDefense()
	UEFM3MainBaseAirDefense()
	UEFM3MainBaseLandAttacks()
	UEFM3MainBaseAirAttacks()
	UEFM3MainBaseTransportAttacks()
end

function UEFM3MainBaseTMLDefense()
	local Builder = {
        BuilderName = 'M3_UEFMain_TML_Builder',
        PlatoonTemplate = {
			'TMLTemplate',
			'NoPlan',
			{'ueb2108', 1, 1, 'Attack', 'None'},
		},
		InstanceCount = 11,
        Priority = 300,
        PlatoonType = 'Any',
        RequiresConstruction = false,
        LocationType = 'M3_UEF_Main_Base',
        PlatoonAIFunction = {'/lua/ai/opai/BaseManagerPlatoonThreads.lua', 'BaseManagerTMLAI'},
        BuildConditions = {
            {BMBC, 'BaseActive', {'M3_UEF_Main_Base'}},
            {BMBC, 'TMLsEnabled', {'M3_UEF_Main_Base'}},
        },
        PlatoonData = {
            BaseName = 'M3_UEF_Main_Base',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
end

function UEFM3MainBaseAirDefense()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	-- Maintains [3, 6, 9] units defined in ChildType
	quantity = {3, 6, 9}
	for k = 1, table.getn(ChildType) do
		opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_UEFMainBase_AirPatrolChain',
					},
					Priority = 200 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	-- Additional ASF patrol
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
                PatrolChains = {
					'M3_UEFMainBase_LandPatrolChain_1',
					'M3_UEFMainBase_LandPatrolChain_2',
				},
				},
				Priority = 200, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	-- Sends random [T2]
	for i = 1, Difficulty do
	opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_T2_LandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEFMain_LandAttackChain',
            },
            Priority = 150 + i, -- Base gets cluttered with units too much if they all have the same priority.
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty)
	opai:SetFormation('AttackFormation')
	
    -- Sends [random - T3]
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
	local trigger = {}
	
	-- Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Gunship_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:SetLockingStyle('BuildTimer', {LockTimer = 60 / Difficulty})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- Heavy Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_HeavyGunship_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:SetLockingStyle('BuildTimer', {LockTimer = 60 / Difficulty})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- ASF attack to counter players' air force
	trigger = {50, 40, 30}
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_ASF_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.AirUnits, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- StratBombers attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_StratBomber_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- StratBombers for directly taking out naval factories
	trigger = {3, 2, 1}
	quantity = {1, 2, 3}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_NavalFactory_Hunter_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.NavalFactories,}
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	if Difficulty >= 2 then
		opai:SetFormation('NoFormation')
	end
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.NavalFactories, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
		
	-- ASFs for directly taking out Strat Bombers
	trigger = {6, 4, 2}
	quantity = {1, 2, 3}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_StrategicBombers_Hunter_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.StrategicBombers,}
			},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	if Difficulty >= 2 then
		opai:SetFormation('NoFormation')
	end
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.StrategicBombers, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- Bombers attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Bomber_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- Interceptors attack
	quantity = {3, 6, 9}
	opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_UEFMainBase_Interceptor_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
end

function UEFM3MainBaseTransportAttacks()
	local opai = nil
	local Bases = {'M2_UEF_Omni_Base_South_West', 'M2_UEF_Omni_Base_North', 'M3_UEF_Air_Base'}
	local LandingChains = {'M2_UEFOmniSW_LandPatrolChain_1', 'M2_UEFOmniNorth_LandPatrolChain_1', 'M3_UEFAir_LandPatrolChain_1'}
	local poolName = 'M3_UEF_Main_Base_TransportPool'
	
	-- Transport Builder
	local Builder = {
        BuilderName = 'M3_UEFMainBase_Transport_Builder',
        PlatoonTemplate = T2TransportTemplate,
        InstanceCount = 10, -- Just in case only 1 transport remains alive from the platoons
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_Main_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {6, poolName}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}}
		},
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M3_UEF_Main_Base',
		},
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- UEF Engineers to rebuild some of the lost bases
	for i = 1, table.getn(Bases) do
		Builder = {
			BuilderName = 'M3_UEF_ExpansionTo_ ' .. Bases[i],
			PlatoonTemplate = EngineerPlatoonTemplate,
			InstanceCount = 1,
			Priority = 250,
			PlatoonType = 'Land',
			RequiresConstruction = true,
			LocationType = 'M3_UEF_Main_Base',
			BuildConditions = {
				{BMBC, 'BaseActive', {Bases[i]}},
				{BMBC, 'NumUnitsLessNearBase', {Bases[i], (categories.FACTORY * categories.STRUCTURE) + (categories.ENGINEER * categories.TECH3), Difficulty}},
            },
			PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},
			PlatoonData = {
				BaseName = 'M3_UEF_Main_Base',
				DisbandAfterLanding = true,
				LandingChain = LandingChains[i],
				TransportReturn = 'M3_UEFMainBaseArea',
			},
		}
		ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	end
	
	-- T2 Assault Builder
	Builder = {
        BuilderName = 'M3_UEFMainBase_T2_Transport_LandForce_Builder',
        PlatoonTemplate = T2LandAssaultTemplate,
        InstanceCount = Difficulty + 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_Main_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uea0104}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
		PlatoonAIFunction = {AIAttackUtils, 'AttackForceAI'},
		PlatoonData = {
			BaseName = 'M3_UEF_Main_Base',
			UseFormation = 'AttackFormation',
			TransportReturn = 'M3_UEFMainBaseArea',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- T3 Assault Builder
	Builder = {
        BuilderName = 'M3_UEFMainBase_T3_Transport_LandForce_Builder',
        PlatoonTemplate = T3LandAssaultTemplate,
        InstanceCount = Difficulty + 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_Main_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uea0104}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
		PlatoonAIFunction = {AIAttackUtils, 'AttackForceAI'},
		PlatoonData = {
			BaseName = 'M3_UEF_Main_Base',
			UseFormation = 'AttackFormation',
			TransportReturn = 'M3_UEFMainBaseArea',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	--[[for i = 1, Difficulty do
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
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
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
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	end]]
end

-------------------------
-- UEF M3 Main Naval Base
-------------------------

function UEFM3NavalBaseAI()
	UEFM3NavalBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Naval_Base', 'M3_UEFNavalBase_Marker', 90, 
		{
			M3_UEFNavalBase = 200,
		}
	)
	UEFM3NavalBase:StartNonZeroBase({1, 2, 3})
	UEFM3NavalBase:SetMaximumConstructionEngineers(3)
	
	UEFM3NavalBaseNavalAttacks()
end

function UEFM3NavalBaseNavalAttacks()
	local opai = nil
	local trigger = {}
	local quantity = {1, 1, 2}
	
	--M2 UEF naval attacks
	local Builder = {
        BuilderName = 'M3_UEF_Naval_Attack_Builder',
        PlatoonTemplate = {
			'M3_UEF_Naval_Attack_Template',
			'NoPlan',
			{ 'ues0201', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
			{ 'ues0202', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		},
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
				'M3_UEFNaval_Assault_Chain',
			},
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	-- Maintains [1, 1, 2] Battleships
	opai = UEFM3NavalBase:AddOpAI('NavalAttacks', 'M3_UEF_Battleship_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_UEFNaval_Assault_Chain',
                },
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('Battleships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	-- Maintains [1, 1, 2] Cruisers
	for i = 1, Difficulty do
	opai = UEFM3NavalBase:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEFNaval_North_Patrol_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity('Cruisers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	end
end