
function ENT:BuildModel()
	-- Hip
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_hip.mdl", "Root")

	-- Torso
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_torso.mdl", "Torso", {Pos = Vector(-10, 0, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin.mdl",  "Chin", {Pos = Vector(0, 0, 13.5)})

	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin_left.mdl",  "ChinGun", {Pos = Vector(0, 14, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_chin_right.mdl", "ChinGun", {Pos = Vector(0, -14, 0)})

	-- Weapons
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_gun_left.mdl",  "LeftWeapon", {Pos = Vector(0, -10, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_gun_right.mdl", "RightWeapon", {Pos = Vector(0, 10, 0)})

	-- Left leg
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_upperleg_left.mdl", "LeftHip",  {Pos = Vector(0, -11, 0), Ang = Angle(-124, 0, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_lowerleg_left.mdl", "LeftKnee", {Pos = Vector(0, 1, 0), Ang = Angle(-62, 0, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_foot_left.mdl",     "LeftFoot", {Pos = Vector(0, 0, 33)})

	-- Left foot
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_inner.mdl", "LeftFoot", {Pos = Vector(12.5, -11.25, 10.6)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_outer.mdl", "LeftFoot", {Pos = Vector(12.5,  11.25, 10.6)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_left_back.mdl",  "LeftFoot", {Pos = Vector(-20,  0, 10.6)})

	-- Right leg
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_upperleg_right.mdl", "RightHip",  {Pos = Vector(0, 11, 0), Ang = Angle(-124, 0, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_lowerleg_right.mdl", "RightKnee", {Pos = Vector(0, -1, 0), Ang = Angle(-60, 0, 0)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_foot_right.mdl",     "RightFoot", {Pos = Vector(0, 0, 33)})

	-- Right foot
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_inner.mdl", "RightFoot", {Pos = Vector(12.5,  11.25, 10.6)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_outer.mdl", "RightFoot", {Pos = Vector(12.5, -11.25, 10.6)})
	self:AddModelPart("models/battlemechs/mw4/vulture/vulture_toe_right_back.mdl",  "RightFoot", {Pos = Vector(-20,  0, 10.6)})
end
