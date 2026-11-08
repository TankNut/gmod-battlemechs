AddCSLuaFile()

if CLIENT then
	function ENT:Think()
		self:UpdateThirdPersonState()

		self:UpdateGait()
		self:UpdateBones()
		self:UpdateIK()

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

		self:UpdateGait()
		self:UpdateBones()
		self:UpdateIK()

		self:TickModules()
	end
end
