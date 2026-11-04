AddCSLuaFile()

function ENT:InitHitboxes()
	if self.Hitboxes then
		self:ClearHitboxes()
	end

	self.Hitboxes = {}
	self:BuildHitboxes()
end

function ENT:ClearHitboxes()
	for _, hitbox in ipairs(self.Hitboxes) do
		hitbox:Destroy()
	end
end

function ENT:GetHitboxPosition(hitbox)
	return LocalToWorld(hitbox.Pos, hitbox.Ang, hitbox.Bone.Pos, hitbox.Bone.Ang)
end

function ENT:AddHitbox(name, group, pos, ang, size)
	table.insert(self.Hitboxes, battlemechs:Hitbox(self, name, group, pos, ang, size))
end

function ENT:TestHitboxes(start, delta, min, max)
	local closest = math.huge
	local hit

	self.LastDamageGroup = nil

	for _, hitbox in ipairs(self.Hitboxes) do
		local hitpos, normal, fraction = hitbox:TestCollision(start, delta, min, max)

		if hitpos and fraction < closest then
			closest = fraction
			hit = {
				HitPos = hitpos,
				Normal = normal,
				Fraction = fraction
			}

			self.LastDamageGroup = hitbox.DamageGroup
		end
	end

	return hit
end
