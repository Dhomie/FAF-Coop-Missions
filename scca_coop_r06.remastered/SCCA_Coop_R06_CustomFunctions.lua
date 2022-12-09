local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local Cybran = 5
local UEF = 3
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

--- Merges units produced by the Base Manager conditional build into the same platoon.
-- PlatoonData = {
--		Name - String, unique name for this platoon
--		NumRequired - Number of experimentals to start moving the platoon
--		PatrolChain - Name of the chain to use
-- }
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
					local chain = Random(1, table.getn(data.PatrolChains))
					for _, v in ScenarioUtils.ChainToPositions(data.PatrolChains[chain]) do
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

--Enables Stealth on Cybran ASFs, and StratBombers
function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(20)
    end
end
----------------------------------------------------------------------------------------------------------
--  EngineersMoveToThread
--      Description: Moves to a set of locations, then disbands if desired
--			Designed for custom Engineer platoons (including sACUs) to move to an expansion base, then disband
--  @PlatoonData
--      -MoveRoute - List of locations to move to
--      -MoveChain - Chain of locations to move
--      -UseTransports - boolean, if true, use transports to move
--		-DisbandAfterArrival - boolean, if true, platoon disbands at the destination.
--  @param platoon Platoon
-----------------------------------------------------------------------------------------------------------
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

--Checks if a base with the given name already exists for the given AI
function GetBaseLocation(brain, locationName)
    for _, v in brain.PBM.Locations do
        if v.LocationType == locationName then
            return v
        end
    end
    return false
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function: AddMobileFactory
-- 		Description: Adds a Fatboy as the primary factory for an AI build location
--	@PlatoonData:
--		-BaseName - String, base name we send the Fatboy to, if it doesn't exist, it will be automatically created.
--		-RallyPoint - String, rally point name for the Fatboy to send its built units to
--		-MoveRoute - String, chain of locations the Fatboy will use to move to its destination
--			-The below PlatoonData are only needed if the base doesn't exist yet
--				-BaseMarker - String, marker name of a new base we want to initially create
--				-BaseRadius - Number, radius of a new base we want to initially create
-- 	@param platoon Platoon
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function AddMobileFactory(platoon)
	local aiBrain = platoon:GetBrain()
	local data = platoon.PlatoonData
	local unit = platoon:GetPlatoonUnits() --Single-unit platoon
	
	--Add build location if it doesn't exist yet
	if not GetBaseLocation(aiBrain, data.BaseName) then
		LOG('Creating' .. data.BaseName .. 'because it doesn\'t exist yet.')
		aiBrain:PBMAddBuildLocation(data.BaseMarker, data.BaseRadius, data.BaseName)
	end
	
	--Generic chain of move orders to get the Fatboy where we want it
	ScenarioFramework.PlatoonMoveRoute(platoon, data.MoveRoute)
	
	--Add the Fatboy as the primary land factory
	for num, loc in aiBrain.PBM.Locations do
		if loc.LocationType == data.BaseName then
			loc.PrimaryFactories.Land = unit[1]
			break
		end
	end
	
	IssueFactoryRallyPoint({unit[1]}, ScenarioUtils.MarkerToPosition(data.RallyPoint))
end

--Function for removing wreckages, useful for long in-game testing to avoid simspeed slowdowns due to wreckage counts
function AreaReclaimCleanUp()
	
	--Define a table for the reclaimables
	local Reclaimables = GetReclaimablesInRect(ScenarioUtils.AreaToRect('M3NewArea'))
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
