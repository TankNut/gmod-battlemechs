AddCSLuaFile()

if CLIENT then
	CreateClientConVar("battlemechs_thirdperson", 1, true, true, "Whether your view is thirdperson or not", 0, 1)
end

CreateConVar("battlemechs_hull_damage_1", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), "How much damage is passed through to a mech's hull when the hit section is healthy.", 0)
CreateConVar("battlemechs_hull_damage_2", 0.25, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), "How much damage is passed through to a mech's hull when the hit section is damaged.", 0)
