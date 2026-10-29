AddCSLuaFile()

if CLIENT then
	function ENT:Think()
		self:UpdateThirdPersonState()

		self:UpdateLegs()
		self:UpdateBones()

		-- Need to figure out what the idea with this is
		-- self:CallModule("Think")

		self:UpdateHUD()
	end
else
	function ENT:Think()
		self:PhysWake()

		self:ProcessDamageEvents() -- Last tick's damage
		self:UpdateLegs()

		-- Need to figure out what the idea with this is
		-- self:CallModule("Think")

		self:NextThink(CurTime())

		return true
	end

	function ENT:PhysicsUpdate(phys)
		self:HandleMovement(phys)

		self:UpdateBones()

		self:CallModule("Tick", self:GetDriver())
	end
end
