AddCSLuaFile()

if CLIENT then
	function ENT:UpdateThirdPersonState()
		if self:GetDriver() != battlemechs.lp then
			return
		end

		local mode = self:GetSeat():GetThirdPersonMode() and 1 or 0

		if mode != battlemechs.lp:GetInfoNum("battlemechs_thirdperson", 1) then
			RunConsoleCommand("battlemechs_thirdperson", mode)
		end
	end
else
	function ENT:SetThirdPersonMode(ply)
		local mode = tobool(ply:GetInfoNum("battlemechs_thirdperson", 1))

		self:GetSeat():SetThirdPersonMode(mode)
	end
end

function ENT:GetViewOrigin()
	local ply = self:GetDriver()
	local ang = IsValid(ply) and ply:LocalEyeAngles() or self:GetAngles()

	local thirdperson = self:GetSeat():GetThirdPersonMode()

	if thirdperson then
		local config = self.ThirdPersonSettings
		local origin = LocalToWorld(config.Pos, angle_zero, self:GetPos(), ang)

		local tr = util.TraceHull({
			start = origin,
			endpos = origin + (ang:Forward() * -config.Distance),
			mask = MASK_SOLID,
			filter = self,
			mins = Vector(-4, -4, -4),
			maxs = Vector(4, 4, 4),
		})

		return tr.HitPos, ang
	else
		local config = self.FirstPersonSettings

		if config.Bone then
			return self:GetBone(config.Bone):LocalToWorld(config.Pos), ang
		else
			return self:LocalToWorld(config.Pos, ang)
		end
	end
end

function ENT:GetAimTrace()
	local pos, ang = self:GetViewOrigin()

	return util.TraceHull({
		start = pos,
		endpos = pos + ang:Forward() * 56756,
		mask = MASK_SHOT,
		filter = table.Add({self}, self.Hitboxes),
		mins = Vector(-4, -4, -4),
		maxs = Vector(4, 4, 4),
	})
end

function ENT:CalcView(ply, origin, angles, fov, znear, zfar)
	if ply:GetViewEntity() != ply then
		return
	end

	origin, angles = self:GetViewOrigin()

	return {
		origin = origin,
		angles = angles,
		fov = fov,
		znear = znear,
		zfar = zfar,
		drawviewer = self:GetSeat():GetThirdPersonMode()
	}
end
