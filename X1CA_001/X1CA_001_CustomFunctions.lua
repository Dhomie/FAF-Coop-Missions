local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local M2CybranAI = import ('/maps/X1CA_001/X1CA_001_m2cybranai.lua')
local M4AeonAI = import ('/maps/X1CA_001/X1CA_001_m4aeonai.lua')
local OpStrings = import('/maps/X1CA_001/X1CA_001_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local AIBehaviors = import('/lua/ai/aibehaviors.lua')
--local CustomFunctions = import ('/maps/X1CA_001/X1CA_001_CustomFunctions.lua')

--------------------------------------------------------------------------------
-- Player's choice to spawn in both, 1-1, or none of the added allied factions.
--------------------------------------------------------------------------------

function GateInDimitriButton()
    -- Setup ping
    ScenarioInfo.GateInDimitriPing = PingGroups.AddPingGroup(OpStrings.Allied_Commander_GateIn_Title, 'url0001', 'attack', OpStrings.Allied_Commander_GateIn_Description)
    ScenarioInfo.GateInDimitriPing:AddCallback(GateInDimitriDialogue)
end

function GateInDimitriDialogue()
    -- Create a comfirmation dialogue for creation of allied commander
    local dialogue = CreateDialogue(OpStrings.Allied_Commander_GateIn_Confirmation, {'<LOC _Yes>', '<LOC _No>'})
    dialogue.OnButtonPressed = function(self, info)
        dialogue:Destroy()
        if info.buttonID == 1 then
		
            ScenarioInfo.CybranCDR = ScenarioFramework.SpawnCommander('Cybran', 'Dimitri_ACU', 'Warp', 'CDR Dimitri', false, false,
			{'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation', 'MicrowaveLaserGenerator'})
			M2CybranAI.CybranMainBaseAI()
			ScenarioInfo.CybranCDR:SetCanBeKilled(false)
            ScenarioInfo.GateInDimitriPing:Destroy()
			ScenarioInfo.GateInDimitriPing = nil
			
        end
    end
end

function GateInAmaliaButton()
    -- Setup ping
    ScenarioInfo.GateInAmaliaPing = PingGroups.AddPingGroup(OpStrings.Allied_Commander_GateIn_Title, 'ual0001', 'attack', OpStrings.Allied_Commander_GateIn_Description)
    ScenarioInfo.GateInAmaliaPing:AddCallback(GateInAmaliaDialogue)
end

function GateInAmaliaDialogue()
    -- Create a comfirmation dialogue for creation of allied commander
    local dialogue = CreateDialogue(OpStrings.Allied_Commander_GateIn_Confirmation, {'<LOC _Yes>', '<LOC _No>'})
    dialogue.OnButtonPressed = function(self, info)
        dialogue:Destroy()
        if info.buttonID == 1 then
		
            ScenarioInfo.AeonCDR = ScenarioFramework.SpawnCommander('Aeon', 'Amalia_ACU', 'Warp', 'CDR Amalia', false, false,
			{'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation', 'ResourceAllocationAdvanced', 'HeatSink'})
			M4AeonAI.AmaliaMainBaseAI()
			ScenarioInfo.AeonCDR:SetCanBeKilled(false)
            ScenarioInfo.GateInAmaliaPing:Destroy()
			ScenarioInfo.GateInAmaliaPing = nil
			
        end
    end
end

--Function for removing wreckages, useful for long in-game testing to avoid simspeed slowdowns due to wreckage counts
--It should only be used for debug/testing purposes
function AreaReclaimCleanUp(area)

	--Define a table for the reclaimables
	local Reclaimables = GetReclaimablesInRect(ScenarioUtils.AreaToRect(area))
		--Check if there are any reclaimables
		if table.getsize(Reclaimables) > 0 then
			LOG('*DEBUG: Reclaimables found, their current count:' .. table.getsize(Reclaimables))
			for k,v in Reclaimables do
				if v then
					--NOTE: Apparently 'IsWreckedUnit()' is not a global
					if not IsUnit(v) then --and IsWreckedUnit(v) then
						--Wreckage health gets reduced
						v:AdjustHealth(v, -1500)
						--If wreckage health is 0 or below, it gets deleted
						if v:GetHealth() <= 0 then
							v:DoPropCallbacks('OnKilled')
							v:Destroy()
						else
						--If wreckage health is above 0, reclaim values get updated
							v:UpdateReclaimLeft()
						end
					end
				end
			end
		end
	LOG('DEBUG: Reclaimables successfully damaged.')
end

--Function that finds enemy armies and inserts them into a table
function GetAllEnemies(armyIndex)
    enemies = {}

    for i, brain in ArmyBrains do
        if IsEnemy(armyIndex, brain:GetArmyIndex()) then
            table.insert(enemies, brain)
        end
    end

    return enemies
end

---------------------------------------------------------------------------------------------------------------
--  CategoryHunterPlatoonAI
--      Summary: Platoon attacks the closest hostile unit of specified categories, it cheats to find the units.
--  PlatoonData -
--      CategoryList : The categories we are going to find and attack
--  function: CategoryHunterPlatoonAI = AddFunction
--      parameter 0: string: platoon = "default_platoon"
----------------------------------------------------------------------------------------------------------------
function CategoryHunterPlatoonAI(platoon)
    local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    local data = platoon.PlatoonData
    local target = false
    while aiBrain:PlatoonExists(platoon) do
        -- Find nearest enemy category to this platoon
        -- Cheat to find the focus army's units
        local newTarget = false
        local platPos = platoon:GetPlatoonPosition()
        local enemies = table.shuffle(GetAllEnemies(aiBrain:GetArmyIndex()))
        for i, enemy in enemies do
            for catNum, category in platoon.PlatoonData.CategoryList do
                local unitList = enemy:GetListOfUnits(category, false, false)
                if table.getn(unitList) > 0 then
                    local distance = 100000
                    for _, v in unitList do
                        if not v.Dead then
                            local currDist = VDist3(platPos, v:GetPosition())
                            if currDist < distance then
                                newTarget = v
                                distance = currDist
                            end
                        end
                    end
                    -- If the target has changed, attack new target
                    if newTarget ~= target then
                        platoon:Stop()
                        platoon:AttackTarget(newTarget)
                    end
                end
                if newTarget then
                    break
                end
            end
        end

        -- If there are no targets, seek out and fight nearest enemy the platoon can find; no cheating here
        if not newTarget then
            target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
            if target and not target.Dead then
                platoon:Stop()
                platoon:AggressiveMoveToLocation(target:GetPosition())

            -- If we still cant find a target, go to the highest threat position on the map
            else
                platoon:Stop()
                platoon:AggressiveMoveToLocation(aiBrain:GetHighestThreatPosition(1, true))
            end
        end
        WaitSeconds(15)
    end
end

-------------------------------------------------------------------------------------
-- Table: SurfacePriorities AKA "Your stuff just got wrecked" priority list.
-- Description: Provides a list of target priorities an experimental should use when
-- wrecking stuff or deciding what stuff should be wrecked next.
-------------------------------------------------------------------------------------
local SurfacePriorities = {
    'COMMAND',
    'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
    'TECH3 ENERGYPRODUCTION STRUCTURE',
    'TECH2 ENERGYPRODUCTION STRUCTURE',
    'TECH3 MASSEXTRACTION STRUCTURE',
    'TECH3 INTELLIGENCE STRUCTURE',
    'TECH2 INTELLIGENCE STRUCTURE',
    'TECH1 INTELLIGENCE STRUCTURE',
    'TECH3 SHIELD STRUCTURE',
    'TECH2 SHIELD STRUCTURE',
    'TECH2 MASSEXTRACTION STRUCTURE',
    'TECH3 FACTORY LAND STRUCTURE',
    'TECH3 FACTORY AIR STRUCTURE',
    'TECH3 FACTORY NAVAL STRUCTURE',
    'TECH2 FACTORY LAND STRUCTURE',
    'TECH2 FACTORY AIR STRUCTURE',
    'TECH2 FACTORY NAVAL STRUCTURE',
    'TECH1 FACTORY LAND STRUCTURE',
    'TECH1 FACTORY AIR STRUCTURE',
    'TECH1 FACTORY NAVAL STRUCTURE',
    'TECH1 MASSEXTRACTION STRUCTURE',
    'TECH3 STRUCTURE',
    'TECH2 STRUCTURE',
    'TECH1 STRUCTURE',
    'TECH3 MOBILE LAND',
    'TECH2 MOBILE LAND',
    'TECH1 MOBILE LAND',
    'EXPERIMENTAL LAND',
}

----------------------------------------------------------------------------------------------------------
--  EngineersMoveToThread
--      Summary: Moves to a set of locations, then disbands if desired
--  @PlatoonData:
--      -MoveRoute - List of locations to move to
--      -MoveChain - Chain of locations to move
--      -UseTransports - Boolean, if true, use transports to move
--		-DisbandAfterArrival - Boolean, if true, platoon disbands at the destination.
--	@param platoon Platoon
-----------------------------------------------------------------------------------------------------------
function EngineersMoveToThread(platoon)

	local cmd = false
    local data = platoon.PlatoonData
	local aiBrain = platoon:GetBrain()

    if data then
        if data.MoveRoute or data.MoveChain then
            local movePositions = {}
            if data.MoveChain then
                movePositions = ScenarioUtils.ChainToPositions(data.MoveChain)
            else
                for _, v in data.MoveRoute do
                    if type(v) == 'string' then
                        table.insert(movePositions, ScenarioUtils.MarkerToPosition(v))
                    else
                        table.insert(movePositions, v)
                    end
                end
            end
            if data.UseTransports then
                for _, v in movePositions do
                cmd = platoon:MoveToLocation(v, data.UseTransports)
                end
            else
                for _, v in movePositions do
                cmd = platoon:MoveToLocation(v, false)
                end
            end
        else
            error('*CUSTOM FUNCTIONS  AI ERROR: EngineersMoveToThread MoveRoute or MoveChain not defined', 2)
        end
    else
        error('*CUSTOM FUNCTIONS AI ERROR: EngineersMoveToThread PlatoonData not defined', 2)
    end
	
	if cmd then
		if data.DisbandAfterArrival then
			while aiBrain:PlatoonExists(platoon) do
				--Only disband after the move command is finished
				if not platoon:IsCommandsActive(cmd) then
					aiBrain:DisbandPlatoon(platoon)
					return
				end
				WaitSeconds(5)
			end
		end
	end
end

-----------------------------------------------------------
-- Function: InWaterCheck
-- 		Summary: Determines if the platoon is in water
-- 		Returns: Boolean, true if platoon is in water, false if it's not
--	@param platoon Platoon
-----------------------------------------------------------
function InWaterCheck(platoon)
    local t4Pos = platoon:GetPlatoonPosition()
    local inWater = GetTerrainHeight(t4Pos[1], t4Pos[3]) < GetSurfaceHeight(t4Pos[1], t4Pos[3])
    return inWater
end

-------------------------------------------------------
-- Function: WreckBase
-- 		Summary: Finds a unit in the base we're currently wrecking.
-- 		Returns: Unit to wreck, base. Else nil.
--	@param platoon Platoon
--	@param base Vector, Location of the base to wreck
-------------------------------------------------------
WreckBase = function(self, base)
    for _, priority in SurfacePriorities do
        local numUnitsAtBase = 0
        local notDeadUnit = false
        local unitsAtBase = self:GetBrain():GetUnitsAroundPoint(ParseEntityCategory(priority), base, 100, 'Enemy')
        for _, unit in unitsAtBase do
            if not unit.Dead then
                notDeadUnit = unit
                numUnitsAtBase = numUnitsAtBase + 1
            end
        end

        if numUnitsAtBase > 0 then
            return notDeadUnit, base
        end
    end
end

--------------------------------------------------------------------------------------------------------------------
-- Function: FatBoyBehavior
-- 		Summary:Find a base to attack. Sit outside of the base in weapon range and build units.
--	@PlatoonData:
--		-BuildTable - Table of unit IDs Fatboy chooses from, it's not called here, but saved for FatBoyBuildCheck()
--		-Formation - String formation, 'GrowthFormation' and 'AttackFormation' are the 2 most common
--		-UnitCount - Number, set the exact size for the children platoon, high numbers cause cluttering
--		-SitDistance - Number, distance from the target the Fatboy should begin building from
--					-It's added to the main weapon range, so don't crazy with this.
--	@param self Platoon
--------------------------------------------------------------------------------------------------------------------

function FatBoyBehavior(self)
    local aiBrain = self:GetBrain()
    AIBehaviors.AssignExperimentalPriorities(self)

    local experimental = AIBehaviors.GetExperimentalUnit(self)
    local lastBase = false
	local PlatoonSize = self.PlatoonData.UnitCount or 20
	local Distance = self.PlatoonData.SitDistance or 10
	

    local mainWeapon = experimental:GetWeapon(1)
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius

    experimental.Platoons = experimental.Platoons or {}

    -- Find target loop
    while experimental and not experimental.Dead do
		LOG('DEBUG: Fatboy found, AI is starting.')
		lastBase = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, experimental)	--We need a threat location only
		if lastBase then
			LOG('DEBUG: Fatboy found a target, commencing attack.')
            IssueClearCommands({experimental})

            if InWaterCheck(self) then
				IssueMove({experimental}, lastBase)	--Move to the location if we're under water
            else
				IssueAggressiveMove({experimental}, lastBase)	--Attack-Move to the location if we're on the surface.
            end

            -- Wait to get in range
            local pos = experimental:GetPosition()
            while VDist2(pos[1], pos[3], lastBase[1], lastBase[3]) > weaponRange + Distance
                and not experimental.Dead and not experimental:IsIdleState() or InWaterCheck(self) == true do
				WaitSeconds(5)
            end

            IssueClearCommands({experimental})

            -- Send our homies to wreck this base
            local goodList = {}
            for _, platoon in experimental.Platoons do
                local platoonUnits = false

                if aiBrain:PlatoonExists(platoon) then
                    platoonUnits = platoon:GetPlatoonUnits()
                end

                if platoonUnits and not table.empty(platoonUnits) then
                    table.insert(goodList, platoon)
                end
            end

            experimental.Platoons = goodList
            for _, platoon in goodList do
                platoon:ForkAIThread(FatboyChildBehavior, experimental, lastBase)
            end

            -- Setup shop outside this guy's base
            while not experimental.Dead and WreckBase(self, lastBase) do
                -- Build stuff if we haven't hit the unit cap.
                FatBoyBuildCheck(self)

                -- Once we have enough units, form them into a platoon and send them to attack the base we're attacking!
                if experimental.NewPlatoon and table.getn(experimental.NewPlatoon:GetPlatoonUnits()) >= PlatoonSize then
                    experimental.NewPlatoon:ForkAIThread(FatboyChildBehavior, experimental, lastBase)

                    table.insert(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
                end
                WaitSeconds(2)
            end
        end
		LOG('DEBUG: Fatboy couldn\'t find a target, searching.')
        WaitSeconds(4)
    end
	LOG('DEBUG: Fatboy not found / is dead, AI function terminating.')
end

-----------------------------------------------------------------------
-- Function: FatBoyBuildCheck
-- 		Description: Builds a random land unit defined in BuildTable
-- 	@param self Platoon
-----------------------------------------------------------------------
function FatBoyBuildCheck(self)
	local data = self.PlatoonData
    local aiBrain = self:GetBrain()
    local experimental = AIBehaviors.GetExperimentalUnit(self)
	local unitToBuild = nil
	local SetFormation = data.Formation or 'NoFormation'

	--If we received a list of units to build from, let's use that.
	if data.BuildTable then
		--Check if we received a valid table
		if type(data.BuildTable) == 'table' then
			unitToBuild = data.BuildTable[Random(1, table.getn(data.BuildTable))]
		else
			WARN('*WARNING:Value for BuildTable received, but it\'s not a table type!')
		end
	--If we didn't receive a list of units to build from, pick between Spearheads, Titans, and Percivals
	else
		local buildUnits = {'uel0303', 'xel0305', 'xel0306', }
		unitToBuild = buildUnits[Random(1, table.getn(buildUnits))]
	end

    aiBrain:BuildUnit(experimental, unitToBuild, 1)
    WaitTicks(1)

    local unitBeingBuilt = false
    repeat
        unitBeingBuilt = unitBeingBuilt or experimental.UnitBeingBuilt
        WaitSeconds(2)
    until experimental.Dead or unitBeingBuilt or aiBrain:GetArmyStat("UnitCap_MaxCap", 0.0).Value - aiBrain:GetArmyStat("UnitCap_Current", 0.0).Value < 10

    repeat
        WaitSeconds(4)
    until experimental.Dead or experimental:IsIdleState() or aiBrain:GetArmyStat("UnitCap_MaxCap", 0.0).Value - aiBrain:GetArmyStat("UnitCap_Current", 0.0).Value < 10

    if not experimental.NewPlatoon or not aiBrain:PlatoonExists(experimental.NewPlatoon) then
        experimental.NewPlatoon = aiBrain:MakePlatoon('', '')
    end

    if unitBeingBuilt and not unitBeingBuilt.Dead then
        aiBrain:AssignUnitsToPlatoon(experimental.NewPlatoon, {unitBeingBuilt}, 'Attack', SetFormation)
        IssueClearCommands({unitBeingBuilt})
        IssueGuard({unitBeingBuilt}, experimental)
    end
end

------------------------------------------------------------------------------------------------
-- Function: FatboyChildBehavior
-- 		Description: AI for fatboy child platoons. Wrecks the base that the fatboy has selected.
-- 		Once the base is wrecked, the units will return to guard the fatboy until a new
-- 		target base is reached, at which point they will attack it.
--	@param self The platoon of Fatboy children to run the behavior on
--	@param parent The parent Fatboy the child platoon belongs to
--	@param base The base to be attacked
-------------------------------------------------------------------------------------------------
function FatboyChildBehavior(self, parent, base)
    local aiBrain = self:GetBrain()
    local targetUnit = false
	local closestTarget = nil

    -- Find target loop
    while aiBrain:PlatoonExists(self) and not table.empty(self:GetPlatoonUnits()) do
        targetUnit, base = WreckBase(self, base)

        if not base then
            -- Wrecked base. Kill AI thread
            self:Stop()
			-- Guard parent Fatboy if it is alive
			if parent then
				IssueGuard(self:GetPlatoonUnits(), parent)
			-- Parent got killed, let's avenge it, attack-move to the closest enemy unit, if it doesn't exist, self-destruct instead.
			else
				closestTarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
				-- Closest target found, let's wreck 'em.
				if closestTarget and not closestTarget.Dead then
					LOG('DEBUG: Parent Fatboy has been destroyed, child platoon is attack-moving to the closest enemy.')
					self:Stop()
					self:AggressiveMoveToLocation(closestTarget:GetPosition())
				-- Nothing to commit vengeance on, self-destruct instead.
				else
					LOG('DEBUG: Parent Fatboy has been destroyed, no nearest enemies found, self-destructing.')
					for k, v in self:GetPlatoonUnits() do
						if v and not v.Dead then
							v:Kill()
							WaitSeconds(0.75)
						end
					end
				end
			end
        end

        if targetUnit and not targetUnit.Dead then
            self:Stop()
            self:AggressiveMoveToLocation(targetUnit:GetPosition())
        end

        -- Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and not table.empty(self:GetPlatoonUnits()) and not targetUnit.Dead do
            WaitSeconds(6)
        end

        WaitSeconds(3)
    end
end