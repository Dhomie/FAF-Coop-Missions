------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R05/SCCA_Coop_R05_m1uefai.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 1 - SCCA_Coop_R05
------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/scenarioplatoonai.lua'

----------------
-- Base Managers
----------------
local UEFM1Base = BaseManager.CreateBaseManager()

-------------------
-- UEF M1 Main Base
-------------------
function UEFM1BaseAI()
    UEFM1Base:Initialize(ArmyBrains[UEF], 'M1_UEF_Base', 'M1_UEFResourceBaseArea', 90, 
		{
			M1_UEFBase_Production = 200,
			--M1_UEFGenerators = 150,
			M1_UEFBase_Walls = 100,
			
		}
	)
	
    UEFM1Base:StartNonZeroBase({2, 4, 8})
	UEFM1Base:AddBuildGroupDifficulty('M1_UEFBase_Defense', 125)
	
	UEFM1Base:SetMaximumConstructionEngineers(8)
	ArmyBrains[UEF]:PBMSetCheckInterval(10)
	
	UEFM1Base:SetDefaultEngineerPatrolChain('M1_UEFBase_Chain')

    UEFM1BaseAirAttacks()
    UEFM1BaseLandAttacks()
end

function UEFM1BaseAirAttacks()
	local opai = nil
    local quantity = {}
	local ChildType = {'Interceptors', 'Bombers', 'Gunships'}
	
	-- Maintains [1, 2, 3] units defined in ChildType
	quantity = {1, 2, 3}
	for k = 1, table.getn(ChildType) do
		opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Base_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M1_UEF_AirPatrol_Chain',
					},
					Priority = 150 - k, -- Interceptors are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	-- 1st wave
	-- Bombers
	quantity = {3, 4, 5}
	opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Air_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin'})
	
	--Interceptors
	quantity = {3, 4, 5}
	opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Air_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin'})
	
	-- 1st wave escalation
	-- Gunships, bombers
	quantity = {4, 6, 8}
	opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Air_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBeginIncrease'})
	
	-- Gunships, Interceptors
	quantity = {4, 6, 8}
	opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Air_Platoon_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors',}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBeginIncrease'})
	
	-- 2nd wave
	-- Gunships
	quantity = {4, 5, 6}
	opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_Air_Platoon_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin2'})
end

function UEFM1BaseLandAttacks()
	local opai = nil
    local quantity = {}
	
	-- Base patrols
    quantity = {6, 9, 12}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_Base_Land_Patrol_Platoon_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFLandPatrolChain_1',
								'M1_UEFLandPatrolChain_2',
                                'M1_UEFLandPatrolChain_3'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
	
	quantity = {4, 6, 8}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_Base_Land_Patrol_Platoon_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFLandPatrolChain_1',
								'M1_UEFLandPatrolChain_2',
                                'M1_UEFLandPatrolChain_3'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, quantity[Difficulty])
	
	quantity = {4, 6, 8}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_Base_Land_Patrol_Platoon_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFLandPatrolChain_1',
								'M1_UEFLandPatrolChain_2',
                                'M1_UEFLandPatrolChain_3'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
	
	-- 1st wave
	-- T1 AA
	quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_AA_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin'})
	
	-- T1 Tanks
	quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_Tank_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin'})
	
	-- T1 Artillery
	quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_Artillery_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin'})
	
	-- 1st wave escalation
	-- Combined anti-PD
	quantity = {2, 4, 6}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_Reinforced_Artillery_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 110,
        }
    )
	opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBeginIncrease'})
	
	-- Combined direct fire
	quantity = {4, 6, 8}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_Reinforced_Breakthrough_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 110,
        }
    )
	opai:SetChildQuantity({'HeavyTanks', 'LightBots'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBeginIncrease'})
	
	-- Combined AA
	quantity = {2, 4, 6}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_First_Wave_Reinforced_AA_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBeginIncrease'})
	
	-- 2nd wave
	-- Combined direct fire
	quantity = {3, 6, 9}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_Third_Wave_Breakthrough_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 120,
        }
    )
	opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks',}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin2'})
	
	-- Combined anti-PD
	quantity = {3, 6, 9}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_Third_Wave_Artillery_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_UEFResourceBaseAttack_Chain1',
								'M1_UEFResourceBaseAttack_Chain2',},
            },
            Priority = 120,
        }
    )
	opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'CheckScenarioInfoVarTable', {'default_brain','M1_UEFAttackBegin2'})
end

