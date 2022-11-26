--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m4aeonai.lua
--**  Author(s): --
--**
--**  Summary  : Aeon army AI for Mission 1 - X1CA_001
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- ------
-- Locals
-- ------
local Aeon = 7
local Difficulty = ScenarioInfo.Options.Difficulty
local FileName = '/maps/X1CA_001/X1CA_001_m4aeonai.lua'

-- -------------
-- Base Managers
-- -------------
local AmaliaMainBase = BaseManager.CreateBaseManager()
local AmaliaNavalBase = BaseManager.CreateBaseManager()

function AddAeonNavalBase()

	AmaliaMainBase:AddExpansionBase('Amalia_NavalBase', 2)
	
end

function AmaliaMainBaseAI()

    -- -----------
    -- Amalia Base
    -- -----------
    AmaliaMainBase:Initialize(ArmyBrains[Aeon], 'Amalia_MainBase', 'M4_Aeon_Base_Marker', 105,
		{
		M4_Aeon_Base_Factories = 250,
		M4_Aeon_Base_Economy = 200,
		M4_Aeon_Base_Defenses = 170,
		M4_Aeon_Base_Misc = 150,
		M4_Aeon_Base_Walls = 140,	
		}
	)
	
    AmaliaMainBase:StartEmptyBase({8, 7, 6})
	
	AmaliaMainBase:SetMaximumConstructionEngineers(8)
	
	AmaliaMainBase:SetActive('AirScouting', true)
	
	ArmyBrains[Aeon]:PBMSetCheckInterval(7)
	
	AmaliaMainAirAttacks()
	AmaliaMainLandAttacks()
	
	ScenarioFramework.CreateTimerTrigger(AddAeonNavalBase, 210)
	ScenarioFramework.CreateTimerTrigger(AmaliaNavalBaseAI, 210)
	
end

function AmaliaMainLandAttacks()
    local opai = nil
	
	for i = 1, 2 do
		opai = AmaliaMainBase:AddOpAI('BasicLandAttack', 'M4_AmaliaT3LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
				Priority = 130 + i,
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
		opai:SetChildCount(4)
	
	
	
		opai = AmaliaMainBase:AddOpAI('BasicLandAttack', 'M3_AmaliaCombinedLandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks',})
		opai:SetChildCount(6)
	
	
	
		opai = AmaliaMainBase:AddOpAI('BasicLandAttack', 'M2_AmaliaT2LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
				Priority = 150 + i,
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileShields',})
		opai:SetChildCount(5)
	end
end

function AmaliaMainAirAttacks()
	local opai = nil
	
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'M1_AmaliaT1AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Bombers', 'Interceptors'})
	opai:SetChildCount(2)
	
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'M2_AmaliaT2AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 130,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'CombatFighters', 'Gunships'})
	opai:SetChildCount(3)
	
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'M3_AmaliaCombinedAirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	opai:SetChildCount(5)
		
		
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'M4_AmaliaT3AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers'})
	opai:SetChildCount(3)
	
	-- Base Patrols
	
	for i = 1, 3 do
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'Amalia_AirDefense_ASF_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
				PatrolChain = 'Aeon_AirPatrol_Chain'
                },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 5)
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
	for i = 1, 3 do
	opai = AmaliaMainBase:AddOpAI('AirAttacks', 'Amalia_AirDefense_HeavyGunships_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_AirPatrol_Chain'
				},
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyGunships', 5)
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	
end

function AmaliaNavalBaseAI()
    -- Aeon M3 Naval Base
    AmaliaNavalBase:Initialize(ArmyBrains[Aeon], 'Amalia_NavalBase', 'Aeon_NavalBase_Marker', 65, 
		{
			M4_Aeon_NavalBase = 150,
		}
	)
    AmaliaNavalBase:StartEmptyBase({4, 3, 2})
    AmaliaNavalBaseNavalAttacks()
end	

function AmaliaNavalBaseNavalAttacks()
	local opai = nil

    -- ----------------------------------------
    -- Aeon M3 Naval Base Op AI, Naval Attacks
    -- ----------------------------------------

    -- sends 6-18 frigate power of [frigates]
    opai = AmaliaNavalBase:AddNavalAI('Aeon_NavalAttack1',
        {
            MasterPlatoonFunction = {FileName, 'AeonNavalAI'},
            --EnableTypes = {'Frigate'},
            MaxFrigates = 18,
            MinFrigates = 6,
            Priority = 120,
        }
    )
	opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Aeon'}, 1, categories.uab0303, '>='})

    -- sends 12-36 frigate power of [frigates, subs]
    opai = AmaliaNavalBase:AddNavalAI('Aeon_NavalAttack2',
        {
            MasterPlatoonFunction = {FileName, 'AeonNavalAI'},
            --EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 36,
            MinFrigates = 12,
            Priority = 110,
        }
    )
	opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Aeon'}, 1, categories.uab0303, '>='})

    -- sends 18-48 frigate power of [all but T3]
    opai = AmaliaNavalBase:AddNavalAI('Aeon_NavalAttack3',
        {
            MasterPlatoonFunction = {FileName, 'AeonNavalAI'},
            MaxFrigates = 48,
            MinFrigates = 18,
            Priority = 100,
        }
    )
    --opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Aeon'}, 1, categories.uab0303, '>='})
end

function AeonNavalAI(platoon)

	local moveNum = false
	
	while(ArmyBrains[Aeon]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 1) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Allied_NavalChain')
					end
				end
            end
        elseif(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Allied_NavalChain')
					end
				end
            end
		elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Allied_NavalChain')
					end
				end
            end
		elseif(ScenarioInfo.MissionNumber == 4) then
            if(not moveNum or moveNum ~= 4) then
                moveNum = 4
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Allied_NavalChain')
					end
				end
            end
        end
        WaitSeconds(10)
    end	
end
