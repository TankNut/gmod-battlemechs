local material = Material("battlemechs/trails/physbeam_white")

function EFFECT:Init(data)
	self.Entity = data:GetEntity()
	self.Index = data:GetAttachment()

	self.Start = self.Entity:GetTracerOrigin(self.Index)
	self.End = self.Entity:GetTrace(self.Index).HitPos

	self.Material = material
	self.Scale = 16
	self.Brightness = 3
	self.Color = Color(33, 255, 0)
end

function EFFECT:Think()
	local should = self.Entity["GetIsFiring" .. self.Index](self.Entity)

	if not should then
		return false
	end

	self.Start = self.Entity:GetTracerOrigin(self.Index)
	self.End = self.Entity:GetTrace(self.Index).HitPos

	self:SetPos(self.End)
	self:SetRenderBoundsWS(self.Start, self.End)

	return true
end

function EFFECT:Render()
	local length = (self.Start - self.End):Length()
	local texcoord = math.Rand(0, 1)

	render.SetMaterial(self.Material)

	for i = 0, math.ceil(self.Brightness) - 1 do
		self.Color.a = math.min((self.Brightness - i) * 255, 255)

		render.DrawBeam(self.Start, self.End, self.Scale, texcoord, texcoord + length / 1024, self.Color)
	end
end
