AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_module_base")

ENT.Base = "battlemechs_module_base"

ENT.Delay = 0

ENT.Burst = 0
ENT.BurstDelay = 0

ENT.Sounds = {
	Fire = nil, -- Played whenever the weapon fires
	StartFiring = nil, -- Played whenever the weapon starts firing
	StopFiring = nil, -- Played whenever the weapon stops firing
	Looping = nil, -- Looping sound that is played and stopped when the weapon is
}

function ENT:Initialize()
	BaseClass.Initialize(self)
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "FireDuration")
	self:NetworkVar("Float", "NextAttack")
	self:NetworkVar("Int", "BurstIndex")
	self:NetworkVar("Int", "MountIndex")

	if SERVER then
		self:SetMountIndex(1)
	end
end

-- Checks if we can, e.g. is our damage group still intact?
function ENT:CanFire()
	return true
end

-- Checks if we should, e.g. are we in a burst?
function ENT:ShouldFire(ply)
	local burst = self:GetBurstIndex()

	if self.Burst > 0 and burst > 0 and burst < self.Burst then
		return true
	end

	return ply:KeyDown(self.Config.Key)
end

function ENT:GetDelay()
	return self.Delay
end

function ENT:GetBurstDelay()
	return self.BurstDelay
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

-- Return true to force-stop firing (e.g. end of a burst)
function ENT:UpdateDelay()
	local burst = self:GetBurstIndex() + 1

	self:SetBurstIndex(burst)

	if burst >= self.Burst and self.BurstDelay > 0 then
		self:SetDelay(self:GetBurstDelay())
		self:SetBurstIndex(0)

		return true
	else
		self:SetDelay(self:GetDelay())
	end
end

function ENT:UpdateMountIndex()
	local config = self.Config

	if config.Mounts and #config.Mounts > 1 then
		local mount = self:GetMountIndex() + 1

		if mount > #config.Mounts then
			mount = 1
		end

		self:SetMountIndex(mount)
	end
end

function ENT:StartFiring()
	self:MechEmitSound(self.Sounds.StartFiring)
	self:MechEmitSound(self.Sounds.Looping, true)
end

function ENT:StopFiring()
	self:MechEmitSound(self.Sounds.StopFiring)
	self:MechStopSound(self.Sounds.Looping)
end

function ENT:FireWeapon(ply)
	self:MechEmitSound(self.Sounds.Fire)
end

function ENT:DriverThink(ply)
	local active = self:CanFire() and self:ShouldFire(ply)
	local time = CurTime()

	local duration = self:GetFireDuration()

	if not game.SinglePlayer() then
		SuppressHostEvents(ply)
	end

	ply:LagCompensation(true)

	if active and self:GetNextAttack() <= time then
		if duration == 0 then
			self:StartFiring()
			self:SetFireDuration(duration + FrameTime())
		end

		self:FireWeapon(ply)
		self:UpdateMountIndex()

		if self:UpdateDelay() then
			active = false
		end
	end

	-- Checking the old cached value so we don't double add duration during the first attack
	if active and duration > 0 then
		self:SetFireDuration(self:GetFireDuration() + FrameTime())
	elseif duration > 0 then
		self:StopFiring()
		self:SetFireDuration(0)
	end

	ply:LagCompensation(false)

	if not game.SinglePlayer() then
		SuppressHostEvents(NULL)
	end
end

if CLIENT then
	function ENT:GetTracerOrigin(index)
		local config = self.Config

		if config.Mounts and config.Mounts[index] then
			config = config.Mounts[index]
		end

		return self:GetOwner():GetBone(config.Bone):LocalToWorld(config.Offset)
	end
end
