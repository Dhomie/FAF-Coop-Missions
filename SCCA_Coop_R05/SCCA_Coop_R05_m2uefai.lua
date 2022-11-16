------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R05/SCCA_Coop_R05_m2uefai.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 2 - SCCA_Coop_R05
------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local FileName = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_m2uefai.lua'
local MainScript = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_script.lua'
--Used by the Northen and South Western Omni bases for transport attacks.
local T2TransportTemplate = {
    'UEF_T2_Transport_Template',
    'NoPlan',
    { 'uea0104', 1, 3, 'Attack', 'None' }, -- 3 T2 Transport
}

----------------
-- Base Managers
----------------
local UEFM2OmniBaseEast = BaseManager.CreateBaseManager()
local UEFM2OmniBaseNorth = BaseManager.CreateBaseManager()
local UEFM2OmniBaseSouthWest = BaseManager.CreateBaseManager()
local UEFM2NavalBase = BaseManager.CreateBaseManager()

------------------------
-- UEF M2 Omni Base East
------------------------
function UEFM2OmniBaseEastAI()
	UEFM2OmniBaseEast:Initialize(ArmyBrains[UEF], 'M2_UEF_Omni_Base_East', 'M2_UEFAirOmniArea', 90, 
		{
			M2_UEFOmniBaseEast_Production = 200,
			M2_UEFOmniBaseEast_Walls = 150,
			
		}
	)
	UEFM2OmniBaseEast:StartNonZeroBase({3, 6, 9})
	UEFM2OmniBaseEast:SetMaximumConstructionEngineers(6)
	
	UEFM2OmniBaseEast:SetDefaultEngineerPatrolChain('M2_UEFOmniBaseEast_Chain')
	
	UEFM2OmniBaseEast:AddBuildGroupDifficulty('M2_UEFOmniBaseEast_Defense', 175)
	
	UEFM2OmniBaseEastAirAttacks()
	UEFM2OmniBaseEastAirDefenses()
end

function UEFM2OmniBaseEastAirAttacks()
	local opai = nil
    local quantity = {}
	
	--Part 1 attacks
	--Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M1_UEFOmniBaseEast_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',
								'M1_UEFAirAttack2_Chain',},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable',
        {'default_brain','M1_UEFAttackBegin2'})
	
	--Gunship, Bomber attack
	quantity = {6, 9, 12}
	opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M1_UEFOmniBaseEast_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',
								'M1_UEFAirAttack2_Chain',},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable',
        {'default_brain','M1_UEFAttackBegin2'})
	--Gunship, Interceptor attack
	quantity = {6, 9, 12}
	opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M1_UEFOmniBaseEast_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',
								'M1_UEFAirAttack2_Chain',},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable',
        {'default_brain','M1_UEFAttackBegin2'})
	
	--Part 2 attacks
	
	--Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M2_UEFOmniBaseEast_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Heavy Gunship attack
	quantity = {3, 6, 9}
	opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M2_UEFOmniBaseEast_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
end

