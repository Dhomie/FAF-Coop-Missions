--****************************************************************************
--**
--**  File     : /maps/X1CA_002/X1CA_002_transportfunctions.lua
--**  Author(s): GVH
--**
--**  Summary  : Transport AI for any army - X1CA_002
--****************************************************************************

-- LOCALS
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local Difficulty = ScenarioInfo.Options.Difficulty

local transportTypes = {
	UEFT1 = 'uea0107',
	UEFT2 = 'uea0104',
	UEFT3 = 'xea0306',
	AEONT1 = 'uaa0107',
	AEONT2 = 'uaa0104',
	CYBT1 = 'ura0107',
	CYBT2 = 'ura0104',
	SERAT1 = 'xsa0107',
	SERAT2 = 'xsa0104',
}
local tTypeCount = table.getn(transportTypes)

local armies = {
	'Player1',
	'Order',
	'QAI',
	'Loyalist',
	'OrderNeutral',
	'Cybran',
	'UEF',
}

local armycount = table.getn(armies)


-- NOTES:	army must be the actual name or index. The index will be converted to the name using the table 'armies' above.
--			IDs only require the actual ID, also in ''.
--			For points, use actual markers! Tables do not function at this moment.
--			transportDelete & platoon are bools. if platoon = true, then unitPatrolChain will be used.
--			Spawning should not take place in the playable area!
--			unitPatrolChain should always be a valid string, found in _save.lua

