--****************************************************************************
--**
--**  File     : /maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_M1AeonAI
--**  Author(s): Dhomie42
--**
--**  Summary  : Aeon army AI for Mission 1 - SCCA_Coop_R06.modified
--****************************************************************************
local BaseManager = import('/maps/SCCA_Coop_R06.modified/SCCA_Coop_R06_BaseManager.lua')

-- ------
-- Locals
-- ------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionPackAllowed = ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units -- 1 --> disallowed, 2 --> allowed.
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local MainScript = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_script.lua'
local CustomFunctions = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_CustomFunctions.lua'

--Used for CategoryHunterPlatoonAI
local ConditionCategories = {
    ExperimentalAir = categories.EXPERIMENTAL * categories.AIR,
    ExperimentalLand = categories.uel0401 + (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    ExperimentalNaval = categories.EXPERIMENTAL * categories.NAVAL,
	GameEnderStructure = categories.ueb2401 + (categories.STRATEGIC * categories.TECH3) + (categories.EXPERIMENTAL * categories.STRUCTURE) + categories.NUKE, --Merged Nukes and HLRAs
}
-- -------------
-- Base Managers
-- -------------
local AeonMainBase = BaseManager.CreateBaseManager()

function M2AeonMainExpansion()
	AeonMainBase:AddBuildGroup('MainBaseStructuresPostBuilt_D' .. Difficulty, 200)
end

function AeonMainBaseAI()
	-- -----------
    -- Aeon Base
    -- -----------
    AeonMainBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M1_Aeon_Main_Base', 'AeonBase', 210,
		{
		MainBaseStructuresPreBuilt = 300,
		}
	)
	
	AeonMainBase:StartNonZeroBase({4, 8, 12})
	AeonMainBase:SetMaximumConstructionEngineers(12)
	ArmyBrains[Aeon]:PBMSetCheckInterval(5)
	
	--This doesn't work, the ACU will be stuck in a limbo of removing 'Shield' and upgrading again, due to it being a requirement for 'ShieldHeavy'.
	--AeonMainBase:SetACUUpgrades({'CrysalisBeam', 'Shield', 'ShieldHeavy', 'HeatSink'}, false)
	
	AeonMainBase:SetActive('AirScouting', true)
    AeonMainBase:SetActive('LandScouting', true)
	
	AeonMainAirDefense()
	AeonMainAirAttacks()
	AeonMainNavalAttacks()
	AeonMainTransportAttacks()
	AeonMainExperimentalNavalAttacks()
	AeonMainExperimentalAttacks()
	M1CzarBuilder()
	M2AeonMainExpansion()
	
	--If FA units are allowed
	if ExpansionPackAllowed == 2 then
		AeonMainLandAttacks()
	end
end

function AeonMainAirDefense()
    local opai = nil
	local quantity = {4, 10, 18}	--Air Factories = [4, 5, 6] depending on the Difficulty
	local ChildType = {}
	
	--If FA units are allowed
	if ExpansionPackAllowed == 2 then
		ChildType = {'AirSuperiority', 'Gunships', 'StratBombers', 'HeavyGunships', 'HeavyTorpedoBombers', 'CombatFighters'}
	else
		ChildType = {'AirSuperiority', 'Gunships', 'StratBombers', 'TorpedoBombers'}
	end
		
	--Maintains [4, 10, 18] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_AirDefense_' .. ChildType[k],	--Example: 'M1_Aeon_AirDefense_AirSuperiority'
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
					PlatoonData = {
						PatrolChain = 'M1_Aeon_Base_Air_Patrol_Chain',
					},
					Priority = 260 - k, --ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function AeonMainAirAttacks()
    local opai = nil
	local quantity = {}
	local trigger = {}
		
	--Sends [8, 20, 36] Gunships.
	quantity = {4, 10, 18}
	for i = 1, 2 do
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_Gunship_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	end
	
	quantity = {4, 10, 18}
	trigger = {15, 10, 5}
	--Sends [4, 10, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'PlayerNavalAttack_Chain',
                },
				Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	--Sends random amounts of Gunships, Air Superiority Fighters, and Strategic Bombers.
	for i = 1, Difficulty do
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_General_Air_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
	opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Gunships', 'AirSuperiority', 'StratBombers', 'HeavyGunships'})
	opai:SetChildCount(Difficulty + 1)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end
	
	--Builds [4, 10, 18] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_GameEnderStructure_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.GameEnderStructure},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.GameEnderStructure, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})

	--Builds [4, 10, 18] Strategic Bombers if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_LandExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalLand},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalLand, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	--Builds, [8, 20, 36] Air Superiority Fighters if players have >= 3, 2, 1 active Air Experimental units, and attacks said Experimentals
	quantity = {8, 20, 36}
	trigger = {3, 2, 1}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalAir},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalAir, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
end

