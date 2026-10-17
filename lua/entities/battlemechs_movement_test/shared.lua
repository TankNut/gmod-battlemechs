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

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:DrawShadow(false)

	self:InitPhysics()
	self:InitMovement()

	if SERVER then
		self:CreateSeat()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")
end

function ENT:InitPhysics()
	local mins = self.Hull.Mins
	local maxs = self.Hull.Maxs

	self:EnableCustomCollisions(true)
	self:SetCollisionBounds(mins, maxs)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:MakePhysicsObjectAShadow(true, true)
		self:SetMoveType(MOVETYPE_CUSTOM)

		self:GetPhysicsObject():SetMaterial("player")
		self:PhysWake()
	end
end

function ENT:Think()
	self:NextThink(CurTime())

	if SERVER and not self:HasDriver() then
		self:ProcessMovement()
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
			ply:SetEyeAngles(self:GetAngles())
		end
	end
end

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return self:GetDriver():IsValid()
end

function ENT:TestCollision(start, delta, isbox, extends, mask)
	if bit.band(mask, CONTENTS_GRATE) == 0 or not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), angle_zero, start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end
