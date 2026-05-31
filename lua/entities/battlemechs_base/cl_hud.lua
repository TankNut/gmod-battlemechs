function ENT:UpdateHUD()
	local isDriving = self:GetDriver() == LocalPlayer()
	local hud, mech = battlemechs:GetHUD()

	if mech and mech != self then
		return
	end

	if isDriving and not hud then
		battlemechs:CreateHUD(self, "mw4")
	elseif not isDriving and hud then
		battlemechs:DestroyHUD()
	end
end

local block = {
	CHudHealth = true
}

function ENT:HUDShouldDraw(name)
	if block[name] and self:GetDriver() == LocalPlayer() then
		return false
	end
end
