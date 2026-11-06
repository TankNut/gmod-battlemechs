AddCSLuaFile()

local function toWorldAng(bone, ang)
	return select(2, LocalToWorld(vector_origin, ang, bone.Pos, bone.Ang))
end

local function toLocalAxis(bone, axis)
	local pos = WorldToLocal(axis + bone.Pos, angle_zero, bone.Pos, bone.Ang)

	return pos
end

local function atan2(a, b)
	return math.deg(math.atan2(a, b))
end

local function icos(a, b, c)
	return math.deg(math.acos((a^2 + b^2 - c^2) / (2 * a * b)))
end

local skeleton = Color(191, 127, 255)
local footColor = Color(127, 0, 255)

function ENT:IK_2Seg_Humanoid(leg, drawDebug)
	local root = self:GetBone(leg.RootBone)
	local hip = self:GetBone(leg.Hip)
	local knee = self:GetBone(leg.Knee)
	local foot = self:GetBone(leg.Foot)

	if drawDebug then
		render.DrawLine(hip.Pos, knee.Pos, skeleton)

		if foot then
			local pos = foot.Pos + foot.Ang:Up() * leg.FootOffset

			render.DrawLine(knee.Pos, pos, skeleton)
			render.DrawLine(pos, foot.Pos, footColor)
		else
			render.DrawLine(knee.Pos, leg.Pos, skeleton)
		end

		return
	end

	local pos, ang = LocalToWorld(leg.Origin, leg.Rotation, root.Pos, root.Ang)
	ang.r = 0

	local base = {
		Pos = pos,
		Ang = ang
	}

	local target = leg.Pos

	if foot then
		local footAxis = toLocalAxis(base, leg.Normal)
		foot.Ang = toWorldAng(base, Angle(-atan2(footAxis.z, footAxis.x) + 90, 0, atan2(footAxis.z, footAxis.y) - 90))

		target = target + foot.Ang:Up() * leg.FootOffset
	end

	local localAxis = toLocalAxis(base, target - base.Pos)
	local temp = {Pos = Vector(base.Pos), Ang = toWorldAng(base, Angle(0, 0, atan2(localAxis.z, localAxis.y) + 90))}

	localAxis = toLocalAxis(temp, target - base.Pos)
	local distance = math.min(localAxis:Length(), leg.LengthA + leg.LengthB)

	hip.Pos = LocalToWorld(leg.Origin, angle_zero, root.Pos, root.Ang)

	if leg.Chicken then
		local pitch = atan2(localAxis.x, localAxis.z) + icos(distance, leg.LengthA, leg.LengthB)

		hip.Ang = toWorldAng(temp, Angle(pitch - 90, 0, 0))
		knee.Ang = toWorldAng(hip, Angle(icos(leg.LengthB, leg.LengthA, distance) + 180, 0, 0))
	else
		local pitch = atan2(-localAxis.x, localAxis.z) + icos(distance, leg.LengthA, leg.LengthB)

		hip.Ang = toWorldAng(temp, Angle(pitch - 90, 180, 180))
		knee.Ang = toWorldAng(hip, Angle(icos(leg.LengthB, leg.LengthA, distance), 180, 180))
	end

	knee.Pos = hip.Pos + hip.Ang:Forward() * leg.LengthA

	if foot then
		foot.Pos = knee.Pos + knee.Ang:Forward() * leg.LengthB + foot.Ang:Up() * -leg.FootOffset
	end
end
