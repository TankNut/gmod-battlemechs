AddCSLuaFile()

function ENT:Think()
	self:PhysWake()

	if CLIENT then -- Only gets called with a valid player
		self:UpdateThirdPersonState()
	else
		self:ProcessDamageEvents()
	end

	self:UpdateLegs()

	if CLIENT then
		self:UpdateBones()
	end

	self:CallModule("Think")

	if CLIENT then
		self:UpdateThirdPersonState()
		self:UpdateHUD()
	end

	self:NextThink(CurTime())

	return true
end
