AddCSLuaFile()

if CLIENT then
	return
end

function ENT:GetStepDown()
	return self.Hull.Step * 2
end

function ENT:GetGroundTrace(mv)
	local pos = self:GetPos()

	local tr = util.TraceHull({
		start = pos,
		endpos = pos - Vector(0, 0, 56756),
		filter = {self, "player", "npc*"},
		collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
		mins = self.Mins,
		maxs = self.Maxs
	})

	mv.GroundLevel = tr.HitPos.z + self.Mins.z
	mv.Normal = tr.HitNormal
	mv.Slope = math.NormalizeAngle(tr.HitNormal:Angle().p + 90)

	mv.OnGround = (pos.z - mv.GroundLevel) < self:GetStepDown()
end

function ENT:CheckGround(mv)
	if not mv.OnGround then
		return
	end

	local vel = mv.Velocity

	local height = self.Hull.Offset
	local dist = self:GetPos().z - mv.GroundLevel

	if mv.Slope > self.MaxSlope then
		local gravity = physenv.GetGravity().z * mv.Delta
		local dir = Vector(mv.Normal)

		dir.x = dir.x * gravity
		dir.y = dir.y * gravity
		dir.z = 0

		vel:Sub(dir)
	end

	local diff = height - dist

	-- Snap to ground
	vel.z = diff * 10
end

function ENT:ApplyRotation(mv)
	local ply = mv.Driver

	if not ply:IsValid() then
		return
	end

	local left = ply:KeyDown(IN_MOVELEFT) and 1 or 0
	local right = ply:KeyDown(IN_MOVERIGHT) and 1 or 0

	local direction = right - left

	if direction != 0 then
		local delta = Angle(0, -(direction * self.TurnRate * mv.Delta), 0)
		local ang = self:GetMechAngles()
		ang:Add(delta)

		mv.Velocity:Rotate(delta)

		self:SetMechAngles(ang)
	end
end

function ENT:ApplyFriction(mv)
	local vel = mv.Velocity

	local friction = 10 * mv.Delta
	local ratio = math.max(math.abs(vel.x), math.abs(vel.y))

	vel.x = math.Approach(vel.x, 0, (math.abs(vel.x) / ratio) * friction)
	vel.y = math.Approach(vel.y, 0, (math.abs(vel.y) / ratio) * friction)
end

function ENT:GetWishSpeed(mv)
	local ply = mv.Driver

	if ply:IsValid() then
		return ply:KeyDown(IN_SPEED) and self.RunSpeed or self.WalkSpeed
	end

	return 0
end

function ENT:GetWishVelocity(mv)
	local ply = mv.Driver

	if not ply:IsValid() then
		return vector_origin
	end

	local forward = ply:KeyDown(IN_FORWARD) and 1 or 0
	local back = ply:KeyDown(IN_BACK) and 1 or 0

	local dir = Vector(forward - back, 0, 0)

	dir:Rotate(self:GetMechAngles())
	dir.z = 0
	dir:Normalize()

	return dir * self:GetWishSpeed(mv)
end

function ENT:Accelerate(mv)
	local vel = mv.Velocity

	local acceleration = 200 * mv.Delta
	local target = self:GetWishVelocity(mv)

	local diff = target - vel
	local ratio = math.max(math.abs(diff.x), math.abs(diff.y))

	vel.x = math.Approach(vel.x, target.x, (diff.x / ratio) * acceleration)
	vel.y = math.Approach(vel.y, target.y, (diff.y / ratio) * acceleration)
end

function ENT:CreateMoveData(phys)
	return {
		Delta = FrameTime(),
		Velocity = phys:GetVelocity(),
		Driver = self:GetDriver(),
	}
end

function ENT:InitMovement()
	self.PhysgunRotation = 0
end

function ENT:HandleMovement(phys)
	if phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
		self:SetOnGround(false)

		local yaw = phys:GetAngles().y
		local ang = self:GetMechAngles()
		ang.y = math.NormalizeAngle(ang.y + (yaw - self.PhysgunRotation))

		self:SetMechAngles(ang)
		self.PhysgunRotation = yaw

		return
	elseif self.PhysgunRotation != 0 then
		self.PhysgunRotation = 0
	end

	local mv = self:CreateMoveData(phys)

	self:GetGroundTrace(mv)
	self:CheckGround(mv)

	if mv.OnGround then
		self:ApplyRotation(mv)

		self:ApplyFriction(mv)
		self:Accelerate(mv)
	end

	-- Snap to angle_zero
	local ang = -self:GetAngles() / mv.Delta

	phys:SetVelocity(mv.Velocity)
	phys:SetAngleVelocity(Vector(ang.r, ang.p, ang.y))

	self:SetMechVelocity(mv.Velocity)
	self:SetOnGround(mv.OnGround)
end
