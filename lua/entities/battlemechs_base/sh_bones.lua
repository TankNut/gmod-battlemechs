AddCSLuaFile()

function ENT:InitBones()
	self.Bones = {}
	self.BoneMap = {}

	local root = self:AddBone("Root")
	root:AddCallback(self.UpdateRootBone)

	self:BuildBones(root) -- Interface

	-- Link parents
	for _, bone in ipairs(self.Bones) do
		bone.Parent = self:GetBone(bone.Parent)
	end
end

function ENT:AddBone(name, parent)
	assert(not self.BoneMap[name], string.format("A bone with the name '%s' already exists!", name))

	return battlemechs.Bone(self, name, parent)
end

function ENT:UpdateRootBone(bone)
	bone.Ang = self:GetMechAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(bone.Ang)

	bone.Pos = self:GetPos()
	bone.Pos:Add(offset)
end

function ENT:GetBone(name)
	return self.BoneMap[name]
end

function ENT:UpdateBounds()
	local pos = self:GetPos()
	local minBounds, maxBounds = self:GetCollisionBounds()

	minBounds:Add(pos)
	maxBounds:Add(pos)

	for _, hitbox in ipairs(self.Hitboxes) do
		local mins, maxs = hitbox:GetAABB()

		minBounds.x = math.min(minBounds.x, mins.x, maxs.x)
		minBounds.y = math.min(minBounds.y, mins.y, maxs.y)
		minBounds.z = math.min(minBounds.z, mins.z, maxs.z)

		maxBounds.x = math.max(maxBounds.x, mins.x, maxs.x)
		maxBounds.y = math.max(maxBounds.y, mins.y, maxs.y)
		maxBounds.z = math.max(maxBounds.z, mins.z, maxs.z)
	end

	minBounds:Sub(pos)
	maxBounds:Sub(pos)

	self:SetSurroundingBounds(minBounds, maxBounds)
end

if CLIENT then
	function ENT:UpdateBones()
		for _, bone in ipairs(self.Bones) do
			bone:Update()
		end
	end
else
	function ENT:UpdateBones()
		for _, bone in ipairs(self.Bones) do
			bone:Update() -- For turrets, make sure the bone is positioned correctly

			if bone.Turret then
				bone.Turret:Tick() -- Update the turret
				bone:Update() -- Update the bone again to apply the new turret angles
			end
		end
	end
end
