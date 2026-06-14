AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_module")

ENT.Base = "battlemechs_module"
ENT.Author = "TankNut"

ENT.TracerConfig = {
	Mat = Material("effects/spark"),
	Velocity = 8000,
	Length = {128, 256},
	Scale = {5, 6}
}

function ENT:Initialize()
	BaseClass.Initialize(self)
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "NextAttack")
end

function ENT:DriverThink(ply)
	if ply:KeyDown(self.Config.Key) and self:GetNextAttack() <= CurTime() then
		self:FireWeapon(ply)
	end
end

function ENT:FireWeapon(ply)
	local mech = self:GetOwner()
	local bone = mech:GetBone(self.Config.Bone)

	ply:LagCompensation(true)

	mech:FireBullets({
		Src = bone.Pos,
		Dir = bone.Ang:Forward(),
		Attacker = ply,
		Inflictor = self,
		Damage = 10,
		Spread = Vector(0.01, 0.01),
		Tracer = 0,
		Callback = function(_, tr, dmg)
			local e = EffectData()
			e:SetStart(tr.StartPos)
			e:SetOrigin(tr.HitPos)
			e:SetEntity(self)

			util.Effect("battlemechs_e_tracer", e)
		end
	}, true)

	ply:LagCompensation(false)

	mech:EmitSound("Weapon_SMG1.NPC_Single")

	self:SetNextAttack(CurTime() + 0.1)
end
