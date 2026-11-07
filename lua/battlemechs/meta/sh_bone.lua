module("battlemechs", package.seeall)

local BONE = CreateMetaTable("Bone")

function BONE:Initialize(name, parent)
	self.Name = name
	self.Parent = parent

	self.Index = table.insert(self.Mech.Bones, self)

	self.Pos = Vector()
	self.Ang = Angle()

	self.Callbacks = {}

	self.Mech.BoneMap[self.Name] = self
end

function BONE:AddBone(name)
	return self.Mech:AddBone(name, self.Name)
end

function BONE:AddCallback(callback)
	table.insert(self.Callbacks, callback)
end

function BONE:MakeTurret(var, callback, noDebug)
	self.Turret = battlemechs.Turret(self.Mech, self, var, noDebug)

	callback(self.Turret)
end

function BONE:SetOffset(pos, ang)
	self.Offset = {
		Pos = pos,
		Ang = ang
	}
end

function BONE:LocalToWorld(pos, ang)
	return LocalToWorld(pos or vector_origin, ang or angle_zero, self.Pos, self.Ang)
end

function BONE:Update()
	if self.Parent then
		if self.Offset then
			local offset = self.Offset

			self.Pos, self.Ang = self.Parent:LocalToWorld(offset.Pos, offset.Ang)
		else
			self.Pos = self.Parent.Pos
			self.Ang = self.Parent.Ang
		end
	end

	for _, callback in ipairs(self.Callbacks) do
		callback(self.Mech, self)
	end
end