function AeonMainNavalAttacks()
	local opai = nil
	local PatrolDestroyerQuantity = {2, 4, 6}
	local PatrolCruiserQuantity = {1, 2, 3}
	local T3Quantity = {2, 4, 6}
	local T2Quantity = {4, 8, 12}
	local T1Quantity = {6, 12, 18}
	
	--Large Aeon Naval Fleet for attacking the players
	local Temp = {
        'M2_Aeon_Main_Naval_Fleet',
        'NoPlan',
        { 'uas0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'uas0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		--{ 'uas0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		--{ 'uas0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M2_Aeon_Main_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'PlayerNavalAttack_Chain',
        },     
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	--Small Naval Fleet for attacking Aiko at Phase 3
	Temp = {
        'M3_Aeon_Main_Naval_Attack_To_UEF',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_Aeon_Main_Naval_Attack_To_UEF_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
				PatrolChains = {
				'M3_AeonToUEF_Naval_Chain',
				'M3_AeonNorthWest_To_UEFSouthWest_Naval_Chain',
				},
            },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	--Maintains [4/2, 16/8, 36/18] Destroyers/Cruisers respectively
	for i = 1, 2 * Difficulty do
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {PatrolDestroyerQuantity[Difficulty], PatrolCruiserQuantity[Difficulty]})
	opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	--Maintains [4/2, 8/4, 16/8] Destroyers/Cruisers respectively North of Arnold's base
	for i = 1, Difficulty do
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Northen_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_North_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {PatrolDestroyerQuantity[Difficulty], PatrolCruiserQuantity[Difficulty]})
	--opai:SetFormation('AttackFormation')
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

--Used only if FA units are allowed, builds T2 Amphibious Tanks
function AeonMainLandAttacks()
	local opai = nil
	local quantity = {4, 8, 12}
	
	--Sends [8, 16, 24] Amphibious Tanks sent to the highest threat
	for i = 1, 2  do
	opai = AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Amphibious_Assault' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
	opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
	opai:SetFormation('AttackFormation')
	end
end

function AeonMainTransportAttacks()
	local opai = nil
	local quantity = {4, 5, 6}
	
	--Temporary T2 Transport Platoon
	local Temp = {
        'M1_Aeon_Main_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
	local Builder = {
        BuilderName = 'M1_Aeon_Main_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 12, -- Just in case only 1 transport remains alive from the platoons
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.uaa0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	--Send random [T3 + T2]
	--BaseManager is allergic to Mobile Shields in random compositions, it spams them, going way over the actually defined ChildCount, and the ones exceeding it are left idle, and not used.
	for i = 1, 2 do	
		opai = AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_TransportAttacks_Northen_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Aeon_AttackChain',
                    LandingChain = 'M2_Aeon_Landing_Chain',
                    TransportReturn = 'AeonBase'
                },
                Priority = 160 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery', 'MobileFlak', 'MobileMissiles', 'HeavyTanks'}) --Removed 'MobileShields' and 'HeavyBots' due to unintended spam.
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})
	end
	
	--Send random [T3 + T2]
	--BaseManager is allergic to Mobile Shields in random compositions, it spams them, going way over the actually defined ChildCount, and the ones exceeding it are left idle, and not used.
	for i = 1, 2 do	
		opai = AeonMainBase:AddOpAI('BasicLandAttack', 'M2_Aeon_TransportAttacks_Southern_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'ControlCenterBig_Chain', --'Aeon_AttackChain'
                    LandingChain = 'M2_Aeon_Landing_Chain',
                    TransportReturn = 'AeonBase'
                },
                Priority = 150 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery', 'MobileFlak', 'MobileMissiles', 'HeavyTanks'}) --Removed 'MobileShields' and 'HeavyBots' due to unintended spam.
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})
	end
end

--Tempest platoon, for Phase 3
function AeonMainExperimentalNavalAttacks()
	local opai = nil
	local number = {1, 1, 2}
	
	--Send [1, 1, 2] Tempests at the Players
	for i = 1, number[Difficulty] do
        opai = AeonMainBase:AddOpAI('M3_Tempest_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Tempest_Platoon',
                    NumRequired = number[Difficulty],
					PatrolChains = {
						'PlayerNavalAttack_Chain',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual',
						{3}}
				},
                MaxAssist = 3,
                Retry = true,
            }
        )
    end
	
end

--Czar for Phase 1, built only once.
function M1CzarBuilder()
	local opai = nil

	opai = AeonMainBase:AddOpAI('Czar',
        {
            Amount = 1,
            KeepAlive = false,
			--Unit's function is defined in the main script
            PlatoonAIFunction = {MainScript, 'CzarAI'},
            MaxAssist = 1,
			--This Czar is only for the first objective, so we don't want it to be built again
            Retry = false,
        }
    )
end

--Galactic Collosus platoon, for Phase 3
function AeonMainExperimentalAttacks()
	local opai = nil
	
	--Sends [1, 2, 3] Galactic Collosuses to the players
	for i = 1, Difficulty do
        opai = AeonMainBase:AddOpAI('M3_GC_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Galatic_Colossus_Platoon',
                    NumRequired = Difficulty,
                    PatrolChains = {
						'M3_Aeon_GC_Chain_1',
						'M3_Aeon_GC_Chain_2',
						'M3_Aeon_GC_Chain_3',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual',
						{3}}
				},
                MaxAssist = 3,
                Retry = true,
            }
        )
    end
end

--Called if Arnold's ACU is destroyed, disables the Aeon base completely, but already active platoons will still follow their orders.
function DisableAeonMainBase()
	--Base Manager gets disabled
    if(AeonMainBase) then
        AeonMainBase:SetBuild('Engineers', false)
		AeonMainBase:SetBuild('Experimentals', false)
        AeonMainBase:SetBuildAllStructures(false)
        AeonMainBase:SetActive('AirScouting', false)
        AeonMainBase:SetActive('LandScouting', false)
        AeonMainBase:BaseActive(false)
    end
	
	--Custom platoons need to be removed from the AI brain manually
	--Reverted, this wipes all Aeon platoons, if Arnold is killed during part 3, the South Eastern base's platoons will be wiped too.
	--ArmyBrains[Aeon]:PBMClearPlatoonList(true) --If set to true, the AI will try to form platoons from existing units before completely wiping its list
end