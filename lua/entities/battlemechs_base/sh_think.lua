AddCSLuaFile()

function ENT:Think()
	self:PhysWake()

	if SERVER then
		self:ProcessDamageEvents()
	end

	self:Tick(self:GetDriver())

	self:UpdateLegs()
	self:UpdateBones()

	self:CallModule("Think")

	if CLIENT then
		self:UpdateThirdPersonState()
		self:UpdateHUD()
	end

	self:NextThink(CurTime())

	return true
end

function ENT:Tick(ply)
	if CLIENT then -- Only gets called with a valid player
		self:UpdateThirdPersonState()
	end

	-- This should probably be moved elsewhere
	if ply:IsValid() then
		local left = ply:KeyDown(IN_MOVELEFT) and 1 or 0
		local right = ply:KeyDown(IN_MOVERIGHT) and 1 or 0

		local direction = right - left
		local delta = Angle()

		if direction != 0 then
			delta.y = -(direction * 70 * FrameTime())

			local ang = self:GetMechAngles()
			ang:Add(delta)

			self:SetMechAngles(ang)
		end

		-- Record the change in angle so we can rotate our forward velocity by the same amount in PhysicsUpdate
		self:SetMechAngleDelta(delta)
	end

	self:CallModule("Tick", ply)
end

function ENT:PlayerPostThink(ply)
	--self:Tick(ply)
end
