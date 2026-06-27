local material = Material("battlemechs/trails/physbeam_white")

function EFFECT:Init(data)
	self.Time = 0

	self.Entity = data:GetEntity()
	self.Index = data:GetAttachment()

	self.Trace = self.Entity:GetTrace()
	self.Start = self.Entity:GetTracerOrigin(self.Index)

	self.Material = material
	self.Scale = 16
	self.Brightness = 3
	self.Color = Color(33, 255, 0)
	self.PulseRatio = 1

	self.Range = 56756
	self.Delay = 0.1

	self.Entity:SetupLaser(self)
end

function EFFECT:Think()
	if not self.Entity:IsValid() or self.Entity:GetFireDuration() == 0 then
		return false
	end

	self.Trace = self.Entity:GetTrace()
	self.Start = self.Entity:GetTracerOrigin(self.Index)

	self:SetPos(self.Trace.HitPos)
	self:SetRenderBoundsWS(self.Start, self.Trace.HitPos)

	return true
end

function EFFECT:Render()
	self.Time = self.Time + FrameTime()

	if (self.Time % self.Delay) / self.Delay > self.PulseRatio then
		return
	end

	local length = (self.Start - self.Trace.HitPos):Length()
	local texcoord = math.Rand(0, 1)

	render.SetMaterial(self.Material)

	for i = 0, math.ceil(self.Brightness) - 1 do
		render.StartBeam(2)
			local brightness = (self.Brightness - i) * 255

			self.Color.a = math.min(brightness, 255)
			render.AddBeam(self.Start, self.Scale, texcoord, self.Color)

			-- Decrease brightness as we approach our max range
			brightness = (1 - self.Trace.Fraction) * brightness

			self.Color.a = math.min(brightness, 255)
			render.AddBeam(self.Trace.HitPos, self.Scale, texcoord + length / 1024, self.Color)
		render.EndBeam()
	end
end
