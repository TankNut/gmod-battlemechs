local TURRET = {}

function TURRET:Initialize(bone, var, noDebug)
	self.Mech = bone.Mech
	self.Bone = bone

	self.NetworkVar = var
	self.NoDebug = noDebug

	self.Slave = false

	self.Rate = Angle()

	self.Pitch = {-360, 360}
	self.Yaw = {-360, 360}
	self.Roll = {-360, 360}

	self.NoPitch = false
	self.NoYaw = false
	self.NoRoll = false

	self.AlwaysActive = false
end

function TURRET:SetCallback(callback)
	self.Callback = callback
end

function TURRET:SetSlave(bool)
	self.Slave = bool
end

function TURRET:SetPitch(min, max) self.Pitch = {min, max} end
function TURRET:SetYaw(min, max) self.Yaw = {min, max} end
function TURRET:SetRoll(min, max) self.Roll = {min, max} end

function TURRET:SetRate(rate)
	self.Rate = isangle(rate) and rate or Angle(rate, rate, rate)
end

function TURRET:LockPitch(bool) self.NoPitch = bool end
function TURRET:LockYaw(bool) self.NoYaw = bool end
function TURRET:LockRoll(bool) self.NoRoll = bool end

function TURRET:SetAlwaysActive(bool) self.AlwaysActive = bool end

function TURRET:GetNetworkVar()
	return self.Mech["Get" .. self.NetworkVar](self.Mech)
end

function TURRET:SetNetworkVar(val)
	self.Mech["Set" .. self.NetworkVar](self.Mech, val)
end

local function approachAngle(from, to, delta, range)
	if not istable(range) then
		return math.ApproachAngle(from, to, delta)
	end

	from = math.NormalizeAngle(from)
	to = math.NormalizeAngle(to)

	local diff = math.AngleDifference(to, from)

	if from + diff < range[1] or from + diff > range[2] then
		diff = -diff
	end

	return math.Approach(from, from + diff, delta)
end

function TURRET:CanAim()
	local ply = self.Mech:GetDriver()

	if not IsValid(ply) then
		return false
	end

	return self.AlwaysActive or not ply:KeyDown(IN_WALK)
end

function TURRET:GetFallbackAngle(forwardAngle)
	return nil -- Don't update
end

function TURRET:GetAngle(forwardAngle)
	if self.Callback then
		return self:Callback(forwardAngle)
	else
		if self:CanAim() then
			local target = (self.Mech.BoneTrace.HitPos - self.Bone.Pos):Angle()
			target:Normalize()

			return target
		else
			return self:GetFallbackAngle(forwardAngle)
		end
	end
end

function TURRET:Update()
	local mech = self.Mech
	local bone = self.Bone

	local ang = self:GetNetworkVar()
	local forwardAngle

	if bone.Parent then
		forwardAngle = bone.Parent.Ang
	else
		forwardAngle = mech:GetAngles()
	end

	if not self.Slave then
		local targetAngle = self:GetAngle(ang, forwardAngle)

		if targetAngle then
			local relTargetAngle = targetAngle - forwardAngle
			local rangeTable = {self.Pitch, self.Yaw, self.Roll}
			local delta = self.Mech.BoneDelta

			for i = 1, 3 do
				local range = rangeTable[i]
				local rate = self.Rate[i]

				local target = math.Clamp(math.NormalizeAngle(relTargetAngle[i]), range[1], range[2])

				if rate == 0 then
					ang[i] = target
				else
					ang[i] = approachAngle(ang[i], target, rate * delta, range)
				end
			end

			self:SetNetworkVar(ang)
		end
	end

	if self.NoPitch then ang.p = 0 end
	if self.NoYaw then ang.y = 0 end
	if self.NoRoll then ang.r = 0 end

	_, bone.Ang = LocalToWorld(vector_origin, ang, bone.Pos, forwardAngle)
end

battlemechs.Turret = setmetatable(TURRET, {__call = function(self, _, ...)
	local instance = setmetatable({}, {__index = self})
	instance:Initialize(...)

	return instance
end})
