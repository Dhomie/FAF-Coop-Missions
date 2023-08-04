-------------------------------------------------------------------------------
--  File     : SCCA_Coop_R06_AIBehaviors.lua
--  Author(s): Dhomie42
--  Summary  : Skirmish-like AI threads, used AIBehaviors.lua as a base
-------------------------------------------------------------------------------
local AIBehaviors = import('/lua/ai/aibehaviors.lua')

--- Table: SurfacePriorities AKA "Your stuff just got wrecked" priority list.
--- Description: Provides a list of target priorities an experimental should use when wrecking stuff or deciding what stuff should be wrecked next.
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
--- Determines if the platoon is in water
--- @param platoon Platoon
--- @return boolean
function InWaterCheck(platoon)
    local t4Pos = platoon:GetPlatoonPosition()
    local inWater = GetTerrainHeight(t4Pos[1], t4Pos[3]) < GetSurfaceHeight(t4Pos[1], t4Pos[3])
    return inWater
end

--- Finds a unit in the base we're currently wrecking.
--- Returns with unit to wreck, and the base, or nil.
--- @param platoon Platoon
--- @param base Vector, Location of the base to wreck
--- @return unit, position
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

--- Find a base to attack. Sit outside of the base, and build units.
--- @PlatoonData:
---		@BuildTable 	- Table of string unit BP IDs to choose from, default are Percies, Spearheads, and Titans
---		@Formation 		- String formation, use 'GrowthFormation' or 'AttackFormation', default is 'NoFormation'
---		@UnitCount 		- Number, exact size for the children platoon, high numbers cause cluttering, default is 20
---		@SitDistance 	- Number, distance from the target to begin building from, it's added to the main weapon range, so don't crazy with this, default is 10
--- @param self Platoon, preferably a single-unit Fatboy platoon

function FatBoyBehavior(self)
    local aiBrain = self:GetBrain()
    AIBehaviors.AssignExperimentalPriorities(self)

    local experimental = self:GetPlatoonUnits()[1]	
    local lastBase = false
	
	--Some platoon data to allow customization, but also consider that we don't receive any platoon data
	local PlatoonSize = self.PlatoonData.UnitCount or 20
	local Distance = self.PlatoonData.SitDistance or 10
	

    local mainWeapon = experimental:GetWeapon(1)
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius

    experimental.Platoons = experimental.Platoons or {}

    -- Find target loop
    while experimental and not experimental.Dead do
		lastBase = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, experimental)	--We need a threat location only
		if lastBase then
            IssueClearCommands({experimental})
			
			--Move straight at the target
			IssueMove({experimental}, lastBase)

            -- Wait to get in range
            local pos = experimental:GetPosition()
            while (VDist2(pos[1], pos[3], lastBase[1], lastBase[3]) > weaponRange + Distance
                and not experimental.Dead and not experimental:IsIdleState()) or InWaterCheck(self) == true do
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
        WaitSeconds(4)
    end
end


--- Builds a random land unit defined in BuildTable, or defaults to Percies, Titans, and Spearheads
--- @param self Platoon, preferably a single-unit Fatboy platoon
function FatBoyBuildCheck(self)
	local data = self.PlatoonData
    local aiBrain = self:GetBrain()
    local experimental = self:GetPlatoonUnits()[1]
	local unitToBuild = nil
	local SetFormation = data.Formation or 'NoFormation'

	--If we received a list of units to build from, let's use that.
	if data.BuildTable then
		--Check if we received a valid table
		if type(data.BuildTable) == 'table' then
			unitToBuild = table.random(data.BuildTable)
		else
			error('*WARNING: Value for BuildTable received, but it\'s not a table type!', 2)
		end
	--If we didn't receive a list of units to build from, pick between Titans, Percivals, and Spearheads
	else
		local buildUnits = {'uel0303', 'xel0305', 'xel0306', }
		unitToBuild = table.random(buildUnits)
	end

    aiBrain:BuildUnit(experimental, unitToBuild, 1)
    WaitTicks(1)

    local unitBeingBuilt = false
    repeat
        unitBeingBuilt = unitBeingBuilt or experimental.UnitBeingBuilt
        WaitSeconds(1)
    until experimental.Dead or unitBeingBuilt or aiBrain:GetArmyStat("UnitCap_MaxCap", 0.0).Value - aiBrain:GetArmyStat("UnitCap_Current", 0.0).Value < 10

    repeat
        WaitSeconds(3)
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

--- Fatboy's children platoon AI thread. Wrecks the base that the fatboy has selected.
--- If base is wrecked, the units will guard the fatboy, until a new target base is reached for them to attack.
--- @param self Fatboy's child platoon
--- @param parent Parent Fatboy the child platoon belongs to
--- @param base The base to be attacked
function FatboyChildBehavior(self, parent, base)
    local aiBrain = self:GetBrain()
    local targetUnit = false
	local closestTarget = nil

    -- Find target loop
    while aiBrain:PlatoonExists(self) and not table.empty(self:GetPlatoonUnits()) do
        targetUnit, base = WreckBase(self, base)

        if not base then
            -- Wrecked base.
            self:Stop()
			-- Guard parent Fatboy if it is alive, kill the AI thread, the Fatboy will call this function again once a new base is found
			if parent and not parent.Dead then
				IssueGuard(self:GetPlatoonUnits(), parent)
				return
			-- Parent got killed, let's avenge it, attack-move to the closest enemy unit, or self-destruct instead.
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

        WaitSeconds(4)
    end
end

