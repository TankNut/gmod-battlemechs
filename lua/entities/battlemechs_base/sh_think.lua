AddCSLuaFile()

if CLIENT then
	function ENT:Think()
		self:UpdateThirdPersonState()

		self:UpdateLegs()
		self:UpdateBones()
		self:UpdateParts()

		self:TickModules()

		self:UpdateHUD()
	end
else
	function ENT:Think()
		self:PhysWake()
		self:NextThink(CurTime())

		return true
	end

	function ENT:PhysicsUpdate(phys)
		self:HandleMovement(phys)

		self:UpdateLegs()
		self:UpdateBones()

		self:TickModules()
	end
end
