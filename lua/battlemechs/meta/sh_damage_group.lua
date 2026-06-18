local GROUP = {}

function GROUP:Get()
	return self.Mech["GetDamageGroup" .. self.Index](self.Mech)
end

function GROUP:GetFraction()
	return self:Get() / self.MaxHealth
end

function GROUP:Set(value)
	self.Mech["SetDamageGroup" .. self.Index](self.Mech, value)
end

function GROUP:IsBroken()
	return self:Get() <= 0
end

battlemechs.DamageGroup = setmetatable(GROUP, {__call = function(_, _, mech, name, health, bones)
	local instance = setmetatable({
		Mech = mech,
		Name = name,
		MaxHealth = health,
		Bones = bones
	}, {__index = GROUP})

	instance.Index = table.insert(mech.DamageGroups, instance)

	mech.DamagePool = mech.DamagePool + health
	mech:NetworkVar("Int", "DamageGroup" .. instance.Index)

	for _, bone in ipairs(bones) do
		mech.DamageMap[bone] = instance
	end

	return instance
end})
