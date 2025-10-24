AddCSLuaFile()

function ENT:InitLegs()
	self.Legs = {}
	self.LastGait = CurTime()

	self:BuildLegs()
end

function ENT:UpdateLegs()
	self:UpdateGait()

	for _, leg in ipairs(self.Legs) do
		leg.Solver(self, leg)
	end
end

local function clampVector2D(vel, length)
	if vel:Length2D() > length then
		vel:Normalize()
		vel:Mul(length)
	end
end

function ENT:UpdateGait()
	local delta = CurTime() - self.LastGait
	self.LastGait = CurTime()

	local vel = self:GetMechVelocity()

	local length = self:GetMoveStat(self.Stance)
	local stepSize = self:GetMoveStat(self.StepSize)
	local mul = math.max(vel:Length(), self.WalkSpeed) / stepSize * (1 - length) * 2

	delta = delta * mul

	clampVector2D(vel, stepSize / 4)

	vel:Div(self:GetMoveStat(self.ForwardLean))

	local oldCycle = self:GetWalkCycle()
	local cycle = oldCycle + delta

	self:SetWalkCycle(cycle % 1)

	local groundOffset = self:GetGroundOffset()

	local gaitOffset = Vector()
	local sideStep = self:GetMoveStat(self.SideStep)
	local upStep = self:GetMoveStat(self.UpStep)

	if not self:CanMove() and (oldCycle == 0 or cycle > 1) then
		for _, leg in ipairs(self.Legs) do
			local offset = self:LocalToWorld(leg.Offset)
			local target, normal = self:FindGround(offset, leg.MaxLength)

			leg.Ground = target
			leg.Pos = target
			leg.Target = target

			leg.Normal = normal

			local z = -(target:Distance(offset) - groundOffset) / upStep

			gaitOffset.z = gaitOffset.z + z
		end

		self:SetGaitOffset(gaitOffset / #self.Legs)
		self:SetWalkCycle(0)

		return
	elseif not self:GetOnGround() then
		for _, leg in ipairs(self.Legs) do
			leg.Pos = self:LocalToWorld(leg.Offset - Vector(0, 0, groundOffset * 0.75))
			leg.Ground = self:FindGround(self:LocalToWorld(leg.Offset), leg.MaxLength)

			leg.Normal = self:GetUp()
		end

		self:SetGaitOffset(Vector())
		self:SetWalkCycle(0)

		return
	end

	for k, leg in ipairs(self.Legs) do
		local gaitStart = leg.Timing
		local gaitEnd = leg.Timing + length

		local fraction = 0
		local canMove = false

		if cycle >= gaitStart and cycle <= gaitEnd then
			fraction = (cycle - gaitStart) / (gaitEnd - gaitStart)
			canMove = true
		elseif gaitStart < 0 then
			if cycle >= math.abs(gaitStart) and cycle <= 1 then
				fraction = (cycle - gaitStart) / (gaitEnd - gaitStart)
				canMove = true
			end
		elseif gaitEnd > 1 then
			if cycle + 1 >= gaitStart and cycle + 1 <= gaitEnd then
				fraction = (cycle + 1 - gaitStart) / (gaitEnd - gaitStart)
				canMove = true
			end
		end

		local offset = self:LocalToWorld(leg.Offset)
		local target, normal = self:FindGround(offset + vel, leg.MaxLength * 1.5)

		local distance = target:Distance(leg.Ground)
		local hasTarget = distance > 5

		if canMove then
			if hasTarget or leg.Moving then
				leg.Target = target

				-- if CLIENT and not leg.Moving then
				-- 	leg.Debug = self:WorldToLocal(leg.Ground):Length2D()
				-- end

				-- Is GroundOffset still the best method to use here?
				local bezier = math.QuadraticBezier(fraction,
					leg.Ground,
					LerpVector(0.5, leg.Ground, leg.Target) + Vector(0, 0, 1) * math.min(distance * 0.5, groundOffset),
					leg.Target)

				leg.Pos = LerpVector(fraction, bezier, leg.Target)

				local normalFraction = math.min(distance / groundOffset, 1)

				local mid1 = LerpVector(normalFraction, leg.OldNormal, (leg.Pos - leg.Ground):GetNormalized())
				local mid2 = LerpVector(normalFraction, normal, (leg.Pos - leg.Target):GetNormalized())

				leg.Normal = math.CubicBezier(fraction, leg.OldNormal, mid1, mid2, normal)
				leg.Normal:Normalize()

				if not leg.Moving then
					self:OnStepStart(k, leg)
				end

				leg.Moving = true
			end
		elseif leg.Moving then
			leg.Ground = leg.Target
			leg.Pos = leg.Target

			leg.Normal = normal
			leg.OldNormal = normal

			-- if CLIENT then
			-- 	print("---", _, "---")
			-- 	print(self:WorldToLocal(leg.Target):Length2D() - leg.Debug)
			-- end

			self:OnStepFinish(k, leg)

			leg.Moving = false
		end

		local sideOffset = (self:WorldToLocal(leg.Pos) - leg.Offset).x / (stepSize / 4)

		local y = sideOffset * leg.Offset:GetNormalized().y * sideStep
		local z = -(leg.Pos:Distance(offset) - groundOffset) / upStep

		gaitOffset:Add(Vector(0, y, z))
	end

	local oldOffset = self:GetGaitOffset()
	local accel = 10 -- This probably needs to be a var

	gaitOffset:Div(#self.Legs)

	gaitOffset.x = math.Approach(oldOffset.x, gaitOffset.x, delta * (oldOffset.x - gaitOffset.x) * accel)
	gaitOffset.y = math.Approach(oldOffset.y, gaitOffset.y, delta * (oldOffset.y - gaitOffset.y) * accel)
	gaitOffset.z = math.Approach(oldOffset.z, gaitOffset.z, delta * (oldOffset.z - gaitOffset.z) * accel)

	self:SetGaitOffset(gaitOffset)
end

local trace
local result = {}

function ENT:FindGround(offset, maxLength)
	if not trace then
		trace = {
			mins = Vector(-5, -5, 0),
			maxs = Vector(5, 5, 0),
			filter = function(ent) return ent != self and ent:GetOwner() != self end,
			collisiongroup = COLLISION_GROUP_WORLD,
			output = result
		}
	end

	trace.start = self:GetPos()
	trace.endpos = offset

	util.TraceLine(trace)

	trace.start = result.HitPos
	trace.endpos = result.HitPos - self:GetUp() * maxLength

	util.TraceLine(trace)

	return result.HitPos, result.Hit and result.HitNormal or self:GetUp()
end

function ENT:AddLeg(leg)
	leg.Moving = false

	local ground, normal = self:FindGround(self:LocalToWorld(leg.Offset), leg.MaxLength)

	leg.Ground = ground
	leg.Pos = ground
	leg.Target = ground

	leg.OldNormal = normal
	leg.Normal = normal

	table.insert(self.Legs, leg)
end
