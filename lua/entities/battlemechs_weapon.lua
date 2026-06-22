AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_module")

ENT.Base = "battlemechs_module"
ENT.Author = "TankNut"

ENT.Delay = 60 / 600

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "NextAttack")
	self:NetworkVar("Int", "LastMount")
end

function ENT:DriverThink(ply)
	if self:GetNextAttack() > CurTime() then
		return
	end

	if self.Config.ChainFire then
		self:ChainFire(ply)
	else
		self:MultiFire(ply)
	end
end

function ENT:GetDelay(amount)
	if self.Config.FixedDelay then
		return self.Config.FixedDelay
	end

	if self.Config.ChainFire then
		return self.Delay / amount
	end

	return self.Delay
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

function ENT:CanFireMount(ply, mount)
	return ply:KeyDown(mount.Key)
end

function ENT:ChainFire(ply)
	local mounts = self.Config.Mounts
	local available = {}

	-- Get all available mounts
	for k, mount in ipairs(mounts) do
		if self:CanFireMount(ply, mount) then
			table.insert(available, k)
		end
	end

	if #available == 0 then
		return
	elseif #available == 1 then
		local index = available[1]

		self:SetLastMount(index)
		self:FireMount(ply, index)
		self:SetDelay(self:GetDelay(#available))

		return
	end

	local lastIndex = self:GetLastMount()
	local chosenIndex = available[1]

	-- Find out what mount we should fire next
	for _, index in ipairs(available) do
		if index > lastIndex then
			chosenIndex = index

			break
		end
	end

	self:SetLastMount(chosenIndex)
	self:FireMount(ply, chosenIndex)
	self:SetDelay(self:GetDelay(#available))
end

function ENT:MultiFire(ply)
	local mounts = self.Config.Mounts
	local fired = 0

	for index, mount in ipairs(mounts) do
		if self:CanFireMount(ply, mount) then
			self:FireMount(ply, index)

			fired = fired + 1
		end
	end

	if fired > 0 then
		self:SetDelay(self:GetDelay(fired))
	end
end

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

function ENT:FireMount(ply, index)
	local mount = self.Config.Mounts[index]

	local mech = self:GetOwner()
	local bone = mech:GetBone(mount.Bone)

	ply:LagCompensation(true)

	mech:FireBullets({
		Src = bone.Pos,
		Dir = bone.Ang:Forward(),
		Attacker = ply,
		Inflictor = self,
		Damage = 8,
		Spread = Vector(0.01, 0.01),
		Tracer = 0,
		Callback = function(_, tr, dmg)
			self:DoEffects(index, tr)
		end
	}, true)

	ply:LagCompensation(false)

	mech:EmitSound("Weapon_SMG1.NPC_Single")
end

if CLIENT then
	function ENT:GetTracerOrigin(index)
		local mount = self.Config.Mounts[index]

		return self:GetOwner():GetBone(mount.Bone):LocalToWorld(mount.Offset)
	end

	local material = Material("effects/spark")

	function ENT:SetupTracer(tracer)
		tracer.Material = material
		tracer.Velocity = 8000
		tracer.Length = math.Rand(128, 256)
		tracer.Scale = math.Rand(5, 6)
	end

	local forward = Color(255, 0, 0)
	local right =   Color(0, 255, 0)
	local up =      Color(0, 0, 255)

	function ENT:DrawDebug()
		local mech = self:GetOwner()

		for index, mount in ipairs(self.Config.Mounts) do
			if mount.Offset then
				local bone = mech:GetBone(mount.Bone)
				local pos, ang = bone:LocalToWorld(mount.Offset, angle_zero)

				render.DrawLine(pos, pos + ang:Forward() * 10, forward)
				render.DrawLine(pos, pos + ang:Right() * 10, right)
				render.DrawLine(pos, pos + ang:Up() * 10, up)

				battlemechs:DrawWorldText(bone:LocalToWorld(mount.Offset), string.format("%s[%s][%s]", self:GetClass(), self:GetModuleIndex(), index), true)
			end
		end
	end
end
