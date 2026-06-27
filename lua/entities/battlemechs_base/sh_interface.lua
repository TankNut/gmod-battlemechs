AddCSLuaFile()

function ENT:CreateNetworkVars()
end

function ENT:BuildBones(root)
end

function ENT:UpdateRootBone(bone)
	local offset = self:GetGaitOffset()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	offset:Rotate(self:GetAngles())
	pos:Add(offset)

	bone.Pos = pos
	bone.Ang = ang
end

function ENT:BuildLegs()
end

function ENT:OnStepStart(index, leg) end
function ENT:OnStepFinish(index, leg)
	if SERVER and self.FootstepSound then
		self:MechEmitSound(self.FootstepSound, leg.Pos + leg.Normal)
	end
end

if CLIENT then
	function ENT:BuildModel()
	end

	function ENT:UpdatePart(part)
	end
else
	function ENT:BuildHitboxes()
	end

	function ENT:BuildDamageGroups()
	end
end

function ENT:BuildModules()
end

function ENT:CanMove()
	return self:HasDriver()
end
