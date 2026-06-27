function ENT:BuildModules()
	self:AddModule("battlemechs_laser_base", {
		Bone = "LeftWeapon",
		Offset = Vector(58, 0, -3),
		Key = IN_ATTACK
	})

	self:AddModule("battlemechs_laser_base", {
		Bone = "RightWeapon",
		Offset = Vector(58, 0, -3),
		Key = IN_ATTACK
	})

	self:AddModule("battlemechs_ballistic_base", {
		Bone = "ChinGun",
		Key = IN_ATTACK2,
		Mounts = {
			{Bone = "ChinGun", Offset = Vector(27, 18.5)},
			{Bone = "ChinGun", Offset = Vector(27, -19.5)}
		}
	})
end
