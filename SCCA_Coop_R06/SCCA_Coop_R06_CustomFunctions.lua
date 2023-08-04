local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local Cybran = 5
local Difficulty = ScenarioInfo.Options.Difficulty

-------------------
-- Build Conditions
-------------------

--- Build condition used to determine if we have transports to ferry land units
---@param aiBrain AIBrain
---@param numReq number
---@param platoonName string
---@return boolean
function HaveGreaterOrEqualThanUnitsInTransportPool(aiBrain, numReq, platoonName)
    -- Get either the specific transport platoon, or the universal 'TransportPool' platoon
    local platoon = aiBrain:GetPlatoonUniquelyNamed(platoonName) or aiBrain:GetPlatoonUniquelyNamed('TransportPool')
	
	-- In this case we need the platoon to exist, and have enough units to return true
	return platoon and table.getn(platoon:GetPlatoonUnits()) >= numReq
end

--- Build condition used to determine if need transports to be built
---@param aiBrain AIBrain
---@param numReq number
---@param platoonName string
---@return boolean
function HaveLessThanUnitsInTransportPool(aiBrain, numReq, platoonName)
	-- Get either the specific transport platoon, or the universal 'TransportPool' platoon
    local platoon = aiBrain:GetPlatoonUniquelyNamed(platoonName) or aiBrain:GetPlatoonUniquelyNamed('TransportPool')
	
	-- If neither exists, we need to build transports, return true
	if not platoon then
		return true
	end
	
	return table.getn(platoon:GetPlatoonUnits()) < numReq
end

--------------------
-- Platoon Functions
--------------------

