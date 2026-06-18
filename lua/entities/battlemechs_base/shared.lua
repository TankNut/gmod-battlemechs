AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.AutomaticFrameAdvance = true

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"

ENT.DisableDuplicator = true

-- [MoveStat] indicates a value can vary based on how fast the mech is going relative to the clamped walk and run speeds (where walk = 0 and run = 1)
-- A table value is linearly interpolated based on the movement fraction
-- Functions are called with self and the movement fraction
-- Every other type of value is passed along without modification

-- Movement related fields
ENT.Hull = {-- The size of the mech's collision hull, this is only used for movement. Keep it off the ground so it doesn't catch on any bumps
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

ENT.GroundOffset = 110 -- How far above the ground the mech sits

ENT.MoveAcceleration = 400 -- Hammer units/s of acceleration when moving or slowing down
ENT.MaxSlope = 40 -- The steepest slope a mech can walk on, any steeper and it'll start sliding down

ENT.WalkSpeed = 200 -- The target speed when walking normally
ENT.RunSpeed = 600 -- The target speed when +speed is held down

ENT.TurnRate = 90 -- [MoveStat] Degrees/s the mech can turn

-- Gait/leg related fields
ENT.StepSize = {160, 220} -- [MoveStat] The horizontal side of each step the mech takes
ENT.Stance = {0.45, 0.65} -- [MoveStat] Fraction of time each leg spends in the air
ENT.ForwardLean = {1.1, 1.4} -- [MoveStat] How far off-center the mech's legs are when moving

ENT.SideStep = 10 -- [MoveStat] The amount of side offset that's applied to the gait offset value
ENT.UpStep = {2, 1} -- [MoveStat] The amount of upwards offset that's applied to the gait offset value

-- Camera
ENT.FirstPersonSettings = {
	Bone = nil,
	Pos = Vector(),

	HideParts = true
}

ENT.ThirdPersonSettings = {
	Distance = 400,
	Pos = Vector(0, 0, 100)
}

-- Misc fields
ENT.BaseHealth = 6000

ENT.DrawRadius = 200 -- The radius that's added on top of ENT.Hull to determine the mech's render bounds
ENT.FootstepSound = "MW4.Footstep.Small"

ENT.DrawDriver = {
	Enabled = false,
	Bone = nil,

	Pos = Vector(),
	Ang = Angle()
}

include("sh_bones.lua")
include("sh_damage.lua")
include("sh_gait.lua")
include("sh_helpers.lua")
include("sh_hitboxes.lua")
include("sh_ik.lua")
include("sh_modules.lua")
include("sh_movement.lua")
include("sh_view.lua")

include("sh_interface.lua")

AddCSLuaFile("cl_debug.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_parts.lua")

if CLIENT then
	include("cl_debug.lua")
	include("cl_hud.lua")
	include("cl_parts.lua")
end

function ENT:SpawnFunction(ply, tr, classname)
	local ent = BaseClass.SpawnFunction(self, ply, tr, classname)

	ent:SetPos(ent:GetPos() + Vector(0, 0, ent:GetGroundOffset()))

	return ent
end

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:DrawShadow(false)

	self:InitPhysics()
	self:InitMovement()

	self:InitBones()
	self:InitLegs()
	self:InitHitboxes()
	self:InitModules()

	if CLIENT then
		local radius = self:GetMechRadius()
		local bounds = Vector(radius, radius, radius)

		self:InitParts()
		self:SetRenderBounds(-bounds, bounds)

		hook.Add("PreDrawHUD", self, self.PreDrawHUD)
	else
		self:CreateSeat()
	end
end

function ENT:InitPhysics()
	if IsValid(self.PhysCollide) then
		self.PhysCollide:Destroy()
	end

	local mins = self.Hull.Mins
	local maxs = self.Hull.Maxs

	self:EnableCustomCollisions(true)
	self:SetCollisionBounds(mins, maxs)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs, "solidmetal")
		self:SetSolid(SOLID_VPHYSICS)

		self:SetMaxHealth(self.BaseHealth)
		self:SetHealth(self.BaseHealth)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	-- Gait
	self:NetworkVar("Float", "WalkCycle")
	self:NetworkVar("Vector", "GaitOffset")

	-- Movement
	self:NetworkVar("Bool", "OnGround")
	self:NetworkVar("Vector", "MechVelocity")

	self:InitDamageGroups()

	self:CreateNetworkVars()
end

function ENT:Think()
	self:PhysWake()

	if SERVER then
		self:ProcessDamageEvents()
	end

	self:UpdateBones()
	self:UpdateLegs()

	if CLIENT then
		self:UpdateThirdPerson()
		self:UpdateHUD()
	end

	self:UpdateModules()

	self:NextThink(CurTime())

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

		self:SetThirdPersonMode(ply)
	end

	function ENT:OnExit(ply)
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

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return IsValid(self:GetDriver())
end

function ENT:GetLookAng()
	local ply = self:GetDriver()

	if not IsValid(ply) then
		return self:GetAngles()
	end

	return ply:LocalEyeAngles()
end

function ENT:OnRemove()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end

	if CLIENT then
		self:ClearParts()
		battlemechs:DestroyHUD(self)
	end
end

function ENT:OnReloaded()
	self:InitBones()
	self:InitLegs()
	self:InitHitboxes()

	if CLIENT then
		self.Debug_HitboxCache = nil

		self:InitParts()
		battlemechs:DestroyHUD(self)
	end
end

if CLIENT then
	function ENT:PrePlayerDraw(ply, flags)
		local config = self.DrawDriver

		if not config.Enabled then
			return true
		end

		local pos = config.Pos
		local ang = config.Ang

		if config.Bone then
			self:UpdateBones()

			local bone = self.Bones[config.Bone]

			pos, ang = LocalToWorld(pos, ang, bone.Pos, bone.Ang)
		else
			pos, ang = LocalToWorld(pos, ang, self:GetPos(), self:GetAngles())
		end

		ply:SetPos(pos)
		ply:SetRenderAngles(ang)

		ply:SetPoseParameter("aim_pitch", 0)
		ply:SetPoseParameter("aim_yaw", 0)

		ply:SetPoseParameter("head_pitch", 0)
		ply:SetPoseParameter("head_yaw", 0)

		ply:InvalidateBoneCache()
	end

	function ENT:PostPlayerDraw(ply, flags)
	end

	function ENT:Draw(flags)
		self:DrawParts(flags, RENDERGROUP_OPAQUE)
	end

	function ENT:DrawTranslucent(flags)
		self:DrawParts(flags, RENDERGROUP_TRANSLUCENT)
	end
end

-- CONTENTS_GRATE runs for physguns but not for bullets
-- CONTENTS_HITBOX runs for bullets but not for physguns

function ENT:TestCollision(start, delta, isbox, extends, mask)
	if bit.band(mask, CONTENTS_GRATE) == 0 or not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end
