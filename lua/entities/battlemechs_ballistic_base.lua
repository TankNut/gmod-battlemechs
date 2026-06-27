AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_weapon_base")

ENT.Base = "battlemechs_weapon_base"

ENT.Damage = 8
ENT.Spread = Vector(0.01, 0.01)

ENT.Delay = 60 / 1200

ENT.Sounds = {
	Fire = "Weapon_SMG1.NPC_Single"
}

function ENT:DoEffects(index, tr)
	local tracer = EffectData()
	tracer:SetStart(tr.StartPos)
	tracer:SetOrigin(tr.HitPos)
	tracer:SetAttachment(index)
	tracer:SetEntity(self)

	util.Effect("battlemechs_e_tracer", tracer)

	local muzzle = EffectData()
	muzzle:SetOrigin(tr.StartPos)
	muzzle:SetAttachment(index)
	muzzle:SetEntity(self)
	muzzle:SetScale(2)

	util.Effect("battlemechs_e_muzzle", muzzle)
end

function ENT:FireWeapon(ply)
	local config = self.Config

	local mech = self:GetOwner()
	local bone = mech:GetBone(config.Bone)

	mech:FireBullets({
		Src = bone.Pos,
		Dir = bone.Ang:Forward(),
		Attacker = ply,
		Inflictor = self,
		Damage = self.Damage,
		Spread = self.Spread,
		Tracer = 0,
		Callback = function(_, tr, dmg)
			self:DoEffects(self:GetMountIndex(), tr)
		end
	}, true)

	BaseClass.FireWeapon(self, ply)
end

if CLIENT then
	local material = Material("effects/spark")

	function ENT:SetupTracer(tracer)
		tracer.Material = material
		tracer.Velocity = 8000
		tracer.Length = math.Rand(128, 256)
		tracer.Scale = math.Rand(5, 6)
	end
end