--- Find a base to attack. Sit outside of the base in weapon range and build units.
--- @PlatoonData:
---		@BuildTable 	- Table of string unit BP IDs to choose from, default are Destroyers, and Cruisers
---		@Formation 		- String formation, use 'GrowthFormation' or 'AttackFormation', default is 'NoFormation'
---		@UnitCount 		- Number, exact size for the children platoon, high numbers cause cluttering, default is 10
---		@SitDistance 	- Number, distance from the target to begin building from, it's added to the main weapon range, so don't crazy with this, default is 10
--- @param self Platoon, preferably a single-unit Tempest

function TempestBehavior(self)
    local aiBrain = self:GetBrain()
    AIBehaviors.AssignExperimentalPriorities(self)

    local experimental = self:GetPlatoonUnits()[1]
    local lastBase = false
	
	--Some platoon data to allow customization, but also consider that we don't receive any platoon data
	local PlatoonSize = self.PlatoonData.UnitCount or 10
	local Distance = self.PlatoonData.SitDistance or 10
	

    local mainWeapon = experimental:GetWeapon(1)
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius

    experimental.Platoons = experimental.Platoons or {}

    -- Find target loop
    while experimental and not experimental.Dead do
		lastBase = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, experimental)	--We need a threat location only
		if lastBase then
            IssueClearCommands({experimental})
			
			--Attack-Move to the location
			IssueAggressiveMove({experimental}, lastBase)

            -- Wait to get in range
            local pos = experimental:GetPosition()
            while VDist2(pos[1], pos[3], lastBase[1], lastBase[3]) > weaponRange + Distance and not experimental.Dead and not experimental:IsIdleState() do
				WaitSeconds(5)
            end

            IssueClearCommands({experimental})

            -- Send our boats to wreck this base
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
                platoon:ForkAIThread(TempestChildBehavior, experimental, lastBase)
            end

            -- Setup shop outside this guy's base
            while not experimental.Dead and WreckBase(self, lastBase) do
                -- Build stuff if we haven't hit the unit cap.
                TempestBuildCheck(self)

                -- Once we have enough units, form them into a platoon and send them to attack the base we're attacking!
                if experimental.NewPlatoon and table.getn(experimental.NewPlatoon:GetPlatoonUnits()) >= PlatoonSize then
                    experimental.NewPlatoon:ForkAIThread(TempestChildBehavior, experimental, lastBase)

                    table.insert(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
                end
                WaitSeconds(2)
            end
        end
        WaitSeconds(4)
    end
end

--- Builds a random naval unit defined in BuildTable, or defaults to Destroyers, and Cruisers
--- @param self Platoon, a single-unit Tempest platoon
function TempestBuildCheck(self)
	local data = self.PlatoonData
    local aiBrain = self:GetBrain()
    local experimental = self:GetPlatoonUnits()[1]
	local unitToBuild = nil
	local SetFormation = data.Formation or 'NoFormation'

	--If we received a list of units to build from, let's use that.
	if data.BuildTable then
		--Check if we received a valid table
		if type(data.BuildTable) == 'table' then
			unitToBuild = table.random(data.BuildTable)
		else
			error('*WARNING: Value for BuildTable received, but it\'s not a table type!')
		end
	--If we didn't receive a list of units to build from, pick Destroyers, and Cruisers
	else
		local buildUnits = {'uas0201', 'uas0202',}
		unitToBuild = table.random(buildUnits)
	end

    aiBrain:BuildUnit(experimental, unitToBuild, 1)
    WaitTicks(1)

    local unitBeingBuilt = false
    repeat
        unitBeingBuilt = unitBeingBuilt or experimental.UnitBeingBuilt
        WaitSeconds(1)
    until experimental.Dead or unitBeingBuilt or aiBrain:GetArmyStat("UnitCap_MaxCap", 0.0).Value - aiBrain:GetArmyStat("UnitCap_Current", 0.0).Value < 10

    repeat
        WaitSeconds(3)
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

--- Tempest's children platoon AI thread. Wrecks the base that the Tempest has selected.
--- If base is wrecked, the units will guard the Tempest, until a new target base is reached for them to attack.
--- @param self Tempest's child platoon
--- @param parent Parent Tempest the child platoon belongs to
--- @param base The base to be attacked
function TempestChildBehavior(self, parent, base)
    local aiBrain = self:GetBrain()
    local targetUnit = false
	local closestTarget = nil

    -- Find target loop
    while aiBrain:PlatoonExists(self) and not table.empty(self:GetPlatoonUnits()) do
        targetUnit, base = WreckBase(self, base)

        if not base then
            -- Wrecked base.
            self:Stop()
			-- Guard parent Tempest if it is alive, kill the AI thread, the Tempest will call this function again once a new base is found
			if parent and not parent.Dead then
				IssueGuard(self:GetPlatoonUnits(), parent)
				return
			-- Parent got killed, let's avenge it, attack the closest enemy unit, or self-destruct instead.
			else
				closestTarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
				-- Closest target found, let's wreck 'em.
				if closestTarget and not closestTarget.Dead then
					SPEW('DEBUG: Parent Tempest has been destroyed, child platoon is attacking the closest enemy.')
					self:Stop()
					self:AttackTarget(targetUnit)
				-- Nothing to commit vengeance on, self-destruct instead.
				else
					SPEW('DEBUG: Parent Tempest has been destroyed, no nearest enemies found, self-destructing.')
					for k, v in self:GetPlatoonUnits() do
						if v and not v.Dead then
							v:Kill()
						end
					end
				end
			end
        end

        if targetUnit and not targetUnit.Dead then
            self:Stop()
			self:AttackTarget(targetUnit)
        end

        -- Sail to and kill target loop
        while aiBrain:PlatoonExists(self) and not table.empty(self:GetPlatoonUnits()) and not targetUnit.Dead do
            WaitSeconds(6)
        end

        WaitSeconds(4)
    end
end
