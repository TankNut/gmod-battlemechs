local HUD = battlemechs.HUDList.mw4
local PANEL = {}

AccessorFunc(PANEL, "Mech", "Mech")

local base = Material("model_color")
local wireframe = Material("models/wireframe")

function PANEL:DrawMech(mech, w, h)
	local x, y = self:LocalToScreen(0, 0)

	local ang = LocalPlayer():LocalEyeAngles()
	local pos = mech:GetPos() - (ang:Forward() * mech:GetMechRadius() * 5)

	cam.Start({
		x = x, y = y,
		w = w, h = h,

		origin = pos,
		angles = ang,
		fov = 30,

		aspect = w / h
	})

	render.CullMode(MATERIAL_CULLMODE_NONE)

	for _, part in ipairs(mech.Parts) do
		if part.Type != battlemechs.MODEL or part.RenderGroup == RENDERGROUP_TRANSLUCENT then
			continue
		end

		local health = 1
		local damageGroup = mech.DamageMap[part.Bone]

		if damageGroup then
			health = math.Clamp(mech["GetDamageGroup" .. damageGroup](mech) / mech.DamageGroups[damageGroup].MaxHealth, 0, 1)
		else
			health = math.Clamp(mech:Health() / mech:GetMaxHealth(), 0, 1)
		end

		local hue = math.Remap(health, 1, 0, 120, 0)

		do
			local sat = health > 0 and 1 or 0
			local val = health > 0 and 0.4 or 0

			render.ModelMaterialOverride(base)
			render.SetColorModulation(HSVToColor(hue, sat, val):ToVector():Unpack())

			mech:DrawModelPart(part)
		end

		do
			local sat = health > 0 and 1 or 0
			local val = health > 0 and 1 or 0.2

			render.ModelMaterialOverride(wireframe)
			render.SetColorModulation(HSVToColor(hue, sat, val):ToVector():Unpack())

			mech:DrawModelPart(part)
		end
	end

	render.ModelMaterialOverride(nil)
	render.SetColorModulation(1, 1, 1)

	render.CullMode(MATERIAL_CULLMODE_CCW)

	cam.End()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(HUD.Colors.Fill)
	surface.DrawRect(0, 0, w, h)

	local mech = self:GetMech()

	if IsValid(mech) then
		self:DrawMech(mech, w, h)
	end

	surface.SetDrawColor(HUD.Colors.Border)
	surface.DrawOutlinedRect(0, 0, w, h)
end

HUD.MechView = vgui.RegisterTable(PANEL, "Panel")
