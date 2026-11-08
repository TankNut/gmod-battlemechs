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
	local minBounds, maxBounds = self:GetCollisionBounds()
	local pos = self:GetPos()

	minBounds:Add(pos)
	maxBounds:Add(pos)

	for _, part in ipairs(self.Parts) do
		if part:ShouldDraw() then
			local mins, maxs = part:GetRenderBounds()

			if mins and maxs then
				minBounds.x = math.min(minBounds.x, mins.x, maxs.x)
				minBounds.y = math.min(minBounds.y, mins.y, maxs.y)
				minBounds.z = math.min(minBounds.z, mins.z, maxs.z)

				maxBounds.x = math.max(maxBounds.x, mins.x, maxs.x)
				maxBounds.y = math.max(maxBounds.y, mins.y, maxs.y)
				maxBounds.z = math.max(maxBounds.z, mins.z, maxs.z)
			end
		end

		part:Update()
	end

	self:SetRenderBoundsWS(minBounds, maxBounds)
end