-- Merges units produced by the Base Manager conditional build into the same platoon.
-- @PlatoonData
--		@Name - String, unique name for this platoon
--		@NumRequired - Number of experimentals to start moving the platoon
--		@PatrolChain - Name of the chain to use
--		@PatrolChains - Table of chain names, use this if you want to randomly pick between chains
function AddExperimentalToPlatoon(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local name = data.Name
    local unit = platoon:GetPlatoonUnits()[1]
    local plat = brain:GetPlatoonUniquelyNamed(name)
    local spawnThread = false

    if not plat then
        plat = brain:MakePlatoon('', '')
        plat:UniquelyNamePlatoon(name)
        plat:SetPlatoonData(data)
        spawnThread = true
    end

    brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
    brain:DisbandPlatoon(platoon)

    if spawnThread then
        ForkThread(MultipleExperimentalsPatrolThread, plat)
    end
end

--- Handles an unique platoon of multiple experimentals.
function MultipleExperimentalsPatrolThread(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    while brain:PlatoonExists(platoon) do
        if not platoon:IsPatrolling('Attack') then
            local numAlive = 0
            for _, v in platoon:GetPlatoonUnits() do
                if not v:IsDead() then
                    numAlive = numAlive + 1
                end
            end

            if numAlive == data.NumRequired then
				--We received a table of chains, pick one at random
				--Works fine even if only 1 chain was given
				if data.PatrolChains then
					--Pick a random chain from the table
					for _, v in ScenarioUtils.ChainToPositions(table.random(data.PatrolChains)) do
						platoon:Patrol(v)
					end
				--We received a single chain
				elseif data.PatrolChain then
					for _, v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
						platoon:Patrol(v)
					end
				--We didn't receive any valid chain data for the platoon
				else
					error('*CUSTOM FUNCTIONS AI ERROR: AddExperimentalToPlatoon PatrolChains or PatrolChain not defined.', 2)
				end
            end
        end
        WaitSeconds(10)
    end
end

--- Function: NavalHuntAI
--- Basic attack logic. Searches for a target unit, and attacks it, otherwise patrols Naval Area marker positions
---@param self Platoon
function NavalHuntAI(self)
    self:Stop()
    local aiBrain = self:GetBrain()
    local armyIndex = aiBrain:GetArmyIndex()
    local target
    local cmd = false
    local PlatoonFormation = self.PlatoonData.UseFormation or 'NoFormation'
    self:SetPlatoonFormationOverride(PlatoonFormation)
    local atkPri = { 'STRUCTURE ANTINAVY', 'MOBILE NAVAL', 'STRUCTURE NAVAL', 'COMMAND', 'EXPERIMENTAL', 'STRUCTURE STRATEGIC EXPERIMENTAL', 'ARTILLERY EXPERIMENTAL', 'STRUCTURE ARTILLERY TECH3', 'STRUCTURE NUKE TECH3', 'STRUCTURE ANTIMISSILE SILO',
        'STRUCTURE DEFENSE DIRECTFIRE', 'TECH3 MASSFABRICATION', 'TECH3 ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE', 'STRUCTURE', 'MOBILE', 'ALLUNITS' }
    local atkPriTable = {}
    for k,v in atkPri do
        table.insert(atkPriTable, ParseEntityCategory(v))
    end
    self:SetPrioritizedTargetList('Attack', atkPriTable)
    local maxRadius = 250
    for k,v in self:GetPlatoonUnits() do
        if v.Dead then
            continue
        end

        if v.Layer == 'Sub' then
            continue
        end

        if v:TestCommandCaps('RULEUCC_Dive') and v.UnitId != 'uas0401' then
            IssueDive({v})
        end
    end
    WaitSeconds(5)
    while aiBrain:PlatoonExists(self) do
        target = AIUtils.AIFindBrainTargetInRange(aiBrain, self, 'Attack', maxRadius, atkPri)
        if target then
            self:Stop()
            cmd = self:AggressiveMoveToLocation(target:GetPosition())
        end
        WaitSeconds(5)
        if (not cmd or not self:IsCommandsActive(cmd)) then
            target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
            if target then
                self:Stop()
                cmd = self:AggressiveMoveToLocation(target:GetPosition())
            else
                local scoutPath = {}
                scoutPath = AIUtils.AIGetSortedNavalLocations(self:GetBrain())
                for k, v in scoutPath do
                    self:Patrol(v)
                end
            end
        end
        WaitSeconds(20)
    end
end

-- Enables Stealth on Cybran ASFs, and StratBombers
function EnableStealthOnAir()
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304 + categories.ura0401, false) do
            if not (v.StealthEnabled or v:IsBeingBuilt()) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                v.StealthEnabled = true	--Entity IDs get recycled, using a unit-specific flag instead
            end
        end
        WaitSeconds(30)
    end
end

--  Moves to a set of locations, then disbands if desired
--	Designed for custom Engineer platoons (including sACUs) to move to an expansion base, then disband
--  @PlatoonData
--      @MoveRoute - List of locations to move to
--      @MoveChain - Chain of locations to move
--      @UseTransports - boolean, if true, use transports to move
--		@DisbandAfterArrival - boolean, if true, platoon disbands at the destination.
--  @param platoon Platoon
function EngineersMoveToThread(platoon)

	local cmd = false
    local data = platoon.PlatoonData
	local aiBrain = platoon:GetBrain()
	
	platoon:Stop()

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
				-- Only disband after the move command is finished
				if not platoon:IsCommandsActive(cmd) then
					aiBrain:DisbandPlatoon(platoon)
					return
				end
				WaitSeconds(5)
			end
		end
	end
end

--- Adds the platoon's engineer units to the BaseManager, used for expansion, or base rebuilding
---@param platoon Platoon
function AddPlatoonToBaseManager(platoon)
	platoon:StopAI()
	
	if not platoon.PlatoonData.BaseName then
		error('*CUSTOM FUNCTIONS AI ERROR: AddPlatoonToBaseManager PlatoonData not defined, requires BaseName', 2)
	end
	
	platoon:ForkAIThread(import('/lua/AI/OpAI/BaseManagerPlatoonThreads.lua').BaseManagerEngineerPlatoonSplit)
end

-- Checks if a base with the given name already exists for the given AI
function GetBaseLocation(brain, locationName)
    for _, v in brain.PBM.Locations do
        if v.LocationType == locationName then
            return v
        end
    end
    return false
end

-- Adds a unit as the primary land factory for an AI build location
-- @PlatoonData:
--		@BaseName 		- String, base name we send the Fatboy to, if it doesn't exist, it will be automatically created.
--		@RallyPoint 	- String, rally point name for the Fatboy to send its built units to
--		@MoveRoute 		- String, chain of locations the Fatboy will use to move to its destination
--		@FactoryType 	- String, Factory type, 'Land', 'Air', 'Sea', and 'Gate' are the options
--			The below PlatoonData are only needed if the base doesn't exist yet
--				@BaseMarker	- String, marker name of a new base we want to initially create
--				@BaseRadius	- Number, radius of a new base we want to initially create
-- @param platoon Single-unit platoon
function AddMobileFactory(platoon)
	local aiBrain = platoon:GetBrain()
	local data = platoon.PlatoonData
	local unit = platoon:GetPlatoonUnits()[1] -- Single-unit platoon
	
	-- Add build location if it doesn't exist yet
	if not GetBaseLocation(aiBrain, data.BaseName) then
		LOG('Creating ' .. data.BaseName .. 'because it doesn\'t exist yet.')
		aiBrain:PBMAddBuildLocation(data.BaseMarker, data.BaseRadius, data.BaseName)
	end
	
	-- Generic chain of move orders to get the Fatboy where we want it
	ScenarioFramework.PlatoonMoveRoute(platoon, data.MoveRoute)
	
	if not data.FactoryType then
		error('AI WARNING: AddMobileFactory() requires FactoryType data: Land, Air, Sea, or Gate are the valid ones.', 2)
	end
	
	for num, loc in aiBrain.PBM.Locations do
		if loc.LocationType == data.BaseName then
			loc.PrimaryFactories[data.FactoryType] = unit
			break
		end
	end
	
	IssueFactoryRallyPoint({unit}, ScenarioUtils.MarkerToPosition(data.RallyPoint))
end

-- Function for removing wreckages, useful for long in-game testing to avoid simspeed slowdowns due to wreckage counts
function AreaReclaimCleanUp()
	
	local Reclaimables = GetReclaimablesInRect(ScenarioUtils.AreaToRect('M3NewArea'))
		--Check if there are any reclaimables
		if not table.empty(Reclaimables) then
			LOG('*DEBUG: Reclaimables found, their current count:' .. table.getsize(Reclaimables))
			for k, v in Reclaimables do
				if v and v.IsWreckage and not v.IsUnit then	--IsUnit(unit) is the same as unit.IsUnit, the latter being added by FAF in 'Unit.lua'
					--Reduce wreckage health
					v:AdjustHealth(v, -1500)
					--If wreckage health is 0 or below, remove it
					if v:GetHealth() <= 0 then
						v:OnKilled()
					--If wreckage health is above 0, update reclaim values
					else
						v:UpdateReclaimLeft()
					end
				end
			end
		end
	LOG('DEBUG: Reclaimables successfully damaged.')
end
