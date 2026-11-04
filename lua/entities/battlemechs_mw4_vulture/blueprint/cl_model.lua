function ENT:BuildModel()
	-- Hip
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_hip.mdl", "Root", {DamageGroup = "Torso"})

	-- Torso
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_torso.mdl", "Torso", {Pos = Vector(-10, 0, 0), DamageGroup = "Torso"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin.mdl", "Chin", {Pos = Vector(0, 0, 13.5), DamageGroup = "Torso"})

	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin_left.mdl",  "ChinGun", {Pos = Vector(0, 14, 0), DamageGroup = "Torso"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin_right.mdl", "ChinGun", {Pos = Vector(0, -14, 0), DamageGroup = "Torso"})


	-- Weapons
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_gun_left.mdl",  "LeftWeapon", {Pos = Vector(0, -10, 0), DamageGroup = "Left Weapon"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_gun_right.mdl", "RightWeapon", {Pos = Vector(0, 10, 0), DamageGroup = "Right Weapon"})


	-- Left leg
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_upperleg_left.mdl", "LeftHip",  {Pos = Vector(0, -11, 0), Ang = Angle(-124, 0, 0), DamageGroup = "Left Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_lowerleg_left.mdl", "LeftKnee", {Pos = Vector(0, 1, 0), Ang = Angle(-62, 0, 0), DamageGroup = "Left Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_foot_left.mdl",     "LeftFoot", {Pos = Vector(0, 0, 33), DamageGroup = "Left Leg"})

	-- Right leg
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_upperleg_right.mdl", "RightHip",  {Pos = Vector(0, 11, 0), Ang = Angle(-124, 0, 0), DamageGroup = "Right Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_lowerleg_right.mdl", "RightKnee", {Pos = Vector(0, -1, 0), Ang = Angle(-60, 0, 0), DamageGroup = "Right Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_foot_right.mdl",     "RightFoot", {Pos = Vector(0, 0, 33), DamageGroup = "Right Leg"})


	-- Left foot
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_inner.mdl", "LeftFoot", {Pos = Vector(12.5, -11.25, 10.6), DamageGroup = "Left Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_outer.mdl", "LeftFoot", {Pos = Vector(12.5,  11.25, 10.6), DamageGroup = "Left Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_back.mdl",  "LeftFoot", {Pos = Vector(-20,  0, 10.6), DamageGroup = "Left Leg"})

	-- Right foot
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_inner.mdl", "RightFoot", {Pos = Vector(12.5,  11.25, 10.6), DamageGroup = "Right Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_outer.mdl", "RightFoot", {Pos = Vector(12.5, -11.25, 10.6), DamageGroup = "Right Leg"})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_back.mdl",  "RightFoot", {Pos = Vector(-20,  0, 10.6), DamageGroup = "Right Leg"})
end
