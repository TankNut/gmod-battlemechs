local material = Material("effects/spark")

function EFFECT:Init(data)
	self.Pos = data:GetStart()
	self.Ent = data:GetEntity()

	self.Start = self.Ent:GetTracerOrigin(data:GetAttachment())
	self.End = data:GetOrigin()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.Time = 0
	self.Active = true

	self.Material = material
	self.Velocity = 5000
	self.Length = math.Rand(64, 128)
	self.Scale = math.Rand(0.75, 0.9)
	self.Color = Color(255, 255, 255)

	self.Ent:SetupTracer(self)

	effects.TracerSound(self.Start, self.End, 2)
end

function EFFECT:Think()
	return self.Active
end

function EFFECT:Render()
	render.SetMaterial(self.Material)

	self.Time = self.Time + FrameTime()
	self.Active = battlemechs:DrawTracer(self.Start, self.End, self.Velocity, self.Length, self.Scale, self.Time, self.Color)
end
