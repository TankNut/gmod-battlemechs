function ENT:BuildModel()
	-- Hip
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_hip.mdl", Bone = "Root"})

	-- Torso
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_torso.mdl", Bone = "Torso"})

	-- Weapons
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_gun_left.mdl", Bone = "LeftWeapon"})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_gun_right.mdl", Bone = "RightWeapon"})

	-- Left leg
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_upperleg_left.mdl", Bone = "LHip", Pos = battlemechs.MW4Scale(0, -0.95, 0), Ang = Angle(-157, 0, 0)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_lowerleg_left.mdl", Bone = "LKnee", Ang = Angle(-60, 0, 0)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_foot_left.mdl", Bone = "LFoot", Pos = battlemechs.MW4Scale(0.1, 0.1, 0.8)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_toe_left_front.mdl", Bone = "LFoot", Pos = battlemechs.MW4Scale(0.45, 0.1, 0.25)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_toe_left_back.mdl", Bone = "LFoot", Pos = battlemechs.MW4Scale(-0.54, 0.1, 0.25)})

	-- Right leg
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_upperleg_right.mdl", Bone = "RHip", Pos = battlemechs.MW4Scale(0, 0.95, 0), Ang = Angle(-157, 0, 0)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_lowerleg_right.mdl", Bone = "RKnee", Pos = battlemechs.MW4Scale(0, 0, 0), Ang = Angle(-60, 0, 0)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_foot_right.mdl", Bone = "RFoot", Pos = battlemechs.MW4Scale(0.1, -0.1, 0.8)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_toe_right_front.mdl", Bone = "RFoot", Pos = battlemechs.MW4Scale(0.45, -0.1, 0.25)})
	battlemechs.ModelPart(self, {Model = "models/battlemechs/mw4/owens/owens_toe_right_back.mdl", Bone = "RFoot", Pos = battlemechs.MW4Scale(-0.54, -0.1, 0.25)})
end
