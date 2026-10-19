AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.AutomaticFrameAdvance = true

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Category = "Battlemechs: MW4"

ENT.Author = "TankNut"

ENT.Spawnable = true

ENT.DisableDuplicator = true

ENT.Hull = {-- The size of the mech's collision hull, this is only used for movement. Keep it off the ground so it doesn't catch on any bumps
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

include("sh_movement.lua")
include("sh_physics.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:DrawShadow(false)

	self:InitPhysics()
	self:InitMovement()

	if CLIENT then
		self:SetRenderBounds(self.Hull.Mins, self.Hull.Maxs)
	else
		self:CreateSeat()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Bool", "IsFrozen")

	self:NetworkVar("Vector", "CustomVelocity")
end

function ENT:Think()
	self:NextThink(CurTime())

	if SERVER and not self:HasDriver() then
		self:ProcessMovement()
	end

	if CLIENT then
		local should = self:GetDriver() == LocalPlayer()

		if should != self:GetPredictable() then
			self:SetPredictable(should)
		end
	end

	return true
end

if SERVER then
	function ENT:CreateSeat()
		self.Seat = ents.Create("prop_vehicle_prisoner_pod")
		self.Seat._battlemech = self

		self.Seat:SetModel("models/props_lab/cactus.mdl")
		self.Seat:SetKeyValue("limitview", 0, 0)

		self.Seat:Spawn()

		self.Seat:SetParent(self)
		self.Seat:SetTransmitWithParent(true)

		self.Seat:SetLocalPos(vector_origin)
		self.Seat:SetLocalAngles(angle_zero)

		self.Seat:SetSolid(SOLID_NONE)
		self.Seat:SetRenderMode(RENDERMODE_NONE)
		self.Seat:DrawShadow(false)

		self:DeleteOnRemove(self.Seat)
		self:SetSeat(self.Seat)
	end

	function ENT:Use(ply)
		if not ply:KeyPressed(IN_USE) or self:HasDriver() then
			return
		end

		ply:EnterVehicle(self.Seat)
	end

	function ENT:OnEnter(ply)
		local dir = self:GetForward()

		dir.z = 0
		dir:Normalize()

		ply:SetEyeAngles(dir:Angle())
	end

	function ENT:OnExit(ply)
		if ply:Alive() then
			local mins, maxs = ply:GetHull()

			local tr = util.TraceHull({
				start = self:GetPos(),
				endpos = self:GetPos() - Vector(0, 0, self.GroundOffset),
				filter = {self, ply},
				mask = MASK_PLAYERSOLID,
				mins = mins,
				maxs = maxs
			})

			ply:SetPos(tr.HitPos)

			local ang = self:GetAngles()
			ang.r = 0

			ply:SetEyeAngles(ang)
		end
	end
end

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return self:GetDriver():IsValid()
end

if CLIENT then
	function ENT:DrawTranslucent(flags)
		render.DrawWireframeBox(self:GetPos(), angle_zero, self.Hull.Mins, self.Hull.Maxs, Color(255, 0, 0), true)
	end
end
