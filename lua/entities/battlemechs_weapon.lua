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

ENT.RPM = 600

function ENT:Initialize()
	BaseClass.Initialize(self)
end

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

function ENT:GetDelay()
	return 60 / self.RPM
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
		self:SetNextAttack(CurTime() + self:GetDelay())

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

	local delay = self:GetDelay() / #available

	self:SetLastMount(chosenIndex)
	self:FireMount(ply, chosenIndex)
	self:SetNextAttack(CurTime() + delay)
end

function ENT:MultiFire(ply)
	local mounts = self.Config.Mounts
	local fired = false

	for index, mount in ipairs(mounts) do
		if self:CanFireMount(ply, mount) then
			self:FireMount(ply, index)

			fired = true
		end
	end

	if fired then
		self:SetNextAttack(CurTime() + self:GetDelay())
	end
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
			local e = EffectData()
			e:SetStart(tr.StartPos)
			e:SetOrigin(tr.HitPos)
			e:SetAttachment(index)

			e:SetEntity(self)

			util.Effect("battlemechs_e_tracer", e)
		end
	}, true)

	ply:LagCompensation(false)

	mech:EmitSound("Weapon_SMG1.NPC_Single")
end

if CLIENT then
	function ENT:GetTracerOrigin(pos, index)
		local mech = self:GetOwner()
		local mount = self.Config.Mounts[index]

		if mount.Offset then
			return mech:GetBone(mount.Bone):LocalToWorld(mount.Offset)
		end

		return pos
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