--Eastern Omni Base maintains air defenses for itself, and the naval base.
function UEFM2OmniBaseEastAirDefenses()
	local opai = nil
	local quantity = {}
	local AirBaseChildType = {'AirSuperiority', 'HeavyGunships', 'Gunships', 'Bombers', 'Interceptors'}
	local NavalBaseChildType = {'AirSuperiority', 'HeavyGunships', 'Gunships', 'TorpedoBombers'}
	
	--Maintains [3, 6, 9] units defined in AirBaseChildType
	quantity = {3, 6, 9}
	for k = 1, table.getn(AirBaseChildType) do
		opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M2_UEFOmniBaseEast_AirDefense' .. AirBaseChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M2_UEFOmniEast_AirPatrolChain',
					},
					Priority = 250 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(AirBaseChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	--Maintains [3, 6, 9] units defined in NavalBaseChildType
	quantity = {3, 6, 9}
	for k = 1, table.getn(NavalBaseChildType) do
		opai = UEFM2OmniBaseEast:AddOpAI('AirAttacks', 'M2_UEFNavalBase_AirDefense' .. NavalBaseChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M2_UEFNaval_AirPatrolChain',
					},
					Priority = 250 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(NavalBaseChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

-------------------------
-- UEF M2 Omni Base North
-------------------------
function UEFM2OmniBaseNorthAI()
	UEFM2OmniBaseNorth:Initialize(ArmyBrains[UEF], 'M2_UEF_Omni_Base_North', 'M2_UEFNorthOmniArea', 90, 
		{
			M2_UEFOmniBaseNorth_Production = 200,
			M2_UEFOmniBaseNorth_Walls = 150,
		}
	)
	UEFM2OmniBaseNorth:StartNonZeroBase({3, 6, 9})
	UEFM2OmniBaseNorth:SetMaximumConstructionEngineers(6)
	
	UEFM2OmniBaseNorth:SetDefaultEngineerPatrolChain('M2_UEFOmniBaseNorth_Chain')
	
	UEFM2OmniBaseNorth:AddBuildGroupDifficulty('M2_UEFOmniBaseNorth', 175) --Defenses and other misc
	
	UEFM2OmniBaseNorthAirAttacks()
	UEFM2OmniBaseNorthTransportAttacks()
end

function UEFM2OmniBaseNorthAirAttacks()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'Gunships', 'Bombers', 'Interceptors'}
	
	--Base patrols
	
	--Maintains [2, 4, 6] units defined in ChildType
	quantity = {2, 4, 6}
	for k = 1, table.getn(ChildType) do
		opai = UEFM2OmniBaseNorth:AddOpAI('AirAttacks', 'M2_UEFOmniBaseNorth_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M2_UEFOmniNorth_AirPatrolChain',
					},
					Priority = 200 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	--Gunship, Bomber attack
	quantity = {4, 6, 8}
	opai = UEFM2OmniBaseNorth:AddOpAI('AirAttacks', 'M2_UEFOmniBaseNorth_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Gunship, Interceptor attack
	quantity = {4, 6, 8}
	opai = UEFM2OmniBaseNorth:AddOpAI('AirAttacks', 'M2_UEFOmniBaseNorth_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Gunship attack
	quantity = {4, 5, 6}
	opai = UEFM2OmniBaseNorth:AddOpAI('AirAttacks', 'M2_UEFOmniBaseNorth_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Heavy Gunship attack
	quantity = {1, 2, 3}
	opai = UEFM2OmniBaseNorth:AddOpAI('AirAttacks', 'M2_UEFOmniBaseNorth_Air_Platoon_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
end

function UEFM2OmniBaseNorthTransportAttacks()
	local opai = nil
	
	local Builder = {
        BuilderName = 'M2_UEFOmniBaseNorth_Transport_Builder',
        PlatoonTemplate = T2TransportTemplate,
        InstanceCount = 10, -- Just in case only 1 transport remains alive from the platoons
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Omni_Base_North',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.uea0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},    
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	--Sends random amounts of [T2]
	for i = 1, Difficulty do
		opai = UEFM2OmniBaseNorth:AddOpAI('BasicLandAttack', 'M2_UEFOmniBaseNorth_TransportAttacks_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M2_UEF_Transport_LZ',
					MovePath = 'M2_UEFOmniBaseNorth_Transport_Path',
                    TransportReturn = 'M2_OmniNorth_TransportReturn'
                },
                Priority = 150,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
		opai:SetChildCount(Difficulty + 1)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin2'})
	end
	
	--Sends random amounts of [T3]
	for i = 1, Difficulty do	
		opai = UEFM2OmniBaseNorth:AddOpAI('BasicLandAttack', 'M2_UEFOmniBaseNorth_TransportAttacks_T3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M2_UEF_Transport_LZ',
					MovePath = 'M2_UEFOmniBaseNorth_Transport_Path',
                    TransportReturn = 'M2_OmniNorth_TransportReturn'
                },
                Priority = 160,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uea0104})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})	--T3 only after part 2
	end
end

------------------------------
-- UEF M2 Omni Base South West
------------------------------
function UEFM2OmniBaseSouthWestAI()
	UEFM2OmniBaseSouthWest:Initialize(ArmyBrains[UEF], 'M2_UEF_Omni_Base_South_West', 'M2_UEFSWOmniArea', 90,
		{
			M2_UEFOmniBaseSouthWest_Production = 200,
			M2_UEFOmniBaseSouthWest_Walls = 150,
		}
	)
	UEFM2OmniBaseSouthWest:StartNonZeroBase({3, 6, 9})
	UEFM2OmniBaseSouthWest:SetMaximumConstructionEngineers(6)
	
	UEFM2OmniBaseSouthWest:SetDefaultEngineerPatrolChain('M2_UEFOmniBaseSouthWest_Chain')
	
	UEFM2OmniBaseSouthWest:AddBuildGroupDifficulty('M2_UEFOmniBaseSouthWest', 175) --Defenses and other misc
	
	UEFM2OmniBaseSouthWestAirAttacks()
	UEFM2OmniBaseSouthWestTransportAttacks()
end

function UEFM2OmniBaseSouthWestAirAttacks()
	local opai = nil
	local quantity = {}
	local ChildType = {'AirSuperiority', 'Gunships', 'Bombers', 'Interceptors'}
	
	--Base patrols
	
	--Maintains [2, 4, 6] units defined in ChildType
	quantity = {2, 4, 6}
	for k = 1, table.getn(ChildType) do
		opai = UEFM2OmniBaseSouthWest:AddOpAI('AirAttacks', 'M2_UEFOmniBaseSouthWest_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M2_UEFOmniSW_AirPatrolChain',
					},
					Priority = 200 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end

	--Gunship, Bomber attack
	quantity = {4, 6, 8}
	opai = UEFM2OmniBaseSouthWest:AddOpAI('AirAttacks', 'M2_UEFOmniBaseSouthWest_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Gunship, Interceptor attack
	quantity = {4, 6, 8}
	opai = UEFM2OmniBaseSouthWest:AddOpAI('AirAttacks', 'M2_UEFOmniBaseSouthWest_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Gunship attack
	quantity = {4, 5, 6}
	opai = UEFM2OmniBaseSouthWest:AddOpAI('AirAttacks', 'M2_UEFOmniBaseSouthWest_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Heavy Gunship attack
	quantity = {1, 2, 3}
	opai = UEFM2OmniBaseSouthWest:AddOpAI('AirAttacks', 'M2_UEFOmniBaseSouthWest_Air_Platoon_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
end

function UEFM2OmniBaseSouthWestTransportAttacks()
	local opai = nil
	
	local Builder = {
        BuilderName = 'M2_UEFOmniBaseSouthWest_Transport_Builder',
        PlatoonTemplate = T2TransportTemplate,
        InstanceCount = 10, -- Just in case only 1 transport remains alive from the platoons
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Omni_Base_South_West',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.uea0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},    
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	--Sends random amounts of [T2]
	for i = 1, Difficulty do
		opai = UEFM2OmniBaseSouthWest:AddOpAI('BasicLandAttack', 'M2_UEFOmniBaseSouthWest_TransportAttacks_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M2_UEF_Transport_LZ',
					--MovePath = 'M2_UEFOmniBaseNorth_Transport_Path',	--Naval base provides cover for these, no need for a specific path
                    TransportReturn = 'M2_SWOmni_TransportReturn'
                },
                Priority = 150,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
		opai:SetChildCount(Difficulty + 1)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin2'})
	end
	
	--Sends random amounts of [T3]
	for i = 1, Difficulty do	
		opai = UEFM2OmniBaseSouthWest:AddOpAI('BasicLandAttack', 'M2_UEFOmniBaseSouthWest_TransportAttacks_T3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_UEFResourceBaseAttack_Chain' .. Random(1, 2),
                    LandingChain = 'M2_UEF_Transport_LZ',
					--MovePath = 'M2_UEFOmniBaseNorth_Transport_Path',	--Naval base provides cover for these, no need for a specific path
                    TransportReturn = 'M2_SWOmni_TransportReturn'
                },
                Priority = 160,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uea0104})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})	--T3 only after part 2
	end
end

-----------------------------
-- UEF M2 Naval Base
-----------------------------
function UEFM2NavalBaseAI()
	UEFM2NavalBase:Initialize(ArmyBrains[UEF], 'M2_UEF_Naval_Base', 'M2_UEFNavalBaseArea', 90, 
		{
			M2_UEFNavalBase_Production = 200,
			M2_UEFNavalBase_Walls = 150,
			
		}
	)
	UEFM2NavalBase:StartNonZeroBase({2, 4, 6})
	UEFM2NavalBase:SetMaximumConstructionEngineers(4)
	
	UEFM2NavalBase:SetDefaultEngineerPatrolChain('M2_UEFNavalBase_Chain')
	
	UEFM2NavalBase:AddBuildGroupDifficulty('M2_UEFNavalBase_Misc', 175)
	
	UEFM2NavalBaseNavalAttacks()
end

function UEFM2NavalBaseNavalAttacks()
	local opai = nil
	local T2Quantity = {1, 2, 3}
	local T1Quantity = {2, 4, 6}
	
	--M1 UEF naval attacks, some minutes after the players have been spotted
	local Temp = {
        'M1_UEF_Naval_Respone_Template',
        'NoPlan',
        { 'ues0201', 1, 1, 'Attack', 'AttackFormation' }, -- T2 Destroyer
		{ 'ues0103', 1, 2, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'ues0203', 1, 2, 'Attack', 'AttackFormation' }, -- T1 Submarine
	
    }
	local Builder = {
        BuilderName = 'M1_UEF_Naval_Respone_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin3'}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {'M2_UEF_Naval_Attack_Chain',},
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	--M2 UEF naval attacks
	Temp = {
        'M2_UEF_Naval_Attack_Template',
        'NoPlan',
        { 'ues0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
		{ 'ues0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'ues0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'ues0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
	}
	
	Builder = {
        BuilderName = 'M2_UEF_Naval_Attack_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {'M2_UEF_Naval_Attack_Chain',
							'M2_UEFNaval_AttackPatrolChain_1',},
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	--Maintains [1/1, 4/4, 9/9] Destroyers/Cruisers
	for i = 1, Difficulty do
	opai = UEFM2NavalBase:AddOpAI('NavalAttacks', 'M2_UEF_Naval_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Lake_Patrol_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {T2Quantity[Difficulty], T2Quantity[Difficulty]})
	--opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end
end