AddCSLuaFile()

ENT.Base = "battlemechs_mw4_base"

ENT.PrintName = "Owens"
ENT.Category = "Battlemechs: MW4"

ENT.Author = "TankNut"

ENT.Spawnable = true

-- Movement related fields
ENT.Hull = { -- Physics hull, only used for movement
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

ENT.GroundOffset = 110 -- How far above the ground the mech's origin sits

ENT.MoveAcceleration = 200 -- Hammer units/s of acceleration when moving or slowing down
ENT.MaxSlope = 40 -- The steepest slope a mech can walk on, any steeper and it'll start sliding down

ENT.WalkSpeed = 200 -- The target speed when walking normally
ENT.RunSpeed = 600 -- The target speed when +speed is held down

ENT.TurnRate = 126 -- [MoveStat] Degrees/s the mech can turn

-- Gait/leg related fields
ENT.StepSize = 300 -- [MoveStat] The forward length of each step the mech takes
ENT.Stance = {0.45, 0.65} -- [MoveStat] Fraction of time each leg spends in the air
ENT.ForwardLean = {1.1, 1.4} -- [MoveStat] How far off-center the mech's legs are when moving

ENT.SideStep = 10 -- [MoveStat] The amount of side offset that's applied to the gait offset value
ENT.UpStep = {2, 1} -- [MoveStat] The amount of upwards offset that's applied to the gait offset value

-- Misc fields
ENT.BaseHealth = 2000

ENT.DrawRadius = 200 -- The radius that's added on top of ENT.Hull to determine the mech's render bounds
ENT.FootstepSound = "MW4.Footstep.Small"

-- Custom fields

ENT.UpperLength = 38
ENT.LowerLength = 85

ENT.FootOffset = 10

include("blueprint/sh_bones.lua")
include("blueprint/sh_hitboxes.lua")
include("blueprint/sh_legs.lua")

AddCSLuaFile("blueprint/cl_model.lua")

if CLIENT then
	include("blueprint/cl_model.lua")
end

function ENT:CreateNetworkVars()
	self:NetworkVar("Angle", "TorsoAngle")

	self:NetworkVar("Angle", "LeftWeaponAngle")
	self:NetworkVar("Angle", "RightWeaponAngle")
end
