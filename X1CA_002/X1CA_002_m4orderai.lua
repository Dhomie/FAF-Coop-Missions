--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_m4orderai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : Order army AI for Mission 4 - X1CA_002
--****************************************************************************
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')

-- ------
-- Locals
-- ------
local Order = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- -------------
-- Base Managers
-- -------------
local OrderM4MainBase = BaseManager.CreateBaseManager()
local OrderM4NorthBase = BaseManager.CreateBaseManager()
local OrderM4CenterBase = BaseManager.CreateBaseManager()
local OrderM4SouthBase = BaseManager.CreateBaseManager()

function OrderM4MainBaseAI()

    -- ------------------
    -- Order M4 Main Base
    -- ------------------
    OrderM4MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M4_Order_Main_Base', 'Order_M4_Main_Base_Marker', 90, {M4_Order_Main_Base = 150})
    OrderM4MainBase:StartNonZeroBase({8, 7, 6})
	OrderM4MainBase:AddBuildGroup('M4_Order_Main_Base_Additional', 90)
	
	OrderM4MainBase:AddExpansionBase('M4_Order_MiddleBase', 4)
	OrderM4MainBase:AddExpansionBase('M4_Order_NorthBase', 4)
	
	--if Difficulty == 1 then
		--OrderM4MainBase:AddBuildGroup('M4_Order_Main_Base_Artillery', 50)
	--end
	
	OrderM4MainBase:SetMaximumConstructionEngineers(8)

    OrderM4MainBaseAirAttacks()
    OrderM4MainBaseLandAttacks()
end

function OrderM4MainBaseAirAttacks()
    local opai = nil

    -- -------------------------------------
    -- Order M4 Main Base Op AI, Air Attacks
    -- -------------------------------------

    -- sends [bombers]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, {4, 4})

    -- sends [combat fighters]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', 8)

    -- sends [gunships, combat fighters]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, {4, 4})

    -- sends [gunships]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 8)

    -- sends [gunships, bombers]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, {4, 4})

    -- Air Defense
	local types = {'AirSuperiority', 'HeavyGunships', 'CombatFighters', 'Gunships'}
	local quantity = {4, 4, 8, 8}
    for i = 1, 4 do
        opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Order_Air_Defense_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity(types[i], quantity[i])
    end
end

function OrderM4MainBaseLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- Order M4 Main Base Op AI, Land Attacks
    -- --------------------------------------

    -- sends collosus
    opai = OrderM4MainBase:AddOpAI('M4_Order_Colos',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'},
            },
            MaxAssist = 3,
            Retry = true,
        }
    )

    -- sends random endlessly, with 15/30/45 secs after each complete platoons
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('BuildTimer', {LockTimer = 15 * Difficulty})

end

function OrderM4NorthBaseAI()

    -- -------------------
    -- Order M4 North Base
    -- -------------------
    OrderM4NorthBase:Initialize(ArmyBrains[Order], 'M4_Order_NorthBase', 'Order_M4_North_Base', 45, {M4_Order_North_Base = 100})
    OrderM4NorthBase:StartNonZeroBase(4)
	OrderM4NorthBase:SetMaximumConstructionEngineers(4)
	
	-- OrderM4NorthBase:AddExpansionBase('M4_Order_MiddleBase', 2)
	-- OrderM4NorthBase:AddExpansionBase('M4_Order_SouthBase', 2)
	--OrderM4NorthBase:AddBuildGroup('M4_Order_Middle_Base', 60)

    OrderM4NorthBaseLandAttacks()
	OrderM4NorthBaseAirAttacks()
end

function OrderM4NorthBaseLandAttacks()
    local opai = nil
	local units = {}
	local quantity = {}

    -- ---------------------------------------
    -- Order M4 North Base Op AI, Land Attacks
    -- ---------------------------------------
	
	opai = OrderM4NorthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttacks_North',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 100,
		}
	)
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('BuildTimer', {LockTimer = 25 * Difficulty})
end

function OrderM4NorthBaseAirAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M4 North Base Op AI, Air Attacks
    -- ---------------------------------------

    -- Air Attack
    opai = OrderM4NorthBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_North_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	opai:SetChildCount(Difficulty + 1)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 25 * Difficulty})
end

function OrderM4CenterBaseAI()

    -- --------------------
    -- Order M4 Center Base
    -- --------------------
    OrderM4CenterBase:Initialize(ArmyBrains[Order], 'M4_Order_MiddleBase', 'Order_M4_Middle_Base', 40, {M4_Order_Middle_Base = 100})
    OrderM4CenterBase:StartNonZeroBase(4)
	OrderM4CenterBase:SetMaximumConstructionEngineers(4)
	
    OrderM4CenterBaseAirAttacks()
    OrderM4CenterBaseLandAttacks()
end

function OrderM4CenterBaseAirAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M4 Center Base Op AI, Air Attacks
    -- ---------------------------------------

    -- Air Attack
    opai = OrderM4CenterBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_Center_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	opai:SetChildCount(Difficulty + 1)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 20 * Difficulty})
end

function OrderM4CenterBaseLandAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Order M4 Center Base Op AI, Land Attacks
    -- ----------------------------------------

    -- Land Attack
    opai = OrderM4CenterBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_Center',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('BuildTimer', {LockTimer = 20 * Difficulty})

end

function OrderM4SouthBaseAI()

    -- -------------------
    -- Order M4 South Base
    -- -------------------
    OrderM4SouthBase:Initialize(ArmyBrains[Order], 'M4_Order_SouthBase', 'Order_M4_South_Base', 45, {M4_Order_South_Base = 100})
    OrderM4SouthBase:StartNonZeroBase(4)
	OrderM4SouthBase:SetMaximumConstructionEngineers(4)

    OrderM4SouthBaseAirAttacks()
    OrderM4SouthBaseLandAttacks()
end

function OrderM4SouthBaseAirAttacks()
    local opai = nil

    -- --------------------------------------
    -- Order M4 South Base Op AI, Air Attacks
    -- --------------------------------------

    -- Air Attack
    opai = OrderM4SouthBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M3_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('StratBombers', false)
    opai:SetChildCount(1)
    --opai:SetLockingStyle('None')
end

function OrderM4SouthBaseLandAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M4 South Base Op AI, Land Attacks
    -- ---------------------------------------

    -- -- Land Attack
    -- opai = OrderM4SouthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_South',
        -- {
            -- MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            -- PlatoonData = {
                -- Location = 'QAI_M3_South_Base',
            -- },
            -- Priority = 100,
        -- }
    -- )
    -- opai:SetChildActive('HeavyBots', false)
    -- opai:RemoveChildren({'HeavyBots'})
    -- opai:SetChildCount(1)
    -- --opai:SetLockingStyle('None')
	
	for i = 1, 3 do
		local units = {{'Siegebots', 'HeavyTanks', 'LightTanks'}, {'MobileMissiles', 'LightArtillery'}, {'MobileFlak', 'LightBots'}}
		local quantity = {3, 4, 4}
		opai = OrderM4SouthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_South' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
				PlatoonData = {
					Location = 'QAI_M3_South_Base',
				},
				Priority = 100,
			}
		)
		opai:SetChildQuantity(units[i], quantity[i])
		----opai:SetLockingStyle('None')
	end
end