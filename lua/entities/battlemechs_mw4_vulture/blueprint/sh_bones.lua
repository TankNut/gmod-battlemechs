AddCSLuaFile()

function ENT:BuildBones(root)
	-- Body
	local torso = root:AddBone("Torso")
	torso:SetOffset(Vector(0, 0, 13))
	torso:MakeTurret({
		NetworkVar = "TorsoAngle",
		Rate = 108,

		NoPitch = true,
		Torso = true
	})

	local leftWeapon = torso:AddBone("LeftWeapon")
	leftWeapon:SetOffset(Vector(-23, 69, 22))
	leftWeapon:MakeTurret({
		NetworkVar = "LeftWeaponAngle",
		Pitch = {-90, 90},
		Yaw = {-15, 30},
		Rate = 108,
	})

	local rightWeapon = torso:AddBone("RightWeapon")
	rightWeapon:SetOffset(Vector(-23, -69, 22))
	rightWeapon:MakeTurret({
		NetworkVar = "RightWeaponAngle",
		Pitch = {-90, 90},
		Yaw = {-30, 15},
		Rate = 108
	})

	local chin = torso:AddBone("Chin")
	chin:SetOffset(Vector(70, 0, 2))
	chin:MakeTurret({
		NetworkVar = "ChinAngle",
		Pitch = {-30, 30},
		Yaw = {-90, 90},
		Rate = 200,

		NoPitch = true
	})

	local chinGun = chin:AddBone("ChinGun")
	chinGun:SetOffset(Vector(2, 0, 0))
	chinGun:MakeTurret({
		NetworkVar = "ChinAngle",
		Slave = true,

		NoYaw = true
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
