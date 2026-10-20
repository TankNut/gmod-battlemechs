AddCSLuaFile()

function ENT:Think()
	self:PhysWake()

	if SERVER then
		self:ProcessDamageEvents()

		if self:HasDriver() then
			self:SetLookAngle(self:GetDriver():LocalEyeAngles())
		else
			self:Tick(NULL)
		end
	end

	self:CallModule("PreThink")

	self:UpdateLegs()
	self:UpdateBones()

	self:CallModule("Think")

	if CLIENT then
		self:UpdateThirdPerson()
		self:UpdateHUD()
	end

	self:NextThink(CurTime())

	return true
end

--[[
Turrets need to be split into two funcs, one that updates the network var (Tick) and one that updates the actual bone (could that be handled through a callback?)

Bones continue to update frequently on the client and regularly on the server for smoothness (this means that turrets need to save their own values so that bones can fetch from those)
]]

function ENT:Tick(ply)
	self:CallModule("PreTick", ply)

	for _, bone in ipairs(self.Bones) do
		bone:Tick()
	end

	self:CallModule("Tick", ply)
end

function ENT:PlayerPostThink(ply)
	self:Tick(ply)
end
