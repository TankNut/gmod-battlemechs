AddCSLuaFile()

function ENT:BuildHitboxes()
	self:AddHitbox("Torso", "Torso", Vector(-75, 0, 35), Angle(0, 0, 0), Vector(160, 80, 110))
	self:AddHitbox("Torso", "Torso", Vector(-30, 0, 23), Angle(0, 0, 0), Vector(15, 120, 15))

	self:AddHitbox("LeftWeapon", "Left Weapon", Vector(-52, 2.5, -5), Angle(0, 0, 0), Vector(110, 25, 40))
	self:AddHitbox("RightWeapon", "Right Weapon", Vector(-52, -2.5, -5), Angle(0, 0, 0), Vector(110, -25, 40))

	self:AddHitbox("LeftHip", "Left Leg", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
	self:AddHitbox("LeftKnee", "Left Leg", Vector(-38, -1, -30),  Angle(-17, 0, 0), Vector(80, 18, 15))
	self:AddHitbox("LeftKnee", "Left Leg", Vector(30, -1, -7),  Angle(-17, 0, 0), Vector(52, 40, 40))

	self:AddHitbox("LeftFoot", "Left Leg", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
	self:AddHitbox("LeftFoot", "Left Leg", Vector(15.5, -13, 8.5),  Angle(0, -45, 0), Vector(32, 23, 17))
	self:AddHitbox("LeftFoot", "Left Leg", Vector(15.5, 13, 8.5),  Angle(0, 45, 0), Vector(32, 23, 17))
	self:AddHitbox("LeftFoot", "Left Leg", Vector(-39, 0, 0),  Angle(-90, 0, 0), Vector(17, 20, 31))

	self:AddHitbox("RightHip", "Right Leg", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
	self:AddHitbox("RightKnee", "Right Leg", Vector(-38, 1, -30), Angle(-17, 0, 0), Vector(80, 18, 15))
	self:AddHitbox("RightKnee", "Right Leg", Vector(30, 1, -7), Angle(-17, 0, 0), Vector(52, 40, 40))

	self:AddHitbox("RightFoot", "Right Leg", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
	self:AddHitbox("RightFoot", "Right Leg", Vector(15.5, 13, 8.5), Angle(0, 45, 0), Vector(32, 23, 17))
	self:AddHitbox("RightFoot", "Right Leg", Vector(15.5, -13, 8.5), Angle(0, -45, 0), Vector(32, 23, 17))
	self:AddHitbox("RightFoot", "Right Leg", Vector(-39, 0, 0), Angle(-90, 0, 0), Vector(17, 20, 31))
end

function ENT:BuildDamageGroups()
	self:AddDamageGroup("Torso", 10)

	self:AddDamageGroup("Left Weapon", 3)
	self:AddDamageGroup("Right Weapon", 3)

	self:AddDamageGroup("Left Leg", 4)
	self:AddDamageGroup("Right Leg", 4)
end
