AddCSLuaFile()

function ENT:InitMovement()
end

function ENT:TraceBBox(pos, dest, output)
	return util.TraceHull({
		start = pos,
		endpos = dest,
		filter = self,
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
		mins = self.Hull.Mins,
		maxs = self.Hull.Maxs,
		output = output
	})
end

local function ClipVelocity(_in, normal, out, overbounce, redirectCoeff)
	local angle = normal.z
	local blocked = 0x00

	-- Probably don't need to bit.bor here
	if angle > 0 then
		blocked = bit.bor(blocked, 0x01) -- Floor
	elseif angle == 0 then
		blocked = bit.bor(blocked, 0x02) -- Step/wall
	end

	local flBlocked = _in:Dot(normal)
	local backoff = flBlocked * overbounce

	for i = 1, 3 do
		out[i] = _in[i] - (normal[i] * backoff)
	end

	local adjust = out:Dot(normal)

	if adjust < 0 then
		out:Sub(normal * adjust)
	end

	if redirectCoeff > 0 then
		local len = out:Length()

		out:Mul((-1 * flBlocked * redirectCoeff + len) / len)
	end

	return blocked
end

local numbumps = 4
local MAX_CLIP_PLANES = 5

function ENT:TryMove(mv)
	local pm = {} -- Trace result

	local blocked, numplanes = 0, 0
	local planes = {}

	local original_velocity = Vector(mv.Velocity)
	local primal_velocity = Vector(mv.Velocity)

	local allFraction = 0
	local time_left = FrameTime()

	for bumpcount = 1, numbumps do
		if mv.Velocity:Length() == 0 then
			break
		end

		self:TraceBBox(mv.Origin, mv.Origin + mv.Velocity * time_left, pm)

		allFraction = allFraction + pm.Fraction

		if pm.AllSolid then
			mv.Velocity:Zero()
			return 4
		end

		if pm.Fraction > 0 then
			if pm.Fraction == 1 then
				local stuck = self:TraceBBox(pm.HitPos, pm.HitPos)

				if stuck.StartSolid or stuck.Fraction != 1 then
					mv.Velocity:Zero()
					break
				end
			end

			mv.Origin = pm.HitPos
			original_velocity:Set(mv.Velocity)
			numplanes = 0
		end

		if pm.Fraction == 1 then
			break
		end

		-- MoveHelper()->AddToTouched(pm, mv->m_vecVelocity)

		if pm.HitNormal.z > 0.7 then
			blocked = bit.bor(blocked, 0x01) -- Floor
		elseif pm.HitNormal.z == 0 then
			blocked = bit.bor(blocked, 0x02) -- Step/wall
		end

		time_left = time_left - (time_left * pm.Fraction)

		if numplanes >= MAX_CLIP_PLANES then
			mv.Velocity:Zero()
			break
		end

		planes[numplanes] = Vector(pm.HitNormal)
		numplanes = numplanes + 1

		-- player->GetMoveType() == MOVETYPE_WALK && player->GetGroundEntity() == NULL
		if numplanes == 1 and false then
			local new_velocity = Vector()

			ClipVelocity(original_velocity, planes[0], new_velocity, 1, 0)

			mv.Velocity:Set(new_velocity)
			original_velocity:Set(new_velocity)
		else
			for i = 0, numplanes - 1 do
				ClipVelocity(original_velocity, planes[i], mv.Velocity, 1, 0)

				local _j = 0

				for j = 0, numplanes - 1 do
					_j = j

					if j != i and mv.Velocity:Dot(planes[j]) < 0 then
						break
					end
				end

				if _j == numplanes - 1 then
					break
				end
			end

			if i == numplanes then
				if numplanes != 2 then
					mv.Velocity:Zero()
					break
				end

				local dir = planes[0]:Cross(planes[1])
				dir:Normalize()

				mv.Velocity:Set(dir * dir:Dot(mv.Velocity))
			end

			if mv.Velocity:Dot(primal_velocity) <= 0 then
				mv.Velocity:Zero()
				break
			end
		end
	end

	if allFraction == 0 then
		mv.Velocity:Zero()
	end

	return blocked
end

local DIST_EPSILON = 0.03125

