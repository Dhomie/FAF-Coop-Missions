--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m2cybranai.lua
--**  Author(s): --
--**
--**  Summary  : Cybran army AI for Mission 1 - X1CA_001
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CFFileName = '/maps/X1CA_001/X1CA_001_CustomFunctions.lua'

-- ------
-- Locals
-- ------
local Cybran = 6
local Difficulty = ScenarioInfo.Options.Difficulty
local FileName = '/maps/X1CA_001/X1CA_001_m2cybranai.lua'
-- -------------
-- Base Managers
-- -------------
local CybranMain = BaseManager.CreateBaseManager()
local CybranNavalBase = BaseManager.CreateBaseManager()

function AddCybranNavalBase()
	CybranMain:AddExpansionBase('Cybran_NavalBase', 2)
end

function CybranMainBaseAI()

	-- -----------
    -- Cybran Base
    -- -----------
    CybranMain:Initialize(ArmyBrains[Cybran], 'M2_Cybran_Base', 'Cybran_Base_Marker', 135,
		{
		M2_Cybran_Base_Factories = 250,
		M2_Cybran_Base_Economy = 200,
		M2_Cybran_Base_Defenses = 170,
		M2_Cybran_Base_Misc = 150,
		M2_Cybran_Base_Walls = 140,	
		}
	)

    CybranMain:StartEmptyBase({8, 7, 6})
	
	CybranMain:SetMaximumConstructionEngineers(8)
	
	CybranMain:SetSupportACUCount(1)
	CybranMain:SetSACUUpgrades({'Switchback', 'NaniteMissileSystem', 'ResourceAllocation'}, false)
	
	ArmyBrains[Cybran]:PBMSetCheckInterval(7)
	
	CybranMain:SetActive('AirScouting', true)
    --CybranMain:SetActive('LandScouting', true)
	
	CybranMainLandAttacks()
	CybranMainAirAttacks()
	
	ScenarioFramework.CreateTimerTrigger(AddCybranNavalBase, 210)
	ScenarioFramework.CreateTimerTrigger(CybranNavalBaseAI, 210)
end

function CybranMainLandAttacks()
    local opai = nil
	
	for i = 1, 2 do
		opai = CybranMain:AddOpAI('BasicLandAttack', 'M4_DimT3LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
				Priority = 130 + i,
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir'})
		opai:SetChildCount(4)
	
	
	
		opai = CybranMain:AddOpAI('BasicLandAttack', 'M3_DimCombinedLandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'HeavyBots', 'MobileHeavyArtillery', 'HeavyMobileAntiAir', 'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots'})
		opai:SetChildCount(6)
	
	
	
		opai = CybranMain:AddOpAI('BasicLandAttack', 'M2_DimT2LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
				Priority = 150 + i,
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'RangeBots', 'MobileStealth'})
		opai:SetChildCount(6)
	end
end

function CybranMainAirAttacks()
    local opai = nil
		
	opai = CybranMain:AddOpAI('AirAttacks', 'M1_DimT1AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 90,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'Bombers', 'Interceptors', 'LightGunships'})
	opai:SetChildCount(3)
	--opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})

	opai = CybranMain:AddOpAI('AirAttacks', 'M2_DimT2AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'CombatFighters', 'Gunships'})
	opai:SetChildCount(3)
	--opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	
	opai = CybranMain:AddOpAI('AirAttacks', 'M3_DimCombinedAirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers', 'CombatFighters', 'Gunships'})
	opai:SetChildCount(5)
	--opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	
	opai = CybranMain:AddOpAI('AirAttacks', 'M4_DimT3AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 120,
        }
    )
    opai:SetChildActive('All', false)
	opai:SetChildrenActive({'HeavyGunships', 'AirSuperiority', 'StratBombers'})
	opai:SetChildCount(3)
	--opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	
	for i = 1, 3 do
	opai = CybranMain:AddOpAI('AirAttacks', 'DimAirDefense_ASF_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Cybran_AirPatrol_Chain'
                },
                Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 6)
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function CybranNavalBaseAI()

    -- -------------------
    -- Cybran M3 Naval Base
    -- -------------------
    CybranNavalBase:Initialize(ArmyBrains[Cybran], 'Cybran_NavalBase', 'Cybran_NavalBase_Marker', 70,
		{
			M2_Cybran_NavalBase = 100,
		}
	)
    CybranNavalBase:StartEmptyBase({4, 3, 2})

    CybranNavalBaseNavalAttacks()
end	

function CybranNavalBaseNavalAttacks()

	local opai = nil

    -- ----------------------------------------
    -- Cybran M3 Naval Base Op AI, Naval Attacks
    -- ----------------------------------------

    -- sends 6-18 frigate power of [frigates]
    opai = CybranNavalBase:AddNavalAI('Cybran_NavalAttack1',
        {
            MasterPlatoonFunction = {FileName, 'CybranNavalAI'},
            --EnableTypes = {'Frigate'},
            MaxFrigates = 18,
            MinFrigates = 6,
            Priority = 120,
        }
    )
	opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Cybran'}, 1, categories.urb0303, '>='})

    -- sends 12-36 frigate power of [frigates, subs]
    opai = CybranNavalBase:AddNavalAI('Cybran_NavalAttack2',
        {
            MasterPlatoonFunction = {FileName, 'CybranNavalAI'},
            --EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 36,
            MinFrigates = 12,
            Priority = 110,
        }
    )
	opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Cybran'}, 1, categories.urb0303, '>='})

    -- sends 18-48 frigate power of [all] 
    opai = CybranNavalBase:AddNavalAI('Cybran_NavalAttack3',
        {
            MasterPlatoonFunction = {FileName, 'CybranNavalAI'},
            MaxFrigates = 48,
            MinFrigates = 18,
            Priority = 100,
        }
    )
    --opai:SetChildActive('T3', false)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 4})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Cybran'}, 1, categories.urb0303, '>='})

end

function CybranNavalAI(platoon)

	local moveNum = false
	
	while(ArmyBrains[Cybran]:PlatoonExists(platoon)) do
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
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Allied_NavalChain') --Cybran_M3_Chain
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