--****************************************************************************
--**
--**  File     : /maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_M2UEFAI.lua
--**  Author(s): Dhomie42
--**
--**  Summary  : UEF army AI for Mission 1-2 - SCCA_Coop_R06.modified
--****************************************************************************
local BaseManager = import('/maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_BaseManager.lua')

-- ------
-- Locals
-- ------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionPackAllowed = ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units -- 1 --> disallowed, 2 --> allowed.
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local UEFControlCenterBase = BaseManager.CreateBaseManager()
local UEFDefensiveLineBase = BaseManager.CreateBaseManager()

function M2UEFControlCenterExpansion()
	UEFControlCenterBase:AddBuildGroup('ControlCenterDefensesPostBuilt_D' .. Difficulty, 100)
	ScenarioInfo.ControlCenterExpansionAuthorized = true
end

function M2DefensiveLineExpansion()
	UEFControlCenterBase:AddExpansionBase('M2_UEF_DefensiveLine', Difficulty)
end

function UEFControlCenterAI()
    -- ------------------------------------------------------------------------------------------
    -- Black Sun Control Center Expansion.
	-- Major defensive line for the UEF. This base will send attacks during Phase 2
    -- -----------------------------------------------------------------------------------------
    UEFControlCenterBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Control_Center_Base', 'ControlCenter', 120,
        {
			ControlCenterDefensesPreBuilt = 150,
        }
    )
	UEFControlCenterBase:StartNonZeroBase({2, 4, 6})
	UEFControlCenterBase:SetMaximumConstructionEngineers(6)
	
	UEFControlCenterBase:SetSupportACUCount(1)
	--Enhancements with no previous upgrade requirements, these work fine.
	UEFControlCenterBase:SetSACUUpgrades({'Shield', 'AdvancedCoolingUpgrade', 'ResourceAllocation'}, false)
	
	M2UEFControlCenterAirDefense()
	M2UEFControlCenterLandAttacks()
	M2UEFControlCenterAirAttacks()
end

function UEFDefensiveLineBaseAI()
    -- ----------------------------------------------------------------------------------------
    -- Black Sun Control Center Defensive Line Expansion.
	-- Minor defensive line for the UEF. 
	-- The UEF Control Center Base will send 1-3 engineer(s) here depending on the Difficulty.
    -- ----------------------------------------------------------------------------------------
    UEFDefensiveLineBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_DefensiveLine', 'M2_DefensiveLine_Base_Marker', 60,
        {
			M2DefensiveLine = 100,
        }
    )

	UEFDefensiveLineBase:StartEmptyBase({1, 2, 3})
	UEFDefensiveLineBase:SetMaximumConstructionEngineers(3)
end

function M2UEFControlCenterAirDefense()
    local opai = nil
	local quantity = {3, 6, 9}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships', 'CombatFighters'}
	
	--Maintains [3, 6, 9] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = UEFControlCenterBase:AddOpAI('AirAttacks', 'M2UEFControlCenter_AirDefense_' .. ChildType[k],	--Example: 'M2UEFControlCenter_AirDefense_AirSuperiority'
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'ControlCenterBig_Chain',
					},
					Priority = 250 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M2UEFControlCenterAirAttacks()
    local opai = nil
	local quantity = {3, 6, 9}
	
	for i = 1, Difficulty do
	opai = UEFControlCenterBase:AddOpAI('AirAttacks', 'M2UEFControlCenter_AirSuperiority_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end
	
	for i = 1, Difficulty do
	opai = UEFControlCenterBase:AddOpAI('AirAttacks', 'M2UEFControlCenter_HeavyGunships_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end
end

function M2UEFControlCenterLandAttacks()
    local opai = nil
	
	local T1Quantity = {8, 6, 4}
    local DirectQuantity = {2, 4, 8}
    local SupportQuantity = {2, 4, 6}
	
	--If FA units are allowed
	if ExpansionPackAllowed == 2 then
		for i = 1, 2  do
			opai = UEFControlCenterBase:AddOpAI('BasicLandAttack', 'M2_UEF_Prototype_T3_Attack' .. i,
				{
					MasterPlatoonFunction = {SPAIFileName, 	'PatrolThread'},
						PlatoonData = {
							PatrolChain = 'M2LandAttack_Chain' .. Random(1, 5),
						},
					Priority = 110,
				}
			)
			opai:SetChildActive('All', false)
			opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery', 'HeavyBots', 'HeavyMobileAntiAir', 'MobileMissilePlatforms'})
			opai:SetChildCount(Difficulty)
			opai:SetFormation('AttackFormation')
			opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		end
	end

    local Temp = {
        'M2_UEF_Medium_Fatboy_Attack',
        'NoPlan',
        { 'uel0201', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Tank
        { 'uel0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Artillery
        { 'uel0202', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Tank
		--{ 'uel0203', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 AmphTank
		{ 'uel0205', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Flak
		{ 'uel0111', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 MML
		{ 'uel0307', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Mobile Shield
	
    }
	local Builder = {
        BuilderName = 'M2_UEF_Medium_Fatboy_Attack',
        PlatoonTemplate = Temp,
        InstanceCount = 4 - Difficulty, --Weak attack for easier difficulties
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Control_Center_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M2LandAttack_Chain' .. Random(1, 5),
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'M2_UEF_Heavy_Fatboy_Attack',
        'NoPlan',
        { 'uel0303', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Siege Bot
        { 'uel0304', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Mobile Artillery
        { 'uel0202', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Tank
		--{ 'uel0203', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 AmphTank
		{ 'uel0205', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Flak
		{ 'uel0111', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 MML
		{ 'uel0307', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Mobile Shield
	
    }
    Builder = {
        BuilderName = 'M2_UEF_Heavy_Fatboy_Attack',
        PlatoonTemplate = Temp,
        InstanceCount = 1 + Difficulty, --Strong attack for harder difficulties
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Control_Center_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
       },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2LandAttack_Chain' .. Random(1, 5),
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end