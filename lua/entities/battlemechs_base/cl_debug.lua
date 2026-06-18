local methods = {"Physics", "Bones", "Hitboxes", "Gait", "IK", "Turrets"}
local convars = {}

for index, name in ipairs(methods) do
	convars[index] = CreateClientConVar("battlemechs_debug_" .. string.lower(name), 0)
end

local physicsColor = Color(255, 191, 0)

local forward = Color(255, 0, 0)
local right =   Color(0, 255, 0)
local up =      Color(0, 0, 255)

local length = 10

local function drawBox(pos, ang, mins, maxs, color)
	local oldAlpha = color.a

	color.a = 255
	render.DrawWireframeBox(pos, ang, mins, maxs, color)

	color.a = 10
	render.SetColorMaterial()
	cam.IgnoreZ(true)
	render.DrawBox(pos, ang, mins, maxs, color)
	cam.IgnoreZ(false)

	color.a = oldAlpha
end

function ENT:DebugPhysics()
	drawBox(self:GetPos(), self:GetAngles(), self.Hull.Mins, self.Hull.Maxs, physicsColor)
end

function ENT:DebugBones()
	for name, bone in pairs(self.Bones) do
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Forward() * 10, forward)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Right() * 10, right)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Up() * 10, up)

		battlemechs:DrawWorldText(bone.Pos, name, true)
	end
end

function ENT:DebugHitboxes()
	if not self.Debug_HitboxCache then
		self.Debug_HitboxCache = {}

		local count = table.Count(self.Bones)
		local increment = 360 / count

		for i = 0, count - 1 do
			table.insert(self.Debug_HitboxCache, HSVToColor(i * increment, 0.5, 1))
		end
	end

	local i = 1

	for _, bone in pairs(self.Bones) do
		local col = self.Debug_HitboxCache[i]

		for _, hitbox in ipairs(bone.Hitboxes) do
			drawBox(hitbox:GetPos(), hitbox:GetAngles(), hitbox:GetHitboxMins(), hitbox:GetHitboxMaxs(), col)
		end

		i = i + 1
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
			render.DrawLine(leg.Ground, leg.Ground + leg.OldNormal * length, forward)
		end

		if leg.Pos and leg.Normal then
			render.DrawLine(leg.Pos, leg.Pos + leg.Normal * length, right)
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

		if turret and not (turret.Slave or turret.Torso) then
			local parent = self:GetBone(bone.Parent)
			local forwardAngle

			if parent then
				forwardAngle = parent.Ang
			else
				forwardAngle = self:GetAngles()
			end

			local ang = forwardAngle + self["Get" .. turret.NetworkVar](self)

			render.DrawLine(bone.Pos, bone.Pos + ang:Forward() * 56756, forward, true)
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
