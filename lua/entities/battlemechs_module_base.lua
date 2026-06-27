AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"

ENT.DisableDuplicator = true

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:SetNoDraw(true)

	self.Module = self:GetOwner().Modules[self:GetModuleIndex()]
	self.Module.Entity = self

	self.Config = self.Module.Config
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ModuleIndex")
end

function ENT:ModuleThink()
end

function ENT:DriverThink(ply)
end

function ENT:MechEmitSound(...) self:GetOwner():MechEmitSound(...) end
function ENT:MechStopSound(...) self:GetOwner():MechStopSound(...) end

if CLIENT then
	function ENT:DrawDebug()
	end
end
