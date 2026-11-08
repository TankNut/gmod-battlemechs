module("battlemechs", package.seeall)

local GROUP = CreateMetaTable("DamageGroup")

function GROUP:Initialize(name, health, bones)
	self.Name = name
	self.MaxHealth = health
	self.Bones = bones

	self.Index = table.insert(self.Mech.DamageGroups, self)

	self.Mech.DamagePool = self.Mech.DamagePool + health
	self.Mech:NetworkVar("Int", "DamageGroup" .. self.Index)

	self.Mech.DamageMap[name] = self
end

function GROUP:Get()
	return self.Mech["GetDamageGroup" .. self.Index](self.Mech)
end

function GROUP:GetFraction()
	return self:Get() / self.MaxHealth
end

function GROUP:Set(val)
	self.Mech["SetDamageGroup" .. self.Index](self.Mech, val)
end

function GROUP:IsBroken()
	return self:Get() <= 0
end

function GROUP:__tostring()
	return string.format("%s [%s][%s]", self.MetaName, self.Mech:EntIndex(), self.Name)
end
