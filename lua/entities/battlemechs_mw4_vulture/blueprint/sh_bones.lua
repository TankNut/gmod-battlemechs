AddCSLuaFile()

function ENT:BuildBones(root)
	-- Body
	local torso = root:AddBone("Torso")
	torso:SetOffset(Vector(0, 0, 13))

	torso:MakeTurret("TorsoAngle", function(turret)
		turret:SetRate(108)
		turret:LockPitch(true)
	end, true)

	-- Left weapon
	local leftWeapon = torso:AddBone("LeftWeapon")
	leftWeapon:SetOffset(Vector(-23, 69, 22))

	leftWeapon:MakeTurret("LeftWeaponAngle", function(turret)
		turret:SetPitch(-90, 90)
		turret:SetYaw(-15, 30)

		turret:SetRate(108)
	end)

	-- Right weapon
	local rightWeapon = torso:AddBone("RightWeapon")
	rightWeapon:SetOffset(Vector(-23, -69, 22))

	rightWeapon:MakeTurret("RightWeaponAngle", function(turret)
		turret:SetPitch(-90, 90)
		turret:SetYaw(-30, 15)

		turret:SetRate(108)
	end)

	-- Chin
	local chin = torso:AddBone("Chin")
	chin:SetOffset(Vector(70, 0, 2))

	chin:MakeTurret("ChinAngle", function(turret)
		turret:SetPitch(-30, 30)
		turret:SetYaw(-90, 90)

		turret:SetRate(200)

		turret:LockPitch(true)
	end)

	-- Chin gun
	local chinGun = chin:AddBone("ChinGun")
	chinGun:SetOffset(Vector(2, 0, 0))

	chinGun:MakeTurret("ChinAngle", function(turret)
		turret:SetSlave(true)
		turret:LockYaw(true)
	end, true)

	-- Left leg
	self:AddBone("LeftHip")
	self:AddBone("LeftKnee")
	self:AddBone("LeftFoot")

	-- Right leg
	self:AddBone("RightHip")
	self:AddBone("RightKnee")
	self:AddBone("RightFoot")
end
