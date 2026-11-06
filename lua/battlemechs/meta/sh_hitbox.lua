AddCSLuaFile()

local HITBOX = battlemechs.Hitbox or {}

function HITBOX:Initialize(bone, group, pos, ang, size)
	self.Bone = bone
	self.DamageGroup = group

	self.Pos = pos
	self.Ang = ang

	self.Mins = Vector(0, -size.y * 0.5, -size.z * 0.5)
	self.Maxs = Vector(size.x, size.y * 0.5, size.z * 0.5)

	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)
end

function HITBOX:Destroy()
	if IsValid(self.PhysCollide) then
		self.PhysCollide:Destroy()
	end
end

function HITBOX:GetBone()
	return self.Mech:GetBone(self.Bone)
end

function HITBOX:GetPosAng()
	local bone = self:GetBone()

	return LocalToWorld(self.Pos, self.Ang, bone.Pos, bone.Ang)
end

function HITBOX:TestCollision(start, delta, min, max)
	local pos, ang = self:GetPosAng()

	return self.PhysCollide:TraceBox(pos, ang, start, start + delta, min, max)
end

battlemechs.Hitbox = setmetatable(HITBOX, {__call = function(self, mech, ...)
	local instance = setmetatable({
		Mech = mech
	}, {__index = self})
	instance:Initialize(...)

	return instance
end})
