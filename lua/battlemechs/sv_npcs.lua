function battlemechs:UpdateNPCRelationships(npc)
	for _, mech in pairs(self.Mechs) do
		npc:AddEntityRelationship(mech, mech:Disposition(npc))
	end
end

function battlemechs:UpdateMechRelationships(mech)
	for _, npc in pairs(self.Npcs) do
		npc:AddEntityRelationship(mech, mech:Disposition(npc))
	end
end
