--[[
SDK References: 

CTempEnts::MuzzleFlash_SMG1_Player
FX_MuzzleEffectAttached
--]]

EFFECT.Mats = {}

for i = 1, 4 do
	EFFECT.Mats[i] = Material("effects/muzzleflash" .. i)
end

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.Index = data:GetAttachment()

	self.Scale = data:GetScale()

	self.Emitter = ParticleEmitter(Vector())
	self.Emitter:SetNoDraw(true)

	local forward = Vector(1, 0, 0)
	local scale = math.Rand(self.Scale - 0.25, self.Scale + 0.25)

	for i = 1, 9 do
		local offset = forward * (i * 2 * scale)
		local p = self.Emitter:Add(table.Random(self.Mats), offset)

		p:SetDieTime(0.025)

		p:SetStartAlpha(255)
		p:SetEndAlpha(128)

		local size = (math.Rand(6, 9) * (12 - i) / 9) * scale

		p:SetStartSize(size)
		p:SetEndSize(size)

		p:SetRoll(math.random(0, 360))
	end
end

function EFFECT:Think()
	if not self.Ent:IsValid() or not self.Emitter:IsValid() then
		return false
	end

	if self.Emitter:GetNumActiveParticles() == 0 then
		self.Emitter:Finish()

		return false
	end

	return true
end

function EFFECT:Render()
	local pos, ang = self.Ent:GetTracerOrigin(self.Index)

	self:SetPos(pos)

	cam.Start3D(WorldToLocal(EyePos(), EyeAngles(), pos, ang))
		self.Emitter:Draw()
	cam.End3D()
end