function ENT:StepMove(mv)
	local endPos = Vector()

	local pos = Vector(mv.Origin)
	local vel = Vector(mv.Velocity)

	self:TryMove(mv)

	local downPos = Vector(mv.Origin)
	local downVel = Vector(mv.Velocity)

	-- Reset original values
	mv.Origin:Set(pos)
	mv.Velocity:Set(vel)

	-- Move up to step over obstacles
	endPos:Set(mv.Origin)
	endPos.z = endPos.z + mv.StepSize + DIST_EPSILON

	local tr = self:TraceBBox(mv.Origin, endPos)

	if not tr.StartSolid and not tr.AllSolid then
		mv.Origin:Set(tr.HitPos)
	end

	self:TryMove(mv)

	-- Try to move back down
	endPos:Set(mv.Origin)
	endPos.z = endPos.z - mv.StepSize + DIST_EPSILON

	self:TraceBBox(mv.Origin, endPos, tr)

	if tr.HitNormal.z < 0.7 then
		mv.Origin:Set(downPos)
		mv.Velocity:Set(downVel)

		mv.StepHeight = mv.StepHeight + math.max(mv.Origin.z - pos.z, 0)

		return
	end

	if not tr.StartSolid and not tr.AllSolid then
		mv.Origin:Set(tr.HitPos)
	end

	-- Copy this origin to up
	local upPos = Vector(mv.Origin)

	local downDist = (downPos - pos):Length2D()
	local upDist = (upPos - pos):Length2D()

	if downDist > upDist then
		mv.Origin:Set(downPos)
		mv.Velocity:Set(downVel)
	else
		mv.Velocity.z = downVel.z
	end

	mv.StepHeight = mv.StepHeight + math.max(mv.Origin.z - pos.z, 0)
end

function ENT:StayOnGround(mv)
	local start = Vector(mv.Origin)
	local endpos = Vector(mv.Origin)

	start.z = start.z + 2 -- Magic number?
	endpos.z = endpos.z - mv.StepSize

	local tr = self:TraceBBox(mv.Origin, start)
	start = tr.HitPos

	self:TraceBBox(start, endpos, tr)

	if tr.Fraction > 0 and tr.Fraction < 1 and not tr.StartSolid and tr.HitNormal.z >= 0.7 then
		local delta = math.abs(mv.Origin.z - tr.HitPos.z)

		if delta > 0.5 * DIST_EPSILON then
			mv.Origin:Set(tr.HitPos)
		end
	end
end

local sv_gravity = GetConVar("sv_gravity")

function ENT:ApplyGravity(mv)
	mv.Velocity.z = mv.Velocity.z - mv.Gravity * sv_gravity:GetFloat() * 0.5 * FrameTime()
end

function ENT:ProcessInputs(mv)
	local ply = self:GetDriver()

	if ply:IsValid() then
		local dir = Vector()

		if ply:KeyDown(IN_FORWARD) then dir.x = dir.x + 1 end
		if ply:KeyDown(IN_BACK) then dir.x = dir.x - 1 end
		if ply:KeyDown(IN_MOVELEFT) then dir.y = dir.y + 1 end
		if ply:KeyDown(IN_MOVERIGHT) then dir.y = dir.y - 1 end

		dir:Rotate(ply:EyeAngles())
		dir.z = 0
		dir:Normalize()

		local speed = ply:KeyDown(IN_SPEED) and 500 or 100

		mv.Velocity:Add(dir * speed)
	end
end

function ENT:CreateMove()
	return {
		Origin = self:GetPos(),
		Velocity = self:GetAbsVelocity(),
		StepSize = 18,
		Gravity = 1,

		StickToGround = true,

		-- Output
		StepHeight = 0
	}
end

function ENT:FinishMove(mv)
	self:SetPos(mv.Origin)
	self:SetAbsVelocity(mv.Velocity)
end

function ENT:ProcessMovement()
	local mv = self:CreateMove()

	self:ProcessInputs(mv)

	self:ApplyGravity(mv) -- Gravity is applied in two steps, I'm not entirely sure why
	self:StepMove(mv)

	if mv.StickToGround then
		self:StayOnGround(mv)
	end

	self:ApplyGravity(mv)
	self:FinishMove(mv)
end

function ENT:PlayerPostThink()
	self:ProcessMovement()
end

-- INIT

	-- Get current velocity
	-- Base velocity(?)

-- PRE MOVE

	-- Get input

	-- Check stuck
	-- Check ground entity/water level

-- MOVE

	-- Add gravity to velocity
	-- Check for jumping (jump packs?)
	-- Friction if grounded

-- WALK MOVE

	-- Get wish velocity/dir/speed
	-- Accelerate
	-- Try direct hull trace
	-- If direct succeeded, StayOnGround and exit
	-- If not, StepMove
	-- StayOnGround

-- STEP MOVE

	-- 

-- AIR MOVE

	-- Get wish velocity
	-- Custom air control multiplier?

-- TRY MOVE

-- FINISH MOVEMENT
	-- Set (abs) origin and velocity
	-- Set angles

	-- Process impacts
