AddCSLuaFile()

function ENT:InitHitboxes()
	if not self.Hitboxes then
		self.Hitboxes = {}
	end

	if SERVER then
		for _, ent in ipairs(self.Hitboxes) do
			SafeRemoveEntity(ent)
		end

		self:BuildHitboxes()
	end
end

if SERVER then
	function ENT:AddHitbox(name, pos, ang, size)
		local ent = ents.Create("battlemechs_hitbox")
		local mins = Vector(0, -size.y * 0.5, -size.z * 0.5)
		local maxs = Vector(size.x, size.y * 0.5, size.z * 0.5)

		ent:SetPos(self:LocalToWorld(pos))
		ent:SetAngles(self:LocalToWorldAngles(ang))

		ent:SetOwner(self)

		ent:SetHitboxIndex(self:GetBone(name).Index)

		ent:SetHitboxPos(pos)
		ent:SetHitboxAng(ang)

		ent:SetHitboxMins(mins)
		ent:SetHitboxMaxs(maxs)

		ent:Spawn()
		ent:Activate()

		self:DeleteOnRemove(ent)
	end
end
