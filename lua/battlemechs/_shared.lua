AddCSLuaFile()

module("battlemechs", package.seeall)

Mechs = Mechs or {}
Npcs = Npcs or {}

include("sh_convars.lua")
include("sh_hooks.lua")
include("sh_hud.lua")

include("meta/sh_bone.lua")
include("meta/sh_damage_group.lua")
include("meta/sh_hitbox.lua")
include("meta/sh_turret.lua")

if SERVER then
	include("sv_npcs.lua")
end

AddCSLuaFile("cl_render.lua")

if CLIENT then
	include("cl_render.lua")
end

function Assert(val, str, ...)
	if not val then
		error(string.format(str, ...), 2)
	end

	return val
end

function GetMech(ply)
	return ply:GetNWEntity("battlemechs.mech")
end

function MW4Scale(x, y, z)
	return Vector(x * 25, y * 25, z * 25)
end

if CLIENT then
	MODEL = 1

	hook.Add("InitPostEntity", "battlemechs", function()
		lp = LocalPlayer()
	end)
end

sound.Add({
	name = "MW4.Footstep.Small",
	channel = CHAN_STATIC,
	volume = 1,
	level = 110,
	pitch = {95, 105},
	sound = ")battlemechs/mw4/footstep_small.wav"
})

sound.Add({
	name = "MW4.Footstep.Large",
	channel = CHAN_STATIC,
	volume = 1,
	level = 110,
	pitch = {95, 105},
	sound = ")battlemechs/mw4/footstep_large.wav"
})
