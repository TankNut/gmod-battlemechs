AddCSLuaFile()

function ENT:InitDamageGroups()
	self.DamageGroups = {}
	self.DamageMap = {}

	self.DamagePool = 0

	self:BuildDamageGroups()

	for index, group in ipairs(self.DamageGroups) do
		group.Fraction = group.MaxHealth / self.DamagePool
		group.MaxHealth = math.ceil(group.Fraction * self.BaseHealth)

		group:Set(group.MaxHealth)
	end

	self.DamageCache = {}
end

function ENT:AddDamageGroup(name, health, bones)
	battlemechs:DamageGroup(self, name, health, bones)
end

function ENT:GetDamageGroup()
end

function ENT:GetBoneDamageGroup(bone)
	return self.DamageMap[bone]
end

if SERVER then
	function ENT:OnTakeDamage(dmg)
		return 0
	end

	local mult1 = GetConVar("battlemechs_hull_damage_1")
	local mult2 = GetConVar("battlemechs_hull_damage_2")

	function ENT:GetHullDamage(index, health, damage)
		local remaining = health - damage
		local passthrough = 0

		if remaining < 0 then
			passthrough = math.abs(remaining)
		end

		return math.Truncate((damage - passthrough) * mult1:GetFloat())
			+ math.Truncate(passthrough * mult2:GetFloat())
	end

	local debugConvar = CreateConVar("battlemechs_debug_damage", 0, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

	function ENT:TakeMechDamage(index, dmg)
		local group = self.DamageGroups[index]
		local damage = dmg:GetDamage()
		local health = group:Get()

		local hullDamage = self:GetHullDamage(index, health, damage)
		local remaining = math.max(health - damage, 0)

		if remaining != health then
			group:Set(remaining)
		end

		if debugConvar:GetBool() then
			print(string.format("\t%s: %s -> %s (%s to hull)", group.Name, health, remaining, hullDamage))
		end

		if hullDamage > 0 then
			local hull = math.max(self:Health() - hullDamage, 0)

			self:SetHealth(hull)

			if hull <= 0 then
				self:Remove()
			end
		end
	end

	function ENT:RegisterDamageEvent(bone, dmg)
		local group = assert(self:GetBone(bone).DamageGroup, "Bone '" .. bone .. "' took damage but is not tied to a damage group!")
		local cache = self.DamageCache

		local uid = string.format("%s-%p-%p-%p", engine.TickCount(), dmg:GetWeapon(), dmg:GetInflictor(), dmg:GetAttacker())

		if not cache[uid] then
			cache[uid] = {
				Attacker = dmg:GetAttacker(),
				Inflictor = dmg:GetInflictor(),
				Weapon = dmg:GetWeapon()
			}
		end

		table.insert(cache[uid], {
			Index = group.Index,
			Damage = dmg:GetDamage(),
			Type = dmg:GetDamageType()
		})
	end

	function ENT:ProcessDamageEvents()
		for _, cache in pairs(self.DamageCache) do
			local damageCount = 0
			local damageType = 0

			local totalDamage = 0
			local baseFraction = 0

			local groups = {}

			for _, instance in ipairs(cache) do
				damageType = bit.bor(damageType, instance.Type)
				damageCount = damageCount + 1

				totalDamage = totalDamage + instance.Damage

				local old = groups[instance.Index] or 0
				local new = math.max(old, instance.Damage)

				baseFraction = baseFraction + (new - old)

				groups[instance.Index] = new
			end

			local finalDamage = baseFraction / table.Count(groups)

			if debugConvar:GetBool() then
				print("=== Damage Event ===")
				print("\tTick:", engine.TickCount())
				print("\t" .. tostring(self))
				print("\tDriver:", self:GetDriver())
				print("\tInstances:", #cache)
				print("\tBase Damage:", math.Truncate(totalDamage))
				print("\tFinal Damage:", math.Truncate(finalDamage))
				print("Source:")
				print("\tAttacker:", cache.Attacker)
				print("\tInflictor:", cache.Inflictor)
				print("\tWeapon:", cache.Weapon)

				print("Damage Spread:")
			end

			for index, fraction in pairs(groups) do
				local damage = math.Truncate((fraction / baseFraction) * finalDamage)

				local dmg = DamageInfo()
				dmg:SetDamageType(damageType)
				dmg:SetDamage(damage)

				if IsValid(cache.Attacker) then
					dmg:SetAttacker(cache.Attacker)
				end

				if IsValid(cache.Inflictor) then
					dmg:SetInflictor(cache.Inflictor)
				end

				if IsValid(cache.Weapon) then
					dmg:SetWeapon(cache.Weapon)
				end

				self:TakeMechDamage(index, dmg)
			end
		end

		table.Empty(self.DamageCache)
	end
end
