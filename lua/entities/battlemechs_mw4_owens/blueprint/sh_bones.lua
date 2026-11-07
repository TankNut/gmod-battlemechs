AddCSLuaFile()

function ENT:BuildBones(root)
	-- Body
	local torso = root:AddBone("Torso")
	torso:SetOffset(battlemechs.MW4Scale(-0.22, 0, 0.67))
	torso:MakeTurret("TorsoAngle", function(turret)
		turret:SetYaw(-130, 130)

		turret:SetRate(225)
		turret:LockPitch(true)
	end)

	local leftWeapon = torso:AddBone("LeftWeapon")
	leftWeapon:SetOffset(battlemechs.MW4Scale(0.17, 2, 0.51))
	leftWeapon:MakeTurret("LeftWeaponAngle", function(turret)
		turret:SetPitch(-70, 70)
		turret:SetYaw(-15, 30)

		turret:SetRate(108)
	end)

	local rightWeapon = torso:AddBone("RightWeapon")
	rightWeapon:SetOffset(battlemechs.MW4Scale(0.17, -2, 0.51))
	rightWeapon:MakeTurret("RightWeaponAngle", function(turret)
		turret:SetPitch(-70, 70)
		turret:SetYaw(-30, 15)

		turret:SetRate(108)
	end)

	-- Left leg
	self:AddBone("LHip")
	self:AddBone("LKnee")
	self:AddBone("LFoot")

	-- Right leg
	self:AddBone("RHip")
	self:AddBone("RKnee")
	self:AddBone("RFoot")
end
