AddCSLuaFile()

function ENT:InitMovement()
	if SERVER then
		self.MoveData = {
			LastUpdate = CurTime(),
			Velocity = Vector()
		}
	end
end

function ENT:GetGroundOffset()
	return self.GroundOffset
end

function ENT:GetMoveAcceleration()
	return self.MoveAcceleration
end

function ENT:GetDesiredMoveSpeed(ply)
	return ply:KeyDown(IN_SPEED) and self.RunSpeed or self.WalkSpeed
end

function ENT:GetGroundTrace()
	local pos = self:GetPos()

	return util.TraceHull({
		start = pos,
		endpos = pos - Vector(0, 0, 56756),
		filter = self,
		collisiongroup = COLLISION_GROUP_WORLD,
		mins = Vector(-10, -10, 0),
		maxs = Vector(10, 10, 0)
	})
end

if SERVER then
	function ENT:CheckGround()
		local data = self.MoveData
		local vel = data.Velocity
		local tr = self:GetGroundTrace()

		data.GroundTrace = tr
		data.Slope = math.NormalizeAngle(tr.HitNormal:Angle().p + 90)

		local height = self:GetGroundOffset()
		local diff = height - tr.HitPos:Distance(tr.StartPos)

		data.OnGround = diff >= -(height * 0.5)

		if not data.OnGround then
			return
		end

		if data.Slope > self.MaxSlope then
			local gravity = physenv.GetGravity().z * data.Delta
			local dir = Vector(tr.HitNormal)

			dir.x = dir.x * gravity
			dir.y = dir.y * gravity
			dir.z = 0

			vel:Sub(dir)
		end

		vel.z = diff * 10
	end

	function ENT:ApplyAirFriction()
		local vel = self.MoveData.Velocity
		local delta = self.MoveData.Delta

		vel.x = vel.x * (1 - 0.05 * delta)
		vel.y = vel.y * (1 - 0.05 * delta)
	end

	function ENT:GetDesiredVelocity()
		local ply = self.MoveData.Driver

		if not IsValid(ply) then
			return vector_origin
		end

		local forward = ply:KeyDown(IN_FORWARD) and 1 or 0
		local back = ply:KeyDown(IN_BACK) and 1 or 0

		local dir = Vector(forward - back, 0, 0)

		dir:Rotate(self:GetAngles())
		dir.z = 0
		dir:Normalize()

		return dir * self:GetDesiredMoveSpeed(ply)
	end

	ENT.SideFriction = 2

	function ENT:ApplyMoveInput()
		local data = self.MoveData
		local vel = data.Velocity

		local acceleration = self:GetMoveAcceleration() * data.Delta
		local target = self:GetDesiredVelocity()

		local diff = target - vel
		local ratio = math.max(math.abs(diff.x), math.abs(diff.y))

		vel.x = math.Approach(vel.x, target.x, (diff.x / ratio) * acceleration)
		vel.y = math.Approach(vel.y, target.y, (diff.y / ratio) * acceleration)
	end

	function ENT:ApplyFriction()
		local data = self.MoveData
		local vel = data.Velocity

		local friction = math.max(vel:Length2D(), 10) * data.Delta * 10
		local ratio = math.max(math.abs(vel.x), math.abs(vel.y))

		vel.x = math.Approach(vel.x, 0, (math.abs(vel.x) / ratio) * friction)
		vel.y = math.Approach(vel.y, 0, (math.abs(vel.y) / ratio) * friction)
	end

	function ENT:GetDesiredAngle()
		local data = self.MoveData

		local left = data.Driver:KeyDown(IN_MOVELEFT) and 1 or 0
		local right = data.Driver:KeyDown(IN_MOVERIGHT) and 1 or 0

		local direction = right - left

		return data.Yaw - (direction * self:GetMoveStat(self.TurnRate) * data.Delta)
	end

	function ENT:PhysicsUpdate(phys)
		local data = self.MoveData

		data.Phys = phys
		data.Driver = self:GetDriver()
		data.HasDriver = IsValid(data.Driver)

		data.Delta = CurTime() - data.LastUpdate
		data.LastUpdate = CurTime()

		if phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
			data.Velocity = vector_origin

			self:SetMechVelocity(vector_origin)
			self:SetOnGround(false)

			return
		end

		phys:EnableGravity(true)

		data.Velocity = phys:GetVelocity()

		local dir = self:GetForward()
		dir.z = 0
		dir:Normalize()

		data.Yaw = math.NormalizeAngle(dir:Angle().y)

		self:CheckGround()

		local canMove = self:CanMove()

		if data.OnGround then
			if canMove then
				self:ApplyMoveInput()
			else
				self:ApplyFriction()
			end
		else
			self:ApplyAirFriction()
		end

		if canMove then
			data.Yaw = self:GetDesiredAngle()
		end

		local ang = self:GetAngles()
		local turnAngle = -ang + Angle(0, data.Yaw, 0)

		if data.OnGround then
			data.Velocity:Rotate(turnAngle)
		end

		self:SetMechVelocity(data.Velocity)
		self:SetOnGround(data.OnGround)

		phys:SetVelocity(data.Velocity)
		phys:SetAngleVelocity(Vector(turnAngle.r * 10, turnAngle.p * 10, turnAngle.y / data.Delta))
	end
end
