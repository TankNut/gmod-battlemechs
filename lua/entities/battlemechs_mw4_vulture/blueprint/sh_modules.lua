function ENT:BuildModules()
	self:AddModule("battlemechs_weapon", {
		ChainFire = true,
		Mounts = {
			{
				Bone = "ChinGun",
				Offset = Vector(27, 18.5),
				Key = IN_ATTACK2
			}, {
				Bone = "ChinGun",
				Offset = Vector(27, -19.5),
				Key = IN_ATTACK2
			}
		}
	})

	self:AddModule("battlemechs_weapon_laser", {
		Mounts = {
			{
				Bone = "LeftWeapon",
				Offset = Vector(58, 0, -3),
				Key = IN_ATTACK
			}, {
				Bone = "RightWeapon",
				Offset = Vector(58, 0, -3),
				Key = IN_ATTACK
			}
		}
	})
end
