local convar_resolution = GetConVar("battlemechs_ground_resolution")

function ENT:GetStepDown()
	return self.Hull.Step * 2
end

function ENT:GetGroundTrace(mv)
	local resolution = convar_resolution:GetInt()

	local space = self.Hull.Size * 2
	local space2 = space * 0.5

	local size = space / resolution
	local size2 = size * 0.5

	local mins = Vector(-size2, -size2, self.Mins.z)
	local maxs = Vector(size2, size2, self.Maxs.z)

	local offset = Vector()
	local pos = self:GetPos() - Vector(space2 - size2, space2 - size2, 0)

	local ground = 0
	local normal = Vector()
	local highest = -math.huge

	for x = 0, resolution - 1 do
		for y = 0, resolution - 1 do
			offset:Set(pos)
			offset.x = offset.x + x * size
			offset.y = offset.y + y * size

			local tr = util.TraceHull({
				start = offset,
				endpos = offset - Vector(0, 0, 56756),
				filter = self,
				collisiongroup = COLLISION_GROUP_WORLD,
				mins = mins,
				maxs = maxs
			})

			-- debugoverlay.SweptBox(tr.StartPos, tr.HitPos, mins, maxs, angle_zero, 0, Color(0, 0, 255))

			ground = ground + tr.HitPos.z
			normal:Add(tr.HitNormal)

			highest = math.max(highest, tr.HitPos.z)
		end
	end

	local count = resolution * resolution

	normal:Div(count)
	normal:Normalize()


	mv.GroundLevel = math.max(ground / count, highest - self.Hull.Step + 16) + mins.z
	mv.Normal = normal
	mv.Slope = math.NormalizeAngle(normal:Angle().p + 90)

	mv.OnGround = (offset.z - mv.GroundLevel) < self:GetStepDown()

	-- local dpos = self:GetPos()
	-- dpos.z = mv.GroundLevel

	-- debugoverlay.Cross(dpos, 5, 0, color_white, true)
end

function ENT:CheckGround(mv)
	local vel = mv.Velocity

	local height = self.Hull.Offset
	local dist = self:GetPos().z - mv.GroundLevel

	if mv.Slope > self.MaxSlope then
		local gravity = physenv.GetGravity().z * mv.Delta
		local dir = Vector(mv.HitNormal)

		dir.x = dir.x * gravity
		dir.y = dir.y * gravity
		dir.z = 0

		vel:Sub(dir)
	end

	local diff = height - dist

	-- Snap to ground
	vel.z = diff * 10
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
	local vel = phys:GetVelocity()

	return {
		Delta = FrameTime(),
		Velocity = vel,
		Driver = self:GetDriver(),
	}
end

function ENT:PhysicsUpdate(phys)
	if phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
		self:SetOnGround(false)

		return
	end

	local mv = self:CreateMoveData(phys)

	self:GetGroundTrace(mv)

	if mv.OnGround then
		self:CheckGround(mv)

		mv.Velocity:Rotate(self:GetMechAngleDelta())

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
