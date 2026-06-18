local GROUP = {}

function GROUP:Initialize(mech, name, health, bones)
	self.Mech = mech
	self.Name = name
	self.MaxHealth = health
	self.Bones = bones

	self.Index = table.insert(mech.DamageGroups, self)

	mech.DamagePool = mech.DamagePool + health
	mech:NetworkVar("Int", "DamageGroup" .. self.Index)

	for _, bone in ipairs(bones) do
		mech.DamageMap[bone] = self
	end
end

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

battlemechs.DamageGroup = setmetatable(GROUP, {__call = function(self, _, ...)
	local instance = setmetatable({}, {__index = self})
	instance:Initialize(...)

	return instance
end})
