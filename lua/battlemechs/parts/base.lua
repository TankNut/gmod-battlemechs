module("battlemechs", package.seeall)

local PART = CreateMetaTable("BasePart")

function PART:Initialize(data)
	local tab = self:GetTable()
	tab.Hidden = false

	tab.Pos = Vector()
	tab.Ang = Angle()

	for k, v in pairs(data) do
		self[k] = v
	end

	table.insert(self.Mech.Parts, self)
end

function PART:GetBone()
	return self.Mech:GetBone(self.Bone)
end

function PART:GetTransform()
	local bone = self:GetBone()

	if bone then
		return bone:LocalToWorld(self.Pos, self.Ang)
	else
		return self.Mech:MechToWorld(self.Pos, self.Ang)
	end
end

function PART:Destroy()
end

function PART:Update()
end

function PART:GetRenderBounds()
end

function PART:ShouldDraw()
	if self.Hidden then
		return false
	end

	return true
end

function PART:Draw(flags, rendergroup)
end
