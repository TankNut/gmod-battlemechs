EFFECT.Mat = Material("effects/spark")

function EFFECT:Init(data)
	self.Pos = data:GetStart()
	self.Ent = data:GetEntity()

	self.Start = self.Ent:GetTracerOrigin(data:GetAttachment())
	self.End = data:GetOrigin()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.Time = 0

	local config = self.Ent.TracerConfig

	self.Velocity = config.Velocity
	self.Length = math.Rand(config.Length[1], config.Length[2])
	self.Scale = math.Rand(config.Scale[1], config.Scale[2])

	self.Active = true

	effects.TracerSound(self.Start, self.End, 2)
end

function EFFECT:Think()
	return self.Active
end

function EFFECT:Render()
	render.SetMaterial(self.Mat)

	self.Time = self.Time + FrameTime()
	self.Active = battlemechs:DrawTracer(self.Start, self.End, self.Velocity, self.Length, self.Scale, self.Time)
end
