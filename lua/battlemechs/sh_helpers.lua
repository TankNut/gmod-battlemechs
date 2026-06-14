AddCSLuaFile()

local VECTOR = FindMetaTable("Vector")
local COLOR = FindMetaTable("Color")

function VECTOR:GetReflection(normal)
	local factor = -2 * normal:Dot(self)

	return Vector(factor * normal.x + self.x,
		factor * normal.y + self.y,
		factor * normal.z + self.z)
end

function COLOR:Set(color)
	self.r = color.r
	self.g = color.g
	self.b = color.b
	self.a = color.a
end
