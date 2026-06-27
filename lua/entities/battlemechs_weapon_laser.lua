AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_module_base")

ENT.Base = "battlemechs_module_base"

ENT.Delay = 0.1

function ENT:Initialize()
	BaseClass.Initialize(self)

	for i = 1, #self.Config.Mounts do
		self:NetworkVar("Bool", "IsFiring" .. i)
	end

	self.Sound = -1
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "NextAttack")
end

function ENT:GetIsFiring(index)
	return self["GetIsFiring" .. index](self)
end

function ENT:SetIsFiring(index, bool)
	self["SetIsFiring" .. index](self, bool)
end

function ENT:StartFiring(index)
	local tracer = EffectData()
	tracer:SetOrigin(self:GetTrace(index).HitPos)
	tracer:SetAttachment(index)
	tracer:SetEntity(self)

	util.Effect("battlemechs_e_tracer_laser", tracer)

	if self.Sound == -1 then
		self.Sound = self:StartLoopingSound("d3_citadel.weapon_zapper_beam_loop1")
	end
end

function ENT:StopFiring(index)
	for i = 1, #self.Config.Mounts do
		if self:GetIsFiring(i) then
			return
		end
	end

	self:StopLoopingSound(self.Sound)
	self.Sound = -1
end

function ENT:GetTrace(index)
	local mount = self.Config.Mounts[index]

	local mech = self:GetOwner()
	local bone = mech:GetBone(mount.Bone)

	return util.TraceLine({
		start = bone.Pos,
		endpos = bone.Pos + bone.Ang:Forward() * 56756,
		mask = MASK_SHOT,
		filter = function(ent) return ent:GetOwner() != mech end
	})
end

function ENT:CanFireMount(ply, mount)
	return ply:KeyDown(mount.Key)
end

function ENT:FireMount(ply, index)
	ply:LagCompensation(true)

	local tr = self:GetTrace(index)

	if tr.Entity:IsValid() then
		local dmg = DamageInfo()
		dmg:SetAttacker(ply)
		dmg:SetInflictor(self)
		dmg:SetDamage(4)
		dmg:SetDamageType(DMG_ENERGYBEAM)
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetDamageForce(tr.Normal * 600)

		tr.Entity:DispatchTraceAttack(dmg, tr)
	end

	ply:LagCompensation(false)
end

function ENT:SetDelay(delay)
	local now = CurTime()
	local last = self:GetNextAttack()
	local diff = now - last

	if diff > engine.TickInterval() or diff < 0 then
		last = now
	end

	self:SetNextAttack(last + delay)
end

function ENT:DriverThink(ply)
	local canFire = self:GetNextAttack() <= CurTime()

	for index, mount in ipairs(self.Config.Mounts) do
		local should = self:CanFireMount(ply, mount)

		if should != self:GetIsFiring(index) then
			self:SetIsFiring(index, should)

			if should then
				self:StartFiring(index)
			else
				self:StopFiring(index)
			end
		end

		if should and canFire then
			self:FireMount(ply, index)
		end
	end

	if canFire then
		self:SetDelay(0.1)
	end
end

if CLIENT then
	function ENT:GetTracerOrigin(index)
		local mount = self.Config.Mounts[index]

		return self:GetOwner():GetBone(mount.Bone):LocalToWorld(mount.Offset)
	end
end
