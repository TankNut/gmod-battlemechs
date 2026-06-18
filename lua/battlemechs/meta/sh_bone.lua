local BONE = {}

function BONE:Initialize(mech, name, data)
	self.Mech = mech
	self.Name = name

	for k, v in pairs(data) do
		self[k] = v
	end

	self.Index = table.insert(mech.Bones, self)

	self.Pos = Vector()
	self.Ang = Angle()

	self.DamageGroup = mech.DamageMap[self.Name]
	self.Hitboxes = {}

	mech.BoneMap[self.Name] = self
end

function BONE:LocalToWorld(pos, ang)
	return LocalToWorld(pos or vector_origin, ang or angle_zero, self.Pos, self.Ang)
end

function BONE:Update()
	if self.Updated then
		return
	end

	if self.Parent then
		self.Parent:Update()

		if self.Offset then
			local offset = self.Offset

			self.Pos, self.Ang = LocalToWorld(offset.Pos or vector_origin, offset.Ang or angle_zero, self.Parent.Pos, self.Parent.Ang)
		else
			self.Pos = self.Parent.Pos
			self.Ang = self.Parent.Ang
		end
	end

	if self.Turret then
		self.Mech:UpdateTurret(self)
	end

	if self.Callback then
		self.Callback(self.Mech, self)
	end

	self:UpdateHitboxes()
	self.Updated = true
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

battlemechs.Bone = setmetatable(BONE, {__call = function(self, _, ...)
	local instance = setmetatable({}, {__index = self})
	instance:Initialize(...)

	return instance
end})
