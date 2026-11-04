AddCSLuaFile()

function battlemechs:Hook(name)
	hook.Add(name, "battlemechs", function(ply, ...)
		local mech = self:GetMech(ply)

		if not mech:IsValid() or not mech[name] then
			return
		end

		return mech[name](mech, ply, ...)
	end)
end

battlemechs:Hook("PlayerButtonDown")
battlemechs:Hook("PlayerButtonUp")
battlemechs:Hook("PlayerPostThink")

if CLIENT then
	function battlemechs:HookLocal(name)
		hook.Add(name, "battlemechs", function(...)
			if not self.lp then
				return
			end

			local mech = self:GetMech(self.lp)

			if not mech:IsValid() or not mech[name] then
				return
			end

			return mech[name](mech, ...)
		end)
	end

	battlemechs:Hook("CalcView")
	battlemechs:Hook("PrePlayerDraw")
	battlemechs:Hook("PostPlayerDraw")

	battlemechs:HookLocal("HUDPaint")
	battlemechs:HookLocal("HUDShouldDraw")
else
	hook.Add("PlayerEnteredVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			ply:SetNWEntity("battlemechs.mech", mech)
			ply:DrawShadow(false)

			mech:OnEnter(ply)

			battlemechs:UpdateMechRelationships(mech)
		end
	end)

	hook.Add("PlayerLeaveVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			mech:OnExit(ply)

			ply:SetNWEntity("battlemechs.mech", NULL)
			ply:DrawShadow(true)

			battlemechs:UpdateMechRelationships(mech)
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "battlemechs", function(ply)
		if battlemechs:GetMech(ply):IsValid() then
			return false
		end
	end)
end

hook.Add("OnEntityCreated", "battlemechs", function(ent)
	if ent:IsNPC() then
		battlemechs.Npcs[ent:EntIndex()] = ent

		if SERVER then
			battlemechs:UpdateNPCRelationships(ent)
		end
	elseif scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_base") then
		battlemechs.Mechs[ent:EntIndex()] = ent
	end
end)

hook.Add("EntityRemoved", "battlemechs", function(ent)
	if ent:IsNPC() then
		battlemechs.Npcs[ent:EntIndex()] = nil
	elseif scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_base") then
		battlemechs.Mechs[ent:EntIndex()] = nil
	end
end)
