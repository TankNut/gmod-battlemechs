AddCSLuaFile()

function ENT:InitModules()
	self.Modules = {}
	self:BuildModules()
end

function ENT:AddModule(class, config)
	local id = table.insert(self.Modules, {
		Config = config or {}
	})

	if SERVER then
		local ent = ents.Create(class)

		ent:SetPos(self:WorldSpaceCenter())
		ent:SetAngles(self:GetAngles())
		ent:SetParent(self)

		ent:SetOwner(self)

		ent:SetTransmitWithParent(true)

		ent:SetModuleIndex(id)

		ent:Spawn()
		ent:Activate()

		self:DeleteOnRemove(ent)
	end
end

function ENT:UpdateModules()
	for _, v in ipairs(self.Modules) do
		v.Entity:ModuleThink()
	end
end

function ENT:PlayerPostThink(ply)
	for _, v in ipairs(self.Modules) do
		v.Entity:DriverThink(ply)
	end
end
