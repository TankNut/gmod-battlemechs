AddCSLuaFile()

function ENT:BuildHitboxes()
	self:AddHitbox("Torso", "Torso", Vector(-30, 0, -5), Angle(0, 0, 0),   Vector(120, 60, 38))
	self:AddHitbox("Torso", "Torso", Vector(2.5, 0, -5), Angle(-90, 0, 0), Vector(55, 40, 40))
	self:AddHitbox("Torso", "Torso", Vector(-20, 0, 13), Angle(0, 0, 0),   Vector(40, 100, 15))

	self:AddHitbox("LeftWeapon", "Left Weapon", Vector(-28, 11, 5),  Angle(0, 0, -90), Vector(60, 47, 30))
	self:AddHitbox("RightWeapon", "Right Weapon", Vector(-28, -11, 5), Angle(0, 0, 90),  Vector(60, 47, 30))

	self:AddHitbox("LHip", "Left Leg", Vector(-13, -12, 5), Angle(0, 0, 0), Vector(self.UpperLength + 25, 13, 30))
	self:AddHitbox("LKnee", "Left Leg", Vector(-10, 0, -5),  Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
	self:AddHitbox("LFoot", "Left Leg", Vector(2, 2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))

	self:AddHitbox("RHip", "Right Leg",  Vector(-13, 12.5, 5), Angle(0, 0, 0),   Vector(self.UpperLength + 25, 13, 30))
	self:AddHitbox("RKnee", "Right Leg", Vector(-10, 0, -5),   Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
	self:AddHitbox("RFoot", "Right Leg", Vector(2, -2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))
end

function ENT:BuildDamageGroups()
	self:AddDamageGroup("Torso", 10)

	self:AddDamageGroup("Left Weapon", 6)
	self:AddDamageGroup("Right Weapon", 6)

	self:AddDamageGroup("Left Leg", 4)
	self:AddDamageGroup("Right Leg ", 4)
end
