AddCSLuaFile()

module("battlemechs", package.seeall)

Mechs = Mechs or {}
Npcs = Npcs or {}

local function shared(path) AddCSLuaFile(path) include(path) end
local function client(path) if CLIENT then include(path) else AddCSLuaFile(path) end end
local function server(path) if SERVER then include(path) end end




end

shared("sh_convars.lua")
shared("sh_hooks.lua")
shared("sh_hud.lua")

shared("meta/sh_bone.lua")
shared("meta/sh_damage_group.lua")
shared("meta/sh_hitbox.lua")
shared("meta/sh_turret.lua")

client("cl_render.lua")

server("sv_npcs.lua")

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
