AddCSLuaFile()

function ENT:BuildBones(root)
	-- Body
	self:AddBone("Torso", {
		Parent = "Root",
		Offset = {
			Pos = battlemechs:MW4Scale(0, 0, 1.3)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Yaw = {-110, 110},
			Rate = 108,

			NoPitch = true,
			Torso = true
		}
	})

	-- Left arm

	self:AddBone("LeftArm", {
		Parent = "Torso",
		Offset = {
			Pos = battlemechs:MW4Scale(-0.5, 2, 2.65)
		},
	})

	self:AddBone("LeftWeapon", {
		Parent = "LeftArm",
		Offset = {
			Pos = battlemechs:MW4Scale(-0.55, 1.3, -2.55)
		},
	})

	-- Right arm

	self:AddBone("RightArm", {
		Parent = "Torso",
		Offset = {
			Pos = battlemechs:MW4Scale(-0.5, -2, 2.65)
		},
	})

	self:AddBone("RightWeapon", {
		Parent = "RightArm",
		Offset = {
			Pos = battlemechs:MW4Scale(-0.55, -1.3, -2.55)
		},
	})

	-- Left leg
	self:AddBone("LeftHip")
	self:AddBone("LeftKnee")
	self:AddBone("LeftFoot")

	-- Right leg
	self:AddBone("RightHip")
	self:AddBone("RightKnee")
	self:AddBone("RightFoot")
end
