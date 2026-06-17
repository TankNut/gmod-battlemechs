function ENT:BuildModel()
	-- Hip
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_hip.mdl", "Root")

	-- Torso
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_torso.mdl", "Torso")

	-- Left arm
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_arm_left.mdl", "LeftArm")
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_gun_left.mdl", "LeftWeapon")

	-- Right arm
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_arm_right.mdl", "RightArm")
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_gun_right.mdl", "RightWeapon")

	-- Left leg
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_upperleg_left.mdl", "LeftHip",  {Pos = battlemechs:MW4Scale(0, -0.65, 0), Ang = Angle(-90)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_lowerleg_left.mdl", "LeftKnee", {Ang = Angle(-90)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_foot_left.mdl",     "LeftFoot", {Pos = battlemechs:MW4Scale(0.1, 0, 1.4)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_toe_left.mdl",      "LeftFoot", {Pos = battlemechs:MW4Scale(0.525, 0, 0.85)})

	-- Right leg
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_upperleg_right.mdl", "RightHip",  {Pos = battlemechs:MW4Scale(0, 0.65, 0), Ang = Angle(-90)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_lowerleg_right.mdl", "RightKnee", {Ang = Angle(-90)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_foot_right.mdl",     "RightFoot", {Pos = battlemechs:MW4Scale(0.1, 0, 1.4)})
	self:AddModelPart("models/battlemechs/mw4/atlas/atlas_toe_right.mdl",      "RightFoot", {Pos = battlemechs:MW4Scale(0.525, 0, 0.85)})
end
