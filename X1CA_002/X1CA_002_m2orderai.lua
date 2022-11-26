--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_m2orderai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : Order army AI for Mission 2 - X1CA_002
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_002/X1CA_002_BaseManager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local Order = 2
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local OrderM2NorthBase = BaseManager.CreateBaseManager()

function OrderM2NorthBaseAI()

    -- ----------------------
    -- Order North Base Op AI
    -- ----------------------
    OrderM2NorthBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_North_Base', 'Order_M2_North_Base_Marker', 75, {M2_North_Base = 100})
	OrderM2NorthBase:StartNonZeroBase({2, 4, 6})
	OrderM2NorthBase:SetMaximumConstructionEngineers(6)
    OrderM2NorthBase:SetActive('AirScouting', true)
	
	OrderM2NorthBase:AddBuildGroup('M2_Order_OuterDef_D' .. Difficulty, 60)
	OrderM2NorthBase:AddBuildGroup('M2_North_Base_Additional', 75)

    OrderM2NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalLand')
    OrderM2NorthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalAir')
    OrderM2NorthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalNaval')
    OrderM2NorthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM2NorthBase_Nuke')
    OrderM2NorthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM2NorthBase_HLRA')

	OrderM2NorthBaseAirDefense()
    OrderM2NorthBaseAirAttacks()
    OrderM2NorthBaseLandAttacks()
end

function OrderM2NorthBaseAirDefense()
	local opai = nil
	local quantity = {5, 10, 15}
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'CombatFighters'}
	
	--Maintains [10, 20, 30] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_OrderNorth_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M2_Combined_AirDef_Chain',
					},
					Priority = 260 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function OrderM2NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {5, 10, 15}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {5, 10, 15}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    quantity = {5, 10, 15}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    quantity = {5, 10, 15}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Gunships'}, quantity[Difficulty])

	-- Sends 5, 10, 15 [ASF] if hostiles have >= 100, 80, 60 air units
    quantity = {5, 10, 15}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- Sends 5, 10, 15 [ASF] if hostiles have >= 60, 50, 40 T2/T3 air units
    quantity = {5, 10, 15}
    trigger = {60, 50, 40}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], (categories.MOBILE * categories.AIR) - categories.TECH1, '>='})

    -- sends 4, 8, 12 [combat fighters, gunships]
    quantity = {4, 8, 12}
    trigger = {60, 40, 20}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- Sends 5, 10, 15 [ASF] if hostiles have >= 6, 4, 2 strat bomber
    quantity = {5, 10, 15}
	trigger = {6, 4, 2}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
		{'default_brain', {'HumanPlayers', 'Loyalist', 'UEF', 'Cybran'}, trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    quantity = {5, 10, 15}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	opai:SetChildCount(Difficulty + 2)
end

function LoyEastSiege(platoon)
    local moveNum = false
    while(true) do
        if(ScenarioInfo.MissionNumber < 4) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Loyalist_Base_East_EngineerChain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 4) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Order_Land_Attack' .. Random(1, 2) .. '_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function LoyWestSiege(platoon)
    local moveNum = false
    while(true) do
        if(ScenarioInfo.MissionNumber < 4) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Loyalist_Base_West_EngineerChain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 4) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Order_Land_Attack' .. Random(1, 2) .. '_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function OrderM2NorthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ---------------------------------------
    -- Order M2 North Base Op AI, Land Attacks
    -- ---------------------------------------

    -- sends random [T2 + T3]
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')

    -- sends 4, 8, 12 [amphibious tanks]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])

    -- sends 2, 4, 6 [heavy bots]
    quantity = {2, 4, 6}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    -- sends 4, 8, 12 [heavy tanks]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])

    -- sends random [T2 + T3]
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
	opai:SetChildCount(Difficulty + 1)
	opai:SetFormation('AttackFormation')

    -- sends 4, 8, 12 [mobile missiles]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    -- sends 4, 6, 8 [mobile flak]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    -- sends 4, 6, 8 [mobile flak]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack8',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    -- sends 2, 4, 6 [siege bots]
    quantity = {2, 4, 6}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack9',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 4, 8, 12 [mobile flak]
    quantity = {4, 8, 12}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack10',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])


    -- sends 2, 4, 6 [mobile heavy artillery]
    quantity = {2, 4, 6}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack11',
        {
            MasterPlatoonFunction = {'/maps/X1CA_002/X1CA_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 150,
        }
    )
	opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
end

function M2OrderLandAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Order]:PlatoonExists(platoon)) do
        if(not ScenarioInfo.OrderAlly) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                if(Random(1, 2) == 1) then
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Combined_LandAttack_Chain')
                else
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Combined_LandAttack2_Chain')
                end
            end
        else
            if(not moveNum or moveNum ~= 4) then
                moveNum = 4
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Order_Land_Attack' .. Random(1, 2) .. '_Chain')
            end
        end
        WaitSeconds(1)
    end
end