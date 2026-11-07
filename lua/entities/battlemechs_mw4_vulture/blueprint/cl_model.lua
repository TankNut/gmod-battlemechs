function ENT:BuildModel()
	-- Hip
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_hip.mdl", Bone = "Root", DamageGroup = "Torso"})

	-- Torso
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_torso.mdl", Bone = "Torso", Pos = Vector(-10, 0, 0), DamageGroup = "Torso"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_chin.mdl", Bone = "Chin", Pos = Vector(0, 0, 13.5), DamageGroup = "Torso"})

	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_chin_left.mdl", Bone = "ChinGun", Pos = Vector(0, 14, 0), DamageGroup = "Torso"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_chin_right.mdl", Bone = "ChinGun", Pos = Vector(0, -14, 0), DamageGroup = "Torso"})

	-- Weapons
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_gun_left.mdl", Bone = "LeftWeapon", Pos = Vector(0, -10, 0), DamageGroup = "Left Weapon"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_gun_right.mdl", Bone = "RightWeapon", Pos = Vector(0, 10, 0), DamageGroup = "Right Weapon"})


	-- Left leg
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_upperleg_left.mdl", Bone = "LeftHip", Pos = Vector(0, -11, 0), Ang = Angle(-124, 0, 0), DamageGroup = "Left Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_lowerleg_left.mdl", Bone = "LeftKnee", Pos = Vector(0, 1, 0), Ang = Angle(-62, 0, 0), DamageGroup = "Left Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_foot_left.mdl", Bone = "LeftFoot", Pos = Vector(0, 0, 33), DamageGroup = "Left Leg"})

	-- Right leg
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_upperleg_right.mdl", Bone = "RightHip", Pos = Vector(0, 11, 0), Ang = Angle(-124, 0, 0), DamageGroup = "Right Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_lowerleg_right.mdl", Bone = "RightKnee", Pos = Vector(0, -1, 0), Ang = Angle(-62, 0, 0), DamageGroup = "Right Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_foot_right.mdl", Bone = "RightFoot", Pos = Vector(0, 0, 33), DamageGroup = "Right Leg"})


	-- Left foot
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_left_inner.mdl", Bone = "LeftFoot", Pos = Vector(12.5, -11.25, 10.6), DamageGroup = "Left Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_left_outer.mdl", Bone = "LeftFoot", Pos = Vector(12.5,  11.25, 10.6), DamageGroup = "Left Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_left_back.mdl", Bone = "LeftFoot", Pos = Vector(-20,  0, 10.6), DamageGroup = "Left Leg"})

	-- Right foot
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_right_inner.mdl", Bone = "RightFoot", Pos = Vector(12.5, 11.25, 10.6), DamageGroup = "Right Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_right_outer.mdl", Bone = "RightFoot", Pos = Vector(12.5, -11.25, 10.6), DamageGroup = "Right Leg"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/vulture/vulture_toe_right_back.mdl", Bone = "RightFoot", Pos = Vector(-20,  0, 10.6), DamageGroup = "Right Leg"})
end