function SingleTransportWithUnitType(army, transportID, unitCount, unitID, transportSpawnPoint, DropPoint, transportReturn, platoonBool, unitPatrolChain)
	ForkThread(function()
	local armyIndex = nil
	local aiBrain = false
	local unit = {}
	local transport = nil
	local allUnits = nil
	local platoon = false
	local cmd = false
	local orientation = 0

		LOG('====== Starting transport sequences ======')
		-- Army string?
		if type(army) == 'string' then		
			if army == 'Player1'  or army == 'Order' or army == 'QAI' or army == 'Loyalist' or army == 'OrderNeutral' or army == 'Cybran' or army == 'UEF' then
				-- LOG('Army ' .. army .. ' is a valid player.')
			else
				LOG('Army ' .. army .. ' is not a valid player. Aborting!')
				return
			end
			-- Determine army index
			for index = 1, armycount do
				if army == armies[index] then armyIndex = index
				end
			end
		else	-- if an index is given
			-- LOG('army ' .. army .. ' is not a string. Converting index to army name ...')
			-- check if index is between 1 and [max players]
			if army > armycount or army <= 0 then
				LOG('Army index invalid --- 0 < index <= 5 --- Aborting!')
				return
			end
			for i = 1, armycount do
				if army == i then
					armyIndex = i
					army = armies[i]
					-- LOG('Index converted to name. army with index ' .. i .. ' determined to be army - ' .. army .. ' -.')
				end
			end
		end
		-- Pointing out the type of transport:
		if transportID == transportTypes.UEFT1 then LOG('Transport type: UEF T1 C-6 Courier')
		elseif transportID == transportTypes.UEFT2 then LOG('Transport type: UEF T2 C14 Star Lifter')
		elseif transportID == transportTypes.UEFT3 then LOG('Transport type: UEF T3 Continental')
		elseif transportID == transportTypes.AEONT1 then LOG('Transport type: Aeon T1 Chariot')
		elseif transportID == transportTypes.AEONT2 then LOG('Transport type: Aeon T2 Aluminar')
		elseif transportID == transportTypes.CYBT1 then LOG('Transport type: Cybran T1 Skyhook')
		elseif transportID == transportTypes.CYBT2 then LOG('Transport type: Cybran T2 Dragon Fly')
		elseif transportID == transportTypes.SERAT1 then LOG('Transport type: Seraphim T1 Vish')
		elseif transportID == transportTypes.SERAT2 then LOG('Transport tupe: Seraphim T2 Vishala')
		else LOG('TransportID is not an air transportation unit. Aborting!') return end
		
		-- spawning the transport and units:
		
		-- if spawning for the Loyalist, change orientation!
		if army == 'Loyalist' then orientation = 3 end
		
		if unitCount <= 0 then unitCount = 1 end
		if type(transportSpawnPoint) == 'string' then
			-- LOG('Marker detected: ' .. transportSpawnPoint .. ' - converting it to a position')
			local spawn = ScenarioUtils.MarkerToPosition(transportSpawnPoint)
			-- LOG('Spawning transport and units at marker ' .. transportSpawnPoint .. '. Position = ' .. spawn[1] .. ', ' .. spawn[2] .. ', ' .. spawn[3] .. '.')
			transport = CreateUnitHPR( transportID, army, spawn[1], spawn[2], spawn[3], 0, orientation, 0 )
			
			if unitCount == 1 then
				unit[1] = CreateUnitHPR( unitID, army, spawn[1], spawn[2], spawn[3], 0, 0, 0 )
			else
				for i = 1, unitCount do
					unit[i] = CreateUnitHPR( unitID, army, spawn[1], spawn[2], spawn[3], 0, 0, 0 )
				end
			end
		else -- if type(transportSpawnPoint) == 'table' then
			-- LOG('Spawning transport and units at ' .. transportSpawnPoint[1] .. ', ' .. transportSpawnPoint[2] .. ', ' .. transportSpawnPoint[3] .. '.')
			transport = CreateUnitHPR( transportID, army, transportSpawnPoint[1], transportSpawnPoint[2], transportSpawnPoint[3], 0, 0, 0 )
			
			if unitCount == 1 then
				unit[1] = CreateUnitHPR( unitID, army, transportSpawnPoint[1], transportSpawnPoint[2], transportSpawnPoint[3], 0, 0, 0 )
			else
				for i = 1, unitCount do
					unit[i] = CreateUnitHPR( unitID, army, transportSpawnPoint[1], transportSpawnPoint[2], transportSpawnPoint[3], 0, 0, 0 )			
				end
			end
		--else
		--	LOG('Transport Spawn Point is invalid. Use a map marker or a table consisting of THREE coordinates. Aborting!')
		--	return
		end
		
		WaitSeconds(1)
		
		-- Check if the unitID is a mobile land unit
		-- Else, destroy the units and transport
		if unitCount == 1 then
			if EntityCategoryContains(categories.MOBILE * categories.LAND, unit[1]) then
				-- LOG('the unitID - ' .. unitID .. ' - is a valid land unit for transportation')
			else
				LOG('the unitID - ' .. unitID .. ' - is not a valid land unit for transportation. Aborting!')
				transport:Destroy()
				unit[1]:Destroy()
				return
			end
		else
			for i = 1, unitCount do
				if EntityCategoryContains(categories.MOBILE * categories.LAND - categories.EXPERIMENTAL, unit[i]) then
					-- LOG('the unitID - ' .. unitID .. ' - is a valid land unit for transportation')
				else
					if i == 1 then
						LOG('the unitID - ' .. unitID .. ' - is not a valid land unit for transportation. Aborting!')
						transport:Destroy()
					end
					unit[i]:Destroy()
					if i == unitCount then
						return
					end
				end
			end
		end
		
		WaitSeconds(1)
		
		-- check for T3, max units = 2!
		-- I rely on the fact that I won't exceed the transport capacities for T2 and T1
		if EntityCategoryContains(categories.TECH3, unit[1]) then
			if unitCount > 2 then
				LOG('Too many units have been spawned for the transport! Deleting some of them.')
				local deleteIndex = 3
				for i = deleteIndex, unitCount do
					unit[i]:Destroy()
				end
				unitCount = 2
			end
		end
		
		-- if the ID corresponds with an engineer, ACU of sACU, then always disband!
		if EntityCategoryContains(categories.ENGINEER, unit[1]) then
			LOG('Engineer unit detected. Preparing disband.')
			platoonBool = false
		end
			
		-- Attach units to the transport
		-- LOG('Attaching units to the transport')
		platoon = ArmyBrains[armyIndex]:MakePlatoon('', '')
		-- Also get the brain now to disband later if desired	
		aiBrain = platoon:GetBrain()
		for i = 1, unitCount do
			ArmyBrains[armyIndex]:AssignUnitsToPlatoon(platoon, {unit[i]}, 'Attack', 'GrowthFormation')
		end
		
		allUnits = platoon:GetPlatoonUnits()
		ScenarioFramework.AttachUnitsToTransports( allUnits, {transport} )
		-- LOG('Units attached to the transport')
		
		-- Unload the units at the designated position/marker.
		if type(DropPoint) == 'string' then
			-- LOG('A marker has been detected as DropPoint: ' .. DropPoint .. '. Converting it to a position.')
			local drop = ScenarioUtils.MarkerToPosition(DropPoint)
			cmd = IssueTransportUnload( {transport}, drop )
			-- LOG('Unloading transport at marker ' .. DropPoint .. '. Location = ' .. drop[1] .. ', ' .. drop[2] .. ', ' .. drop[3] .. '.')
		elseif type(DropPoint) == 'table' then
			local drop = {DropPoint[1], DropPoint[2], DropPoint[3]}
			cmd = IssueTransportUnload( {transport}, drop )
			-- LOG('Unloading transport at location: ' .. drop[1] .. ', ' .. drop[2] .. ', ' .. drop[3] .. '.')
		end
		
		-- wait for unload to be completed.
		for k, v in allUnits do
			while(not v:IsDead() and v:IsUnitState('Attached')) do
				WaitSeconds(.5)
			end
		end
		if not transport:IsDead() then
			-- LOG('Unload complete.')
		else LOG('Transport destroyed') end
		
		-- Units must start a patrol if platoon = true. Else, disband platoon.
		local platoonUnits = platoon:GetPlatoonUnits()
		for k, v in platoonUnits do
			if v:IsDead() then
				return
			end
		end
		if platoonBool == true then
			if type(unitPatrolChain) == 'string' then
				ScenarioFramework.PlatoonPatrolChain(platoon, unitPatrolChain)
				-- LOG('Units are commencing their patrol. Chain = ' .. unitPatrolChain .. '.')
			else
				LOG('The patrol chain for the platoon - ' .. unitPatrolChain .. ' - is not valid. Use a string with name as found in _save.lua.')
				LOG('Units will remain at their current position.')
			end
		else	-- probably only when giving engineers, this was already taken care of.
			aiBrain:DisbandPlatoon(platoon)
			LOG('Disbanding platoon')
		end
		
		-- Moving transport and deleting it.
		-- LOG('Moving transport to remove point.')
		if type(transportReturn) == 'string' then
			local removeloc = ScenarioUtils.MarkerToPosition(transportReturn)
			cmd = IssueMove({transport}, removeloc)
		elseif type(transportReturn) == 'table' then
			local removeLoc = {transportReturn[1], transportReturn[2], transportReturn[3]}
			cmd = IssueMove({transport}, removeLoc)
		else
			LOG('Transport return point is invalid! Removing transport at current location.')
			transport:Destroy()
		end
		
		while not IsCommandDone(cmd) do
			WaitSeconds(1)
		end
		-- LOG('Removing transport')
		transport:Destroy()	
		LOG('====== Transport script succesfully executed! ======')
	end )
end