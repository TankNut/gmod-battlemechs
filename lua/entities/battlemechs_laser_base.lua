AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_weapon_base")

ENT.Base = "battlemechs_weapon_base"

ENT.Damage = 8
ENT.Range = 56756 -- Max range possible in source

ENT.Delay = 0.1

ENT.Burst = 20
ENT.BurstDelay = 1

ENT.Sounds = {
	Looping = "d3_citadel.weapon_zapper_beam_loop1"
}

function ENT:GetTrace()
	local config = self.Config

	local mech = self:GetOwner()
	local bone = mech:GetBone(config.Bone)

	return util.TraceLine({
		start = bone.Pos,
		endpos = bone.Pos + bone.Ang:Forward() * self.Range,
		mask = MASK_SHOT,
		filter = function(ent) return ent:GetOwner() != mech end
	})
end

function ENT:StartFiring()
	local config = self.Config
	local origin = self:GetTrace().HitPos

	local function createLaser(index)
		local tracer = EffectData()
		tracer:SetOrigin(origin)
		tracer:SetAttachment(index)
		tracer:SetEntity(self)

		util.Effect("battlemechs_e_tracer_laser", tracer)
	end

	if config.Mounts then
		for i = 1, #config.Mounts do
			createLaser(i)
		end
	else
		createLaser(1)
	end

	BaseClass.StartFiring(self)
end

function ENT:FireWeapon(ply)
	local tr = self:GetTrace()

	if tr.Entity:IsValid() then
		local damage = math.ceil((1 - tr.Fraction) * self.Damage)

		local dmg = DamageInfo()
		dmg:SetAttacker(ply)
		dmg:SetInflictor(self)
		dmg:SetDamage(damage)
		dmg:SetDamageType(DMG_ENERGYBEAM)
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetDamageForce(tr.Normal * 600)

		tr.Entity:DispatchTraceAttack(dmg, tr)
	end

	BaseClass.FireWeapon(self, ply)
end

if CLIENT then
	local material = Material("battlemechs/trails/physbeam_white")

	function ENT:SetupLaser(laser)
		laser.Material = material
		laser.Scale = 16
		laser.Brightness = 3
		laser.Color = Color(33, 255, 0)
		laser.PulseRatio = 1

		-- Probably don't touch these
		laser.Range = self.Range
		laser.Delay = self.Delay
	end
end
