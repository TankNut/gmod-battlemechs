local BONE = {}

function BONE:Update()
	if self.Updated then
		return
	end

	local parent = self.Mech:GetBone(self.Parent)

	if parent then
		parent:Update()

		if self.Offset then
			local offset = self.Offset

			self.Pos, self.Ang = LocalToWorld(offset.Pos or vector_origin, offset.Ang or angle_zero, parent.Pos, parent.Ang)
		else
			self.Pos = parent.Pos
			self.Ang = parent.Ang
		end
	end

	if self.Turret then
		self.Mech:UpdateTurret(self)
	end

	if self.Callback then
		self.Callback(self.Mech, self)
	end

	self:UpdateHitboxes()
end

function BONE:UpdateHitboxes()
	for _, hitbox in ipairs(self.Hitboxes) do
		local pos, ang = LocalToWorld(hitbox:GetHitboxPos(), hitbox:GetHitboxAng(), self.Pos, self.Ang)

		-- NaN check
		if pos.x != pos.x then
			continue
		end

		hitbox:SetPos(pos)
		hitbox:SetAngles(ang)
	end
end

battlemechs.Bone = setmetatable(BONE, {__call = function(self, _, mech, data)
	local instance = setmetatable(data, {__index = self})

	instance.Mech = mech
	instance.DamageGroup = mech.DamageMap[instance.Name]
	instance.Hitboxes = {}

	return instance
end})
