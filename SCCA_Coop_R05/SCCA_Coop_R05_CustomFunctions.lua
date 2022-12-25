local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local UEF = 2

----------------------------------------------------------------------------------------------------------
--  EngineersMoveToThread
--      Moves to a set of locations, then disbands if desired
--		Designed for custom Engineer platoons (including sACUs) to move to an expansion base, then disband
--  PlatoonData
--      MoveRoute - List of locations to move to
--      MoveChain - Chain of locations to move
--      UseTransports - boolean, if true, use transports to move
--		DisbandAfterArrival - boolean, if true, platoon disbands at the destination.
--  function: MoveToThread = AddFunction
--      parameter 0: string: platoon = "default_platoon"
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

--Sets AI functions found in platoon.lua to OpAI instances
function UsePlatoonPlan(platoon)
	local data = platoon.PlatoonData
	if data.PlatoonAIPlan then
		platoon:SetAIPlan(data.PlatoonAIPlan)
	end
end

--Function for removing wreckages, useful for long in-game testing to avoid simspeed slowdowns due to wreckage counts
--It should only be used for debug/testing purposes
function AreaReclaimCleanUp()
	--Define the area (rectangle) we want reclaimables to "decay" inside of
    local rect = ScenarioUtils.AreaToRect('M3NewArea')
	
	--Define a table for the reclaimables
	local Reclaimables = GetReclaimablesInRect(rect)
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
