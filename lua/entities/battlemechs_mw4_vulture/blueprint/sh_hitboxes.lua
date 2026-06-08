AddCSLuaFile()

if SERVER then
	function ENT:BuildHitboxes()
		self:AddHitbox("Torso", Vector(-75, 0, 35), Angle(0, 0, 0), Vector(160, 80, 110))
		self:AddHitbox("Torso", Vector(-30, 0, 23), Angle(0, 0, 0), Vector(15, 120, 15))

		self:AddHitbox("LeftWeapon", Vector(-52, 2.5, -5), Angle(0, 0, 0), Vector(110, 25, 40))
		self:AddHitbox("RightWeapon", Vector(-52, -2.5, -5), Angle(0, 0, 0), Vector(110, -25, 40))

		self:AddHitbox("LeftHip", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
		self:AddHitbox("LeftKnee", Vector(-35, -2, -28),  Angle(-17, 0, 0), Vector(80, 20, 15))
		self:AddHitbox("LeftKnee", Vector(30, -2, -7),  Angle(-17, 0, 0), Vector(45, 40, 35))

		self:AddHitbox("LeftFoot", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
		self:AddHitbox("LeftFoot", Vector(15.5, -13, 8.5),  Angle(0, -45, 0), Vector(32, 23, 17))
		self:AddHitbox("LeftFoot", Vector(15.5, 13, 8.5),  Angle(0, 45, 0), Vector(32, 23, 17))
		self:AddHitbox("LeftFoot", Vector(-39, 0, 0),  Angle(-90, 0, 0), Vector(17, 20, 31))

		self:AddHitbox("RightHip", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
		self:AddHitbox("RightKnee", Vector(-35, 2, -28), Angle(-17, 0, 0), Vector(80, 20, 15))
		self:AddHitbox("RightKnee", Vector(30, 2, -7), Angle(-17, 0, 0), Vector(45, 40, 35))

		self:AddHitbox("RightFoot", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
		self:AddHitbox("RightFoot", Vector(15.5, 13, 8.5), Angle(0, 45, 0), Vector(32, 23, 17))
		self:AddHitbox("RightFoot", Vector(15.5, -13, 8.5), Angle(0, -45, 0), Vector(32, 23, 17))
		self:AddHitbox("RightFoot", Vector(-39, 0, 0), Angle(-90, 0, 0), Vector(17, 20, 31))
	end
end

function ENT:BuildDamageGroups()
	self:AddDamageGroup("Torso", 10, {"Torso", "Chin", "ChinGun"})

	self:AddDamageGroup("Left Weapon", 3, {"LeftWeapon"})
	self:AddDamageGroup("Right Weapon", 3, {"RightWeapon"})

	self:AddDamageGroup("Left Leg", 4, {"LeftHip", "LeftKnee", "LeftFoot"})
	self:AddDamageGroup("Right Leg", 4, {"RightHip", "RightKnee", "RightFoot"})
end
