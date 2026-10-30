AddCSLuaFile()

function ENT:MechToWorld(pos, ang)
	return LocalToWorld(pos, ang or angle_zero, self:GetPos(), self:GetMechAngles())
end

function ENT:WorldToMech(pos, ang)
	return WorldToLocal(pos, ang or angle_zero, self:GetPos(), self:GetMechAngles())
end

function ENT:GetMechCenter()
	return self:GetPos() + Vector(0, 0, (self.Hull.Height - self.Hull.Offset) / 2)
end

function ENT:GetMechRadius()

	local x = math.max(math.abs(self.Mins.x), math.abs(self.Maxs.x))
	local y = math.max(math.abs(self.Mins.x), math.abs(self.Maxs.x))
	local z = math.max(math.abs(self.Mins.x), math.abs(self.Maxs.x))

	return math.sqrt(x^2 + y^2 + z^2)
end

function ENT:GetMoveStat(val)
	local scale = math.Clamp(math.Remap(self:GetMechVelocity():Length2D(), self.WalkSpeed, self.RunSpeed, 0, 1), 0, 1)

	if istable(val) then
		return Lerp(scale, val[1], val[2])
	elseif isfunction(val) then
		return val(self, scale)
	end

	return val
end

function ENT:GetGroundOffset()
	return self.Hull.Offset
end

function ENT:MechEmitSound(snd, arg)
	if snd == nil then return end

	-- Looping sound
	if arg == true then
		self.SoundCache[snd] = self:StartLoopingSound(snd)
	elseif isvector(arg) then
		EmitSound(snd, arg, self:EntIndex())
	else
		self:EmitSound(snd)
	end
end

function ENT:MechStopSound(snd, arg)
	if snd == nil then return end

	if arg == true then
		self:StopLoopingSound(self.SoundCache[snd] or -1)
	else
		self:StopSound(snd)
	end
end
