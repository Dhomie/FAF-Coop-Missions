--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06.remastered/SCCA_Coop_R06_M2UEFAI.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 1-2 - SCCA_Coop_R06.remastered
--------------------------------------------------------------------------------
local BaseManager = import('/maps/SCCA_Coop_R06.remastered/SCCA_Coop_R06_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- ------
-- Locals
-- ------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionPackAllowed = ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units -- 1 --> disallowed, 2 --> allowed.
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/scca_coop_r06.remastered/SCCA_Coop_R06_CustomFunctions.lua'
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
	UEFControlCenterBase:AddExpansionBase('M2_UEF_DefensiveLine', Difficulty * 2)
end

function UEFControlCenterAI()
    -- -------------------------------------
    -- Black Sun Control Center Expansion.
	-- Major defensive line for the UEF.
    -- -------------------------------------
    UEFControlCenterBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Control_Center_Base', 'ControlCenter', 25,
        {
			ControlCenterDefensesPreBuilt = 150,
        }
    )
	UEFControlCenterBase:StartNonZeroBase({4, 6, 8})
	UEFControlCenterBase:SetMaximumConstructionEngineers(8)
end

function UEFDefensiveLineBaseAI()
    -- ---------------------------------------------------
    -- Black Sun Control Center Defensive Line Expansion.
	-- Minor defensive line for the UEF. 
    -- ---------------------------------------------------
    UEFDefensiveLineBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_DefensiveLine', 'M2_DefensiveLine_Base_Marker', 60,
        {
			M2DefensiveLine = 100,
        }
    )

	UEFDefensiveLineBase:StartEmptyBase({2, 4, 6})
	UEFDefensiveLineBase:SetMaximumConstructionEngineers(6)
end

function MobileFactoryAI(unit, i)
    -- from fatty
    -- Adding build location for AI
    ArmyBrains[UEF]:PBMAddBuildLocation('UEF_Mobile_Factory_Marker_' .. i, 20, 'MobileFactory' .. i)

    for num, loc in ArmyBrains[UEF].PBM.Locations do
        if loc.LocationType == 'MobileFactory' .. i then
            loc.PrimaryFactories.Land = unit
            break
        end
    end

    IssueFactoryRallyPoint({unit}, ScenarioUtils.MarkerToPosition('UEF_Mobile_Factory_Rally_' .. i))

    MobileFactoryAttacks(i)
end

function MobileFactoryAttacks(i)
	local T1Quantity = {8, 6, 4}
    local DirectQuantity = {2, 4, 6}
    local SupportQuantity = {1, 2, 4}
	
    if i == 1 then
		--1st Fatboy platoon, heavy attacks
        local Builder = {
        BuilderName = 'M2_UEF_Heavy_Fatboy_Attack_Builder',
        PlatoonTemplate = {
        'M2_UEF_Fatboy_Heavy_Attack_Platoon_Template',
        'NoPlan',
        { 'uel0303', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Siege Bot
        { 'uel0304', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Mobile Artillery
        { 'uel0202', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Tank
		{ 'uel0205', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Flak
		{ 'uel0111', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 MML
		{ 'uel0307', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Mobile Shield
		},
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'MobileFactory1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M2LandAttack_Chain1',
							'M2LandAttack_Chain2',
							'M2LandAttack_Chain3',
							'M2LandAttack_Chain4',
							'M2LandAttack_Chain5',
			},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
    elseif i == 2 then
		--2nd Fatboy platoon, light attacks
		local Builder = {
        BuilderName = 'M2_UEF_Medium_Fatboy_Attack_Builder',
        PlatoonTemplate = {
        'M2_UEF_Fatboy_Medium_Attack_Platoon_Template',
        'NoPlan',
        { 'uel0201', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Tank
        { 'uel0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Artillery
        { 'uel0202', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Tank
		{ 'uel0205', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Flak
		{ 'uel0111', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 MML
		{ 'uel0307', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Mobile Shield
		},
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'MobileFactory2',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M2LandAttack_Chain1',
							'M2LandAttack_Chain2',
							'M2LandAttack_Chain3',
							'M2LandAttack_Chain4',
							'M2LandAttack_Chain5',
			},
        },
		}
		ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    end
end