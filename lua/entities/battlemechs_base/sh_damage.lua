AddCSLuaFile()

function ENT:InitDamageGroups()
	self.DamageGroups = {}
	self.DamageMap = {}

	self.DamagePool = 0

	self:BuildDamageGroups() -- Interface

	for index, group in ipairs(self.DamageGroups) do
		group.Fraction = group.MaxHealth / self.DamagePool
		group.MaxHealth = math.ceil(group.Fraction * self.BaseHealth)

		group:Set(group.MaxHealth)
	end
end

function ENT:AddDamageGroup(name, health, bones)
	battlemechs:DamageGroup(self, name, health, bones)
end

function ENT:GetDamageGroup(name)
	return self.DamageMap[name]
end

if SERVER then
	local cvar_mult1 = GetConVar("battlemechs_hull_damage_1")
	local cvar_mult2 = GetConVar("battlemechs_hull_damage_2")

	function ENT:GetHullDamage(health, damage)
		local remaining = health - damage
		local passthrough = 0

		if remaining < 0 then
			passthrough = math.abs(remaining)
		end

		return math.Truncate((damage - passthrough) * cvar_mult1:GetFloat())
			+ math.Truncate(passthrough * cvar_mult2:GetFloat())
	end

	function ENT:TakeGroupDamage(group, damage)
		local health = group:Get()
		local spill = self:GetHullDamage(health, damage)
		local remaining = math.max(health - damage, 0)

		if remaining != health then
			group:Set(remaining)

			-- If remaining == 0 then fire hooks
		end

		return spill
	end

	function ENT:TakeHullDamage(damage)
		if damage <= 0 then
			return
		end

		local health = math.max(self:Health() - damage, 0)

		self:SetHealth(health)

		if health <= 0 then
			self:Remove()
		end
	end

	function ENT:OnTakeDamage(dmg)
		local group = self:GetDamageGroup(self.LastDamageGroup)

		self.LastDamageGroup = nil

		local damage = dmg:GetDamage()

		if group then
			damage = self:TakeGroupDamage(group, damage)
		end

		self:TakeHullDamage(damage)

		return 0
	end
end
