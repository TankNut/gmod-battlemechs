function ENT:InitParts()
	if self.Parts then
		self:ClearParts()
	end

	self.Parts = {}
	self:BuildModel() -- Interface
end

function ENT:DrawParts(flags, rendergroup)
	local lp = battlemechs.lp

	-- Need to handle this some other way, configurable per-part with a global default
	if self.FirstPersonSettings.HideParts and lp == self:GetDriver() and not self:GetSeat():GetThirdPersonMode() and lp:GetViewEntity() == lp then
		return
	end

	for _, part in ipairs(self.Parts) do
		if part:ShouldDraw() then
			part:Draw(flags, rendergroup)
		end
	end
end

function ENT:ClearParts()
	for _, part in ipairs(self.Parts) do
		part:Destroy()
	end
end

function ENT:UpdateParts()
	local renderMins, renderMaxs = self:GetCollisionBounds()

	renderMins = self:LocalToWorld(renderMins)
	renderMaxs = self:LocalToWorld(renderMaxs)

	for _, part in ipairs(self.Parts) do
		if part:ShouldDraw() then
			local mins, maxs = part:GetRenderBounds()

			if mins and maxs then
				renderMins.x = math.min(renderMins.x, mins.x, maxs.x)
				renderMins.y = math.min(renderMins.y, mins.y, maxs.y)
				renderMins.z = math.min(renderMins.z, mins.z, maxs.z)

				renderMaxs.x = math.max(renderMaxs.x, mins.x, maxs.x)
				renderMaxs.y = math.max(renderMaxs.y, mins.y, maxs.y)
				renderMaxs.z = math.max(renderMaxs.z, mins.z, maxs.z)
			end
		end

		part:Update()
	end

	self:SetRenderBoundsWS(renderMins, renderMaxs)
end
