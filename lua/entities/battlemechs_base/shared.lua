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
ENT.Hull = {
	Size = 64, -- Length and Width
	Height = 105, -- Height above the entity origin
	Offset = 135, -- How high the origin sits above the ground
	Step = 96 -- How far the bottom of the hull sits from the ground, enables stepping over objects
}

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

ENT.Bounds = {
	Mins = Vector(-120, -120, -135),
	Maxs = Vector(120, 120, 120)
}

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
include("sh_think.lua")
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

if SERVER then
	function ENT:SpawnFunction(ply, tr, classname)
		local ent = BaseClass.SpawnFunction(self, ply, tr, classname)

		if not IsValid(ent) then
			return
		end

		local offset = self.Hull.Offset

		ent:SetPos(tr.HitPos + Vector(0, 0, offset))
		ent:SetAngles(angle_zero)

		local yaw = math.NormalizeAngle(tr.Normal:Angle().y + 180)
		ent:SetMechAngles(Angle(0, yaw, 0))

		return ent
	end
end

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:DrawShadow(false)

	self:InitPhysics()

	self:InitBones()
	self:InitLegs()
	self:InitHitboxes()
	self:InitModules()

	self.Radius = (self.Bounds.Maxs - self.Bounds.Mins):Length() * 0.5
	self.SoundCache = {}

	if CLIENT then
		self:InitParts()
		self:SetRenderBounds(self.Bounds.Mins, self.Bounds.Maxs)

		hook.Add("PreDrawHUD", self, self.PreDrawHUD)
	else
		self:CreateSeat()

		self:SetMaxHealth(self.BaseHealth)
		self:SetHealth(self.BaseHealth)

		self:InitMovement()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Angle", "MechAngles")
	self:NetworkVar("Vector", "MechVelocity")

	self:NetworkVar("Float", "WalkCycle")
	self:NetworkVar("Vector", "GaitOffset")

	self:NetworkVar("Bool", "OnGround")

	self:InitDamageGroups()
	self:CreateNetworkVars()
end

function ENT:InitPhysics()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end

	local phys = self:GetPhysicsObject()
	local frozen = false

	if phys:IsValid() then
		frozen = not phys:IsMotionEnabled()
	end

	local hull = self.Hull

	self.Mins = Vector(-hull.Size, -hull.Size, -hull.Offset + hull.Step)
	self.Maxs = Vector(hull.Size, hull.Size, hull.Height)

	self:EnableCustomCollisions(true)

	self:SetCollisionBounds(self.Mins - Vector(0, 0, hull.Step), self.Maxs)
	self:SetSurroundingBounds(self.Bounds.Mins, self.Bounds.Maxs)

	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)

	if SERVER then
		self:PhysicsInitBox(self.Mins, self.Maxs, "solidmetal")
		self:SetSolid(SOLID_VPHYSICS)

		self:GetPhysicsObject():EnableMotion(not frozen)
	end
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
		ply:SetEyeAngles(self:GetMechAngles())

		self:SetThirdPersonMode(ply)
	end

	function ENT:OnExit(ply)
		if ply:Alive() then
			local mins, maxs = ply:GetHull()

			local tr = util.TraceHull({
				start = self:GetPos(),
				endpos = self:GetPos() + Vector(0, 0, self.Bounds.Mins.z),
				filter = {self, ply},
				mask = MASK_PLAYERSOLID,
				mins = mins,
				maxs = maxs
			})

			ply:SetPos(tr.HitPos)
			ply:SetEyeAngles(self:GetMechAngles())
		end
	end
end

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return self:GetDriver():IsValid()
end

function ENT:OnRemove()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end

	self:ClearHitboxes()

	if CLIENT then
		self:ClearParts()
		battlemechs:DestroyHUD(self)
	end

	for snd in pairs(self.SoundCache) do
		self:StopSound(snd)
	end
end

function ENT:OnReloaded()
	self.Radius = (self.Bounds.Maxs - self.Bounds.Mins):Length() * 0.5

	self:InitPhysics()

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

--[[
	TestCollision is only called into for traces that pass into our , vphysics has it's own thing going on

	Since player physics have funky behavior when clipping inside of a vphysics hull, we still have to
	maintain a classic PhysCollide box and trace against that during player movement

	Testing player movement against hitboxes wouldn't be a good time anyways since the player can't be pushed around by bone movement
	which would result in the player clipping into the mech, just in a slightly different way instead
]]
function ENT:TestCollision(start, delta, isbox, extends, mask)
	if mask != MASK_PLAYERSOLID then
		return self:TestHitboxes(start, delta, isbox, extends, mask)
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hitpos, normal, fraction = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hitpos then
		return
	end

	return {
		HitPos = hitpos,
		Normal = normal,
		Fraction = fraction
	}
end
