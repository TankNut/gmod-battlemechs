AddCSLuaFile()

function ENT:CreateNetworkVars()
end

function ENT:BuildBones()
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
		self:PlaySound(leg.Pos + leg.Normal, self.FootstepSound)
	end
end

if CLIENT then
	function ENT:UpdateModelPart(ent, part)
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

function ENT:CanAim(bone, config)
	local ply = self:GetDriver()

	return IsValid(ply) and not ply:KeyDown(IN_WALK)
end
