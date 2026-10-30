AddCSLuaFile()

function ENT:InitHitboxes()
	self:ClearHitboxes()

	self.Hitboxes = {}

	self:BuildHitboxes()
end

function ENT:ClearHitboxes()
	if not self.Hitboxes then
		return
	end

	for _, hitbox in ipairs(self.Hitboxes) do
		if IsValid(hitbox.PhysCollide) then
			hitbox.PhysCollide:Destroy()
		end
	end
end

function ENT:AddHitbox(name, pos, ang, size)
	local mins = Vector(0, -size.y * 0.5, -size.z * 0.5)
	local maxs = Vector(size.x, size.y * 0.5, size.z * 0.5)

	table.insert(self.Hitboxes, {
		Pos = pos,
		Ang = ang,

		Bone = self:GetBone(name),
		PhysCollide = CreatePhysCollideBox(mins, maxs),

		Mins = mins,
		Maxs = maxs
	})
end

function ENT:TestHitboxes(start, delta, isbox, extends, mask)
	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local closest = math.huge
	local hit

	for _, hitbox in ipairs(self.Hitboxes) do
		local pos, ang = LocalToWorld(hitbox.Pos, hitbox.Ang, hitbox.Bone.Pos, hitbox.Bone.Ang)
		local hitpos, normal, fraction = hitbox.PhysCollide:TraceBox(pos, ang, start, start + delta, min, max)

		if hitpos and fraction < closest then
			closest = fraction
			hit = {
				HitPos = hitpos,
				Normal = normal,
				Fraction = fraction
			}
		end
	end

	return hit
end
