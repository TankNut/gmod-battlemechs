AddCSLuaFile()

--[[
	Most of the functions in here are interface functions, meant to be filled out or overwritten on inherited entities.
]]

function ENT:CreateNetworkVars()
end

function ENT:BuildBones(root)
end

function ENT:BuildLegs()
end

function ENT:BuildHitboxes()
end

function ENT:BuildDamageGroups()
end

function ENT:BuildModules()
end

if CLIENT then
	function ENT:BuildModel()
	end
end

function ENT:OnStepStart(index, leg) end
function ENT:OnStepFinish(index, leg)
	if SERVER and self.FootstepSound then
		EmitSound(self.FootstepSound, leg.Pos + leg.Normal, self:EntIndex())
	end
end
