--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_M3AeonAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Aeon army AI for Mission 3 - SCCA_Coop_R06.modified
--------------------------------------------------------------------------------
local BaseManager = import('/maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_BaseManager.lua')

-- ------
-- Locals
-- ------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionPackAllowed = ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units -- 1 --> disallowed, 2 --> allowed.
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local M3AeonSouthEasternBase = BaseManager.CreateBaseManager()

function M3AeonSouthEasternBaseAI()

	-- -----------
    -- Aeon Base
    -- -----------
    M3AeonSouthEasternBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_SouthEastern_Base', 'M3_Aeon_SouthEastern_Base_Marker', 180,
		{
		M3_Aeon_Southern_Base = 450,
		}
	)
	
	M3AeonSouthEasternBase:StartNonZeroBase({3, 6, 10})
	M3AeonSouthEasternBase:SetMaximumConstructionEngineers(10)
	
	--M3AeonSouthEasternBase:SetSACUUpgrades({'EngineeringFocusingModule', 'Shield', 'ShieldHeavy', 'ResourceAllocation'}, false)
	
	M3AeonSouthEasternBase:SetActive('AirScouting', true)
    M3AeonSouthEasternBase:SetActive('LandScouting', true)
	ArmyBrains[Aeon]:PBMSetCheckInterval(7)
	
	M3AeonSouthEasternNavalAttacks()
	--M3AeonSouthEasternTransportAttacks()
	M3AeonSouthEasternAirAttacks()
	M3AeonSouthEasternAirDefense()
	if ExpansionPackAllowed == 2 then
		M3AeonSouthEasternLandAttacks()
	end
end

function M3AeonSouthEasternNavalAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {2, 3, 4}
	local T1Quantity = {5, 4, 3}
	
	--Medium Aeon Fleet for attacking the players
	local Temp = {
        'M3_Aeon_SouthEastern_Naval_Fleet',
        'NoPlan',
        { 'uas0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'uas0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
	
    }
	local Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
			'M3_AeonSouthEast_To_Player_Naval_Chain1',
			--'M3_AeonSouthEast_To_Player_Naval_Chain2',	-- This one is too close to the UEF Main Base
			},
        },     
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	--Smaller Aeon Fleet for attacking Aiko
	Temp = {
        'M3_Aeon_SouthEastern_Naval_Attack_To_UEF',
        'NoPlan',
        --{ 'uas0302', 1, 1, 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
	
    }
	
	Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Naval_Attack_To_UEF_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M3_AeonSouthEast_To_UEFMain_Naval_Chain1',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
		
end

--Used only if FA units are allowed, builds T2 Amphibious Tanks
function M3AeonSouthEasternLandAttacks()
	local opai = nil
	local quantity = {4, 8, 12}
	
	--Sends [8, 16, 24] Amphibious Tanks sent to the highest threat
	for i = 1, 2  do
	opai = M3AeonSouthEasternBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SouthEastern_Amphibious_Assault' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
	opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
	opai:SetFormation('AttackFormation')
	end
end

--2 bases using transport attacks is not working as intended.
--Both use the same transport pool, so the South Eastern base can pick transports from Arnold's (North Western) base.
--Chances are, transports swapping between the 2 bases will get picked off on their way.
function M3AeonSouthEasternTransportAttacks()
	local opai = nil
	local quantity = {2, 4, 6}
	
	--Temporary T2 Transport Platoon
	local Temp = {
        'M3_Aeon_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
	local Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 12, -- Just in case only 1 transport remains alive from the platoons
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 16, categories.uaa0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	--Sends [T2] to players
	for i = 1, 2 do
		opai = M3AeonSouthEasternBase:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttacks_Northern_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Aeon_AttackChain',
                    LandingChain = 'M2_Aeon_Landing_Chain',
					--MovePath = 'M2_UEF_Transport_Move_Chain',
                    TransportReturn = 'M3_Aeon_SouthEastern_Base_Marker'
                },
                Priority = 160,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'RangeBots'})
		opai:SetChildCount(Difficulty)
	end
	
	--Sends [T2] to the Control Center
	for i = 1, 2 do	
		opai = M3AeonSouthEasternBase:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttacks_Southern_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'ControlCenterBig_Chain',
                    LandingChain = 'M2_Aeon_Landing_Chain',
					--MovePath = 'M2_UEF_Transport_Move_Chain',
                    TransportReturn = 'M3_Aeon_SouthEastern_Base_Marker'
                },
                Priority = 150,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'RangeBots'})
		opai:SetChildCount(Difficulty)
	end
end

function M3AeonSouthEasternAirAttacks()
    local opai = nil
	local quantity = {6, 12, 18}
	local trigger = {30, 25, 20}
		
	--Sends [12, 24, 36] Air Superiority Fighters to players if they have >= 30, 25, 20 air units
	for i = 1, 2 do
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_AirSuperiority_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain' .. Random(1, 2),
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
	end
	
	--Sends [6, 12, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	trigger = {15, 10, 5}
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain' .. Random(1, 2),
                },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	--Sends [6, 12, 18] Strategic Bombers to players
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_StratBombers_Attack', --.. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain' .. Random(1, 2),
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	
	--Sends [6, 12, 18] Gunships to players
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain' .. Random(1, 2),
                },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	--Sends random amounts of Gunships, Air Superiority Fighters, and Strategic Bombers.
	for i = 1, Difficulty do
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_Aeon_SouthEastern_General_Air_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Gunships', 'AirSuperiority', 'StratBombers', 'HeavyGunships'})
	opai:SetChildCount(Difficulty + 1)
	end
end

function M3AeonSouthEasternAirDefense()
    local opai = nil
	local quantity = {4, 10, 18}	--Air Factories = [2, 4, 6] depending on the Difficulty
	local ChildType = {}
	
	--If FA units are allowed
	if ExpansionPackAllowed == 2 then
		ChildType = {'AirSuperiority', 'Gunships', 'StratBombers', 'HeavyGunships', 'HeavyTorpedoBombers', 'CombatFighters'}
	else
		ChildType = {'AirSuperiority', 'Gunships', 'StratBombers'}
	end
	
	--Maintains [4, 10, 18] [Air Superiority Fighters, Heavy Gunships, Strategic Bombers]
	--Create platoons for each unit type.
	for k = 1, table.getn(ChildType) do
		opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_Aeon_SouthEastern_AirDefense' .. ChildType[k], --Example: 'M3_Aeon_SouthEastern_AirDefense_AirSuperiority'
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M3_Aeon_SouthEastern_Base_Patrol_Chain',
					},
				Priority = 200 - k,	--ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end