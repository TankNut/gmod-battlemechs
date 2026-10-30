local methods = {"Physics", "Bones", "Hitboxes", "Gait", "IK", "Turrets", "Modules"}
local convars = {}

for index, name in ipairs(methods) do
	convars[index] = CreateClientConVar("battlemechs_debug_" .. string.lower(name), 0, true)
end

local physicsColor = Color(255, 191, 0)
local stepColor = Color(255, 0, 0)

local forward = Color(255, 0, 0)
local right =   Color(0, 255, 0)
local up =      Color(0, 0, 255)

local arrow = Material("widgets/arrow.png", "nocull smooth mips")
local cvar_ignorez = CreateClientConVar("battlemechs_debug_ignorez", 0, true)

local function drawBox(pos, ang, mins, maxs, color)
	local oldAlpha = color.a
	local ignorez = cvar_ignorez:GetBool()

	color.a = 255
	render.DrawWireframeBox(pos, ang, mins, maxs, color, not ignorez)

	color.a = 10
	render.SetColorMaterial()
	cam.IgnoreZ(ignorez)
	render.DrawBox(pos, ang, mins, maxs, color)
	cam.IgnoreZ(false)

	color.a = oldAlpha
end

local function drawArrow(pos, ang, length, color)
	local dir = isangle(ang) and ang:Forward() or ang

	cam.IgnoreZ(true)
		render.SetMaterial(arrow)
		render.DrawBeam(pos, pos + dir * length, length * 0.125, 1, 0, color)
	cam.IgnoreZ(false)
end

function ENT:DebugPhysics()
	local mins, maxs = Vector(self.Mins), Vector(self.Maxs)
	local pos = self:GetPos()

	drawBox(pos, angle_zero, mins, maxs, physicsColor)

	maxs.z = mins.z
	mins.z = mins.z - self.Hull.Step

	drawBox(pos, angle_zero, mins, maxs, stepColor)
	drawArrow(pos, self:GetMechAngles(), 100, physicsColor)
end

function ENT:DebugBones()
	for _, bone in ipairs(self.Bones) do
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Forward() * 10, forward)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Right() * 10, right)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Up() * 10, up)

		battlemechs:DrawWorldText(bone.Pos, bone.Name, true)
	end
end

function ENT:DebugHitboxes()
	if not self.Debug_HitboxCache then
		local bones = {}

		for _, hitbox in ipairs(self.Hitboxes) do
			bones[hitbox.Bone.Index] = true
		end

		local increment = 300 / table.Count(bones)
		local i = 0

		for k in pairs(bones) do
			bones[k] = HSVToColor(i * increment, 0.5, 1)
			i = i + 1
		end

		self.Debug_HitboxCache = bones
	end

	for _, hitbox in ipairs(self.Hitboxes) do
		local pos, ang = LocalToWorld(hitbox.Pos, hitbox.Ang, hitbox.Bone.Pos, hitbox.Bone.Ang)
		local col = self.Debug_HitboxCache[hitbox.Bone.Index]

		drawBox(pos, ang, hitbox.Mins, hitbox.Maxs, col)
	end
end

function ENT:DebugGait()
	for _, leg in ipairs(self.Legs) do
		for k, pos in ipairs({leg.Ground, leg.Pos, leg.Target}) do
			local screen = pos:ToScreen()

			local r = k == 1 and 255 or 0
			local g = k == 2 and 255 or 0
			local b = k == 3 and 255 or 0

			if screen.visible then
				cam.Start2D()
					surface.DrawCircle(screen.x, screen.y, 10, r, g, b)
				cam.End2D()
			end
		end

		if leg.Ground and leg.OldNormal then
			render.DrawLine(leg.Ground, leg.Ground + leg.OldNormal * 10, forward)
		end

		if leg.Pos and leg.Normal then
			render.DrawLine(leg.Pos, leg.Pos + leg.Normal * 10, right)
		end
	end
end

function ENT:DebugIK()
	for _, leg in ipairs(self.Legs) do
		leg.Solver(self, leg, true)
	end
end

function ENT:DebugTurrets()
	local tr = self:GetAimTrace()

	render.DrawLine(tr.StartPos, tr.HitPos, up, true)

	for _, bone in pairs(self.Bones) do
		local turret = bone.Turret

		if turret and not turret.NoDebug then
			local parent = bone.Parent
			local forwardAngle

			if parent then
				forwardAngle = parent.Ang
			else
				forwardAngle = self:GetMechAngles()
			end

			local ang = forwardAngle + self["Get" .. turret.NetworkVar](self)

			render.DrawLine(bone.Pos, bone.Pos + ang:Forward() * 56756, forward, true)
		end
	end
end

function ENT:DebugModules()
	for _, v in ipairs(self.Modules) do
		if IsValid(v.Entity) then
			v.Entity:DrawDebug()
		end
	end
end

function ENT:DrawDebug()
	for index, name in ipairs(methods) do
		local convar = convars[index]

		if convar:GetBool() and self["Debug" .. name] then
			self["Debug" .. name](self)
		end
	end
end

function ENT:PreDrawHUD()
	if self:IsDormant() then
		return
	end

	cam.Start3D()
		self:DrawDebug()
	cam.End3D()
end
