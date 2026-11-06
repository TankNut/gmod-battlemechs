module("battlemechs", package.seeall)

function UpdateNPCRelationships(npc)
	for _, mech in pairs(Mechs) do
		npc:AddEntityRelationship(mech, mech:Disposition(npc))
	end
end

function UpdateMechRelationships(mech)
	for _, npc in pairs(Npcs) do
		npc:AddEntityRelationship(mech, mech:Disposition(npc))
	end
end
