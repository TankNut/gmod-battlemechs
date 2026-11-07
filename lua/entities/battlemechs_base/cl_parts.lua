function ENT:InitParts()
	if self.Parts then
		self:ClearParts()
	end

	self.Parts = {}
	self:BuildModel() -- Interface
end

function ENT:AddModelPart(mdl, bone, data)
	data = data or {}

	data.Type = battlemechs.MODEL
	data.Model = Model(mdl)
	data.Bone = battlemechs.Assert(self:GetBone(bone), "Model part '%s' references undefined bone '%s'", mdl, bone)

	data.Pos = data.Pos or Vector()
	data.Ang = data.Ang or Angle()

	self:AddPart(data)
	self:CreatePartEntity(data)
end

function ENT:AddPart(data)
	table.insert(self.Parts, data)
end

function ENT:CreatePartEntity(part)
	local ent = ClientsideModel(part.Model, part.RenderGroup)

	if not IsValid(ent) or ent:GetModel() == "models/error.mdl" then
		part.Bad = true

		return
	end

	ent:SetSkin(part.Skin or 0)
	ent:SetNoDraw(true)

	part.Entity = ent

	return ent
end

function ENT:DrawParts(flags, renderGroup)
	local lp = battlemechs.lp

	if self.FirstPersonSettings.HideParts and lp == self:GetDriver() and not self:GetSeat():GetThirdPersonMode() and lp:GetViewEntity() == lp then
		return
	end

	for _, part in ipairs(self.Parts) do
		if not part.RenderGroup or part.RenderGroup == renderGroup then
			self:DrawPart(part, flags)
		end
	end
end

function ENT:DrawModelPart(part, flags)
	local ent = part.Entity

	if not IsValid(ent) then
		ent = self:CreatePartEntity(part)

		if not IsValid(ent) then
			return
		end
	end

	ent:DrawModel(flags)
end

function ENT:DrawPart(part, flags)
	if part.Type == battlemechs.MODEL then
		if part.Bad then
			return
		end

		self:DrawModelPart(part, flags)
	end
end

function ENT:ClearParts()
	for _, part in ipairs(self.Parts) do
		SafeRemoveEntity(part.Entity)
	end
end

function ENT:UpdateParts()
	local renderMins, renderMaxs = self:GetCollisionBounds()

	renderMins = self:LocalToWorld(renderMins)
	renderMaxs = self:LocalToWorld(renderMaxs)

	for _, part in ipairs(self.Parts) do
		local ent = part.Entity

		self:UpdatePart(part)

		if not IsValid(ent) then
			continue
		end

		local bone = part.Bone
		local pos, ang = LocalToWorld(part.Pos, part.Ang, bone.Pos, bone.Ang)

		if pos.x != pos.x then
			continue
		end

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetupBones()

		local mins, maxs = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
		mins:Add(ent:GetPos())
		maxs:Add(ent:GetPos())

		renderMins.x = math.min(renderMins.x, mins.x, maxs.x)
		renderMins.y = math.min(renderMins.y, mins.y, maxs.y)
		renderMins.z = math.min(renderMins.z, mins.z, maxs.z)

		renderMaxs.x = math.max(renderMaxs.x, mins.x, maxs.x)
		renderMaxs.y = math.max(renderMaxs.y, mins.y, maxs.y)
		renderMaxs.z = math.max(renderMaxs.z, mins.z, maxs.z)
	end

	self:SetRenderBoundsWS(renderMins, renderMaxs)
end
