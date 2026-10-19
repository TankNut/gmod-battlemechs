AddCSLuaFile()

function ENT:InitPhysics()
	local mins = self.Hull.Mins
	local maxs = self.Hull.Maxs

	self:EnableCustomCollisions(true)
	self:SetCollisionBounds(mins, maxs)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:MakePhysicsObjectAShadow(true, true)
		self:SetMoveType(MOVETYPE_CUSTOM)

		local phys = self:GetPhysicsObject()

		phys:EnableGravity(false)
		phys:SetMaterial("player")
		phys:SetMass(1000)
	end
end

function ENT:TestCollision(start, delta, isbox, extends, mask)
	if bit.band(mask, CONTENTS_GRATE) == 0 or not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), angle_zero, start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end
