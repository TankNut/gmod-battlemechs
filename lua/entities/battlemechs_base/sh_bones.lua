AddCSLuaFile()

function ENT:InitBones()
	self.Bones = {}
	self.BoneMap = {}

	self.LastBoneThink = CurTime()

	local root = self:AddBone("Root")
	root:AddCallback(self.UpdateRootBone)

	self:BuildBones(root)

	for _, bone in ipairs(self.Bones) do
		bone.Parent = self:GetBone(bone.Parent)
	end
end

function ENT:AddBone(name, parent)
	assert(not self.BoneMap[name], string.format("A bone with the name '%s' already exists!", name))

	return battlemechs:Bone(self, name, parent)
end

function ENT:UpdateRootBone(bone)
	bone.Ang = self:GetAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(bone.Ang)

	bone.Pos = self:GetPos()
	bone.Pos:Add(offset)
end

function ENT:GetBone(name)
	if not name then
		return
	end

	return self.BoneMap[name]
end

function ENT:UpdateBones()
	self.BoneDelta = CurTime() - self.LastBoneThink
	self.BoneTrace = self:GetAimTrace()

	for _, bone in ipairs(self.Bones) do
		bone.Updated = nil
	end

	for _, bone in ipairs(self.Bones) do
		bone:Update()
	end

	self.LastBoneThink = CurTime()
end
