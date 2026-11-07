module("battlemechs", package.seeall)

function Hook(name)
	hook.Add(name, "battlemechs", function(ply, ...)
		local mech = GetMech(ply)

		if not mech:IsValid() or not mech[name] then
			return
		end

		return mech[name](mech, ply, ...)
	end)
end

Hook("PlayerButtonDown")
Hook("PlayerButtonUp")
Hook("PlayerPostThink")

if CLIENT then
	function HookLocal(name)
		hook.Add(name, "battlemechs", function(...)
			if not lp then
				return
			end

			local mech = GetMech(lp)

			if not mech:IsValid() or not mech[name] then
				return
			end

			return mech[name](mech, ...)
		end)
	end

	Hook("CalcView")
	Hook("PrePlayerDraw")
	Hook("PostPlayerDraw")

	HookLocal("HUDPaint")
	HookLocal("HUDShouldDraw")
else
	hook.Add("PlayerEnteredVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			ply:SetNWEntity("battlemechs.mech", mech)
			ply:DrawShadow(false)

			mech:OnEnter(ply)

			UpdateMechRelationships(mech)
		end
	end)

	hook.Add("PlayerLeaveVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			mech:OnExit(ply)

			ply:SetNWEntity("battlemechs.mech", NULL)
			ply:DrawShadow(true)

			UpdateMechRelationships(mech)
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "battlemechs", function(ply)
		if GetMech(ply):IsValid() then
			return false
		end
	end)
end

hook.Add("OnEntityCreated", "battlemechs", function(ent)
	if ent:IsNPC() then
		Npcs[ent:EntIndex()] = ent

		if SERVER then
			battlemechs.UpdateNPCRelationships(ent)
		end
	elseif scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_base") then
		Mechs[ent:EntIndex()] = ent
	end
end)

hook.Add("EntityRemoved", "battlemechs", function(ent)
	if ent:IsNPC() then
		Npcs[ent:EntIndex()] = nil
	elseif scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_base") then
		Mechs[ent:EntIndex()] = nil
	end
end)
