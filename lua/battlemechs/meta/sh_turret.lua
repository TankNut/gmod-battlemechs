AddCSLuaFile()

local TURRET = {}

function TURRET:Initialize(bone, var, noDebug)
	self.Mech = bone.Mech
	self.Bone = bone

	bone:AddCallback(function()
		self:BoneCallback()
	end)

	self.NetworkVar = var
	self.NoDebug = noDebug

	self.Slave = false

	self.Pitch = {-360, 360}
	self.Yaw = {-360, 360}
	self.Roll = {-360, 360}

	self.Rate = 0

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

function TURRET:SetRate(rate) self.Rate = rate end

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

	if not ply:IsValid() then
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
			local target = (self.Mech:GetAimTrace().HitPos - self.Bone.Pos):Angle()
			target:Normalize()

			return target
		else
			return self:GetFallbackAngle(forwardAngle)
		end
	end
end

function TURRET:BoneCallback()
	local mech = self.Mech
	local bone = self.Bone

	local forwardAngle = bone.Parent and bone.Parent.Ang or mech:GetMechAngles()
	local ang = self:GetNetworkVar()

	if self.NoPitch then ang.p = 0 end
	if self.NoYaw then ang.y = 0 end
	if self.NoRoll then ang.r = 0 end

	_, bone.Ang = LocalToWorld(vector_origin, ang, bone.Pos, forwardAngle)
end

function TURRET:Tick()
	if self.Slave then
		self.Bone:Update()
		return
	end

	local mech = self.Mech
	local bone = self.Bone

	local ang = self:GetNetworkVar()
	local forwardAngle = bone.Parent and bone.Parent.Ang or mech:GetMechAngles()
	local targetAngle = self:GetAngle(forwardAngle)

	if not targetAngle then
		return
	end

	local relTargetAngle = targetAngle - forwardAngle
	local delta = FrameTime()

	local pitch = math.Clamp(math.NormalizeAngle(relTargetAngle.p), self.Pitch[1], self.Pitch[2])
	local yaw = math.Clamp(math.NormalizeAngle(relTargetAngle.y), self.Yaw[1], self.Yaw[2])
	local roll = math.Clamp(math.NormalizeAngle(relTargetAngle.r), self.Roll[1], self.Roll[2])

	if self.Rate == 0 then
		ang.p = pitch
		ang.y = yaw
		ang.r = roll
	else
		local target = Angle(pitch, yaw, roll)
		local diff = target - ang

		diff:Normalize()

		local ratio = math.max(math.abs(diff.p), math.abs(diff.y), math.abs(diff.r))

		if ratio > 0 then
			ang.p = approachAngle(ang.p, pitch, (diff.p / ratio) * self.Rate * delta, range)
			ang.y = approachAngle(ang.y, yaw, (diff.y / ratio) * self.Rate * delta, range)
			ang.r = approachAngle(ang.r, roll, (diff.r / ratio) * self.Rate * delta, range)
		end
	end

	self:SetNetworkVar(ang)

	bone:Update()
end

battlemechs.Turret = setmetatable(TURRET, {__call = function(self, _, ...)
	local instance = setmetatable({}, {__index = self})
	instance:Initialize(...)

	return instance
end})
