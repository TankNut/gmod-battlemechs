AddCSLuaFile()

function battlemechs:Hook(name)
	hook.Add(name, "battlemechs", function(ply, ...)
		local mech = self:GetMech(ply)

		if not IsValid(mech) or not mech[name] then
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
			local lp = LocalPlayer()

			if not IsValid(lp) then
				return
			end

			local mech = self:GetMech(lp)

			if not IsValid(mech) or not mech[name] then
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
		end
	end)

	hook.Add("PlayerLeaveVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			mech:OnExit(ply)

			ply:SetNWEntity("battlemechs.mech", NULL)
			ply:DrawShadow(true)
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "battlemechs", function(ply)
		if IsValid(battlemechs:GetMech(ply)) then
			return false
		end
	end)
end
