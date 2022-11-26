--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m2orderai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : Order army AI for Mission 2 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local OrderM2MainBase = BaseManager.CreateBaseManager()
local OrderM2AirNorthBase = BaseManager.CreateBaseManager()
local OrderM2AirSouthBase = BaseManager.CreateBaseManager()
local OrderM2LandNorthBase = BaseManager.CreateBaseManager()
local OrderM2LandSouthBase = BaseManager.CreateBaseManager()

function OrderM2MainBaseAI()

    -- ------------------
    -- Order M2 Main Base
    -- ------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_WestCamp_D' .. Difficulty)
    OrderM2MainBase:Initialize(ArmyBrains[Order], 'M2_Town_Attack_Base', 'M2_Order_NorthBase', 20, {M2_Town_Attack_Base = 100})
    OrderM2MainBase:StartNonZeroBase({2, 4, 6})

    OrderM2MainBaseLandAttacks()
end

function OrderM2MainBaseLandAttacks()
    local opai = nil
	local quantity = {3, 6, 9}

    -- --------------------------------------
    -- Order M2 Main Base Op AI, Land Attacks
    -- --------------------------------------
    -- sends [siege bots]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    --opai:SetLockingStyle('None')
	
    -- sends [heavy tanks]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
	
    -- sends [heavy artillery]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])


end

function OrderM2AirNorthBaseAI()

    -- -----------------------
    -- Order M2 Air North Base
    -- -----------------------
    OrderM2AirNorthBase:Initialize(ArmyBrains[Order], 'M2_Order_Air_North', 'M2_Order_Air_North_Marker', 20, {M2_Order_Air_North = 100})
    OrderM2AirNorthBase:StartNonZeroBase({1, 2, 4})

    OrderM2AirNorthBaseAirAttacks()
end

function OrderM2AirNorthBaseAirAttacks()
    local opai = nil
	local quantity = {2, 4, 6}

    -- ------------------------------------------
    -- Order M2 Air North Base Op AI, Air Attacks
    -- ------------------------------------------

    -- sends [bombers]
    opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthAirAttack1' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends [gunships]
    opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthAirAttack2' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- Air Defense
    for i = 1, Difficulty do
        opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_BaseAir_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    end
end

function OrderM2AirSouthBaseAI()

    -- -----------------------
    -- Order M2 Air South Base
    -- -----------------------
    OrderM2AirSouthBase:Initialize(ArmyBrains[Order], 'M2_Order_Air_South', 'M2_Order_Air_South_Marker', 20, {M2_Order_Air_South = 100})
    OrderM2AirSouthBase:StartNonZeroBase({1, 2, 4})

    OrderM2AirSouthBaseAirAttacks()
end

function OrderM2AirSouthBaseAirAttacks()
    local opai = nil
	local quantity = {2, 4, 6}

    -- ------------------------------------------
    -- Order M2 Air South Base Op AI, Air Attacks
    -- ------------------------------------------

    -- sends [bombers]
    opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthAirAttack1' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends [gunships]
    opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthAirAttack2' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- Air Defense
    for i = 1, Difficulty do
        opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_BaseAir_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    end
end

function OrderM2LandNorthBaseAI()

    -- ------------------------
    -- Order M2 Land North Base
    -- ------------------------
    OrderM2LandNorthBase:Initialize(ArmyBrains[Order], 'M2_Order_Land_North', 'M2_Order_Land_North_Marker', 20, {M2_Order_Land_North = 100})
    OrderM2LandNorthBase:StartNonZeroBase({1, 2, 4})

    OrderM2LandNorthBaseLandAttacks()
end

function OrderM2LandNorthBaseLandAttacks()
    local opai = nil
	local quantity = {2, 4, 6}
	
    -- --------------------------------------------
    -- Order M2 Land North Base Op AI, Land Attacks
    -- --------------------------------------------

    -- sends [light tanks, heavy tanks]
    opai = OrderM2LandNorthBase:AddOpAI('BasicLandAttack', 'M2_LandNorthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends [light artillery]
    opai = OrderM2LandNorthBase:AddOpAI('BasicLandAttack', 'M2_LandNorthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    --opai:SetLockingStyle('None')
end

function OrderM2LandSouthBaseAI()

    -- ------------------------
    -- Order M2 Land South Base
    -- ------------------------
    OrderM2LandSouthBase:Initialize(ArmyBrains[Order], 'M2_Order_Land_South', 'M2_Order_Land_South_Marker', 20, {M2_Order_Land_South = 100})
    OrderM2LandSouthBase:StartNonZeroBase({1, 3, 5})

    OrderM2LandSouthBaseLandAttacks()
end

function OrderM2LandSouthBaseLandAttacks()
    local opai = nil
	local quantity = {2, 4, 6}
    -- --------------------------------------------
    -- Order M2 Land South Base Op AI, Land Attacks
    -- --------------------------------------------

    -- sends [mobile missiles, light artillery]
    opai = OrderM2LandSouthBase:AddOpAI('BasicLandAttack', 'M2_LandSouthLandAttack1',
        {
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    --opai:SetLockingStyle('None')

    -- sends [light bots]
    opai = OrderM2LandSouthBase:AddOpAI('BasicLandAttack', 'M2_LandSouthLandAttack2',
        {
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')
end

function M2DisableOrderBases()
    if(OrderM2MainBase) then
        OrderM2MainBase:SetBuild('Engineers', false)
        OrderM2MainBase:SetBuildAllStructures(false)
        OrderM2MainBase:BaseActive(false)
    end
	
	if(OrderM2AirNorthBase) then
        OrderM2AirNorthBase:SetBuild('Engineers', false)
        OrderM2AirNorthBase:SetBuildAllStructures(false)
        OrderM2AirNorthBase:BaseActive(false)
    end
	
	if(OrderM2AirSouthBase) then
        OrderM2AirSouthBase:SetBuild('Engineers', false)
        OrderM2AirSouthBase:SetBuildAllStructures(false)
        OrderM2AirSouthBase:BaseActive(false)
    end
	
	if(OrderM2LandNorthBase) then
        OrderM2LandNorthBase:SetBuild('Engineers', false)
        OrderM2LandNorthBase:SetBuildAllStructures(false)
        OrderM2LandNorthBase:BaseActive(false)
    end
	
	if(OrderM2LandSouthBase) then
        OrderM2LandSouthBase:SetBuild('Engineers', false)
        OrderM2LandSouthBase:SetBuildAllStructures(false)
        OrderM2LandSouthBase:BaseActive(false)
    end
end