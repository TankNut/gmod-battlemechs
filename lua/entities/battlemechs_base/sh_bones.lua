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
	bone.Ang = self:GetMechAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(bone.Ang)

	bone.Pos = self:GetPos()
	bone.Pos:Add(offset)
end

function ENT:GetBone(name)
	return self.BoneMap[name]
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
