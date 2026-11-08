module("battlemechs", package.seeall)

local HITBOX = CreateMetaTable("Hitbox")

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

function HITBOX:GetTransform()
	local bone = self:GetBone()

	return LocalToWorld(self.Pos, self.Ang, bone.Pos, bone.Ang)
end

local matrix = Matrix()

-- Returns the hitbox's AABB in world space
function HITBOX:GetAABB()
	local pos, ang = self:GetTransform()

	matrix:Identity()
	matrix:SetAngles(ang)

	local mins, maxs = Vector(pos), Vector(pos)

	for i = 1, 3 do
		for j = 1, 3 do
			local a = matrix:GetField(i, j) * self.Mins[j]
			local b = matrix:GetField(i, j) * self.Maxs[j]

			if a < b then
				mins[i] = mins[i] + a
				maxs[i] = maxs[i] + b
			else
				mins[i] = mins[i] + b
				maxs[i] = maxs[i] + a
			end
		end
	end

	return mins, maxs
end

function HITBOX:TestCollision(start, delta, min, max)
	local pos, ang = self:GetTransform()

	return self.PhysCollide:TraceBox(pos, ang, start, start + delta, min, max)
end

function HITBOX:__tostring()
	return string.format("%s [%s][%s]", self.MetaName, self.Mech:EntIndex(), self.Bone)
end
