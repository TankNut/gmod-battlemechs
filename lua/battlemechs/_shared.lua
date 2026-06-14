AddCSLuaFile()

battlemechs = battlemechs or {}

include("sh_helpers.lua")

AddCSLuaFile("cl_render.lua")

if CLIENT then
	include("cl_render.lua")
end

include("sh_convars.lua")
include("sh_hooks.lua")
include("sh_hud.lua")

function battlemechs:GetMech(ply)
	return ply:GetNWEntity("battlemechs.mech")
end

function battlemechs:SimpleBone(parent, pos, ang)
	return {
		Parent = parent,
		Offset = {
			Pos = pos,
			Ang = ang
		}
	}
end

function battlemechs:MW4Scale(x, y, z)
	return Vector(x * 25, y * 25, z * 25)
end

if CLIENT then
	battlemechs.MODEL = 1

	function battlemechs:ModelPart(mdl, bone, data)
		data = data or {}

		data.Type = self.MODEL
		data.Model = Model(mdl)
		data.Bone = bone

		data.Pos = data.Pos or Vector()
		data.Ang = data.Ang or Angle()

		return data
	end
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
