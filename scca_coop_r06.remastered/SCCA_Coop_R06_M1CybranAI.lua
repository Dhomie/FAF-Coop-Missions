------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06.remastered/SCCA_Coop_R06_M1CybranAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Cybran Debug army AI for Mission 1 - SCCA_Coop_R06
------------------------------------------------------------------------------
local BaseManager = import('/maps/SCCA_Coop_R06.remastered/SCCA_Coop_R06_BaseManager.lua')

-- ------
-- Locals
-- ------
local Cybran = 5
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/scca_coop_r06.remastered/SCCA_Coop_R06_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local M1CybranDebugBase = BaseManager.CreateBaseManager()

function M1CybranDebugBaseAI()

	-- -----------
    -- Player1 Base
    -- -----------
    M1CybranDebugBase:Initialize(ArmyBrains[Cybran], 'M1_Cybran_Debug_Base', 'PlayerBase', 210,
		{
			Allied_Debug_Base_D1 = 250,
		}
	)
	
	--M1CybranDebugBase:StartNonZeroBase({4, 4, 3})
	M1CybranDebugBase:StartEmptyBase({15, 14, 13})
	M1CybranDebugBase:SetMaximumConstructionEngineers(15)
	ArmyBrains[Cybran]:PBMSetCheckInterval(5)
	
    M1CybranDebugBase:SetActive('AirScouting', true)
	
	M1CybranDebugBaseLandAttacks()
	M1CybranDebugBaseAirAttacks()
	M1CybranDebugBaseNavaAttacks()
	M1CybranDebugBaseAirDefense()
	M1CybranDebugBaseExperimentals()
end

function M1CybranDebugBaseLandAttacks()
	local opai = nil
		
		-- Random compositions
	for i = 1, Difficulty do
		opai = M1CybranDebugBase:AddOpAI('BasicLandAttack', 'Cybran_Debug_T2_RandomLandAttack_' .. i,
        {
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_Allied_Land_Chain_' .. Random(1, 3),
			},     
            Priority = 150 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileStealth'})
		opai:SetChildCount(Difficulty + 2)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		
		opai = M1CybranDebugBase:AddOpAI('BasicLandAttack', 'Cybran_Debug_T3_RandomLandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Allied_Land_Chain_' .. Random(1, 3),
                },
            Priority = 120 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty + 1)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end

end

function M1CybranDebugBaseAirAttacks()
	local opai = nil
		
		opai = M1CybranDebugBase:AddOpAI('AirAttacks', 'Cybran_Debug_RandomAirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'AirSuperiority', 'StratBombers', 'Gunships'})
		opai:SetChildCount(Difficulty)
		--opai:SetLockingStyle('BuildTimer', {LockTimer = 5 * Difficulty})
		opai:SetLockingStyle('None')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
end

function M1CybranDebugBaseNavaAttacks()
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 4, 6}
	local T1Quantity = {3, 6, 9}
	
	--Cybran Debug Naval Fleet
	local Temp = {
        'Cybran_Debug_Naval_Attacks',
        'NoPlan',
        { 'urs0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'urs0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'urs0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'urs0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'urs0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
	
    }
	local Builder = {
        BuilderName = 'Cybran_Debug_Naval_Attacks',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty + 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Cybran_Debug_Base',
		BuildConditions = {
			--{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
				'M1_Cybran_Naval_Chain_1',
				'M1_Cybran_Naval_Chain_2',
			},
        },     
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function M1CybranDebugBaseAirDefense()
    local opai = nil
	local quantity = {5, 10, 15}	--Air Factories = 5 at all times
	local ChildType = {'AirSuperiority', 'Gunships', 'StratBombers'}
	
	--Maintains [5, 10, 15] units defined in ChildType
	--Create platoons for each unit type.
	for k = 1, table.getn(ChildType) do
		opai = M1CybranDebugBase:AddOpAI('AirAttacks', 'M1_Cybran_Debug_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'Player_Base_Patrol_Chain',
					},
				Priority = 200 - k,	--ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M1CybranDebugBaseExperimentals()
	local opai = nil

	--Sends [1-1, 2-2, 3-3] Spiderbots to the UEF Main Base
	for i = 1, 2 do
		for k = 1, Difficulty do
			opai = M1CybranDebugBase:AddOpAI('Allied_M3_Spiderbot_' .. k,
				{
					Amount = 1,
					KeepAlive = true,
					PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
					PlatoonData = {
						Name = 'Allied_M3_Spiderbot_Platoon_' .. i,
						NumRequired = Difficulty,
						PatrolChains = {
							'M3_Allied_Land_Chain_1',
							'M3_Allied_Land_Chain_2',
							'M3_Allied_Land_Chain_3',
						},
					},
					BuildCondition = {
						{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual',
							{2}}
					},
					MaxAssist = 3,
					Retry = true,
				}
			)
		end
    end
end