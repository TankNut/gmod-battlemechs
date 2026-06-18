AddCSLuaFile()

function ENT:BuildBones(root)
	-- Body
	self:AddBone("Torso", {
		Parent = "Root",
		Offset = {
			Pos = battlemechs:MW4Scale(-0.22, 0, 0.67)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Pitch = {-30, 30},
			Yaw = {-130, 130},
			Rate = 225,

			NoPitch = true,
			Torso = true
		}
	})

	self:AddBone("LeftWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = battlemechs:MW4Scale(0.17, 2, 0.51)
		},
		Turret = {
			NetworkVar = "LeftWeaponAngle",
			Pitch = {-90, 90},
			Yaw = {-15, 30},
			Rate = 108,
		}
	})

	self:AddBone("RightWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = battlemechs:MW4Scale(0.17, -2, 0.51)
		},
		Turret = {
			NetworkVar = "RightWeaponAngle",
			Pitch = {-90, 90},
			Yaw = {-30, 15},
			Rate = 108
		}
	})

	-- Left leg
	self:AddBone("LHip")
	self:AddBone("LKnee")
	self:AddBone("LFoot")

	-- Right leg
	self:AddBone("RHip")
	self:AddBone("RKnee")
	self:AddBone("RFoot")
end
