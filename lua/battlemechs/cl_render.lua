function battlemechs:DrawWorldText(pos, text, noz)
	local screen = pos:ToScreen()

	if not screen.visible then
		return
	end

	cam.IgnoreZ(true)
	cam.Start2D()
		surface.SetFont("BudgetLabel")

		local w, h = surface.GetTextSize("BudgetLabel", text)

		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(screen.x - w * 0.5, screen.y - h * 0.5)

		surface.DrawText(text)
	cam.End2D()
	cam.IgnoreZ(false)
end

local tracerColor = Color(255, 255, 255)

-- Returns false if done rendering
function battlemechs:DrawTracer(startpos, endpos, velocity, length, scale, time, color)
	local dir = endpos - startpos
	local distance = dir:Length()
	dir:Normalize()

	-- Minimum length
	if distance <= 128 then
		return false
	end

	local lifetime = (distance + length) / velocity

	if time > lifetime then
		return false
	end

	local startDistance = velocity * time
	local endDistance = startDistance - length

	startDistance = math.Clamp(startDistance, 0, distance)
	endDistance = math.Clamp(endDistance, 0, distance)

	if startDistance == 0 and endDistance == 0 then
		return true
	end

	local offset = math.abs(startDistance - endDistance) / length

	local origin = EyePos()

	-- Is this backwards? I don't know
	local endPoint = startpos + dir * startDistance
	local startPoint = startpos + dir * endDistance

	local lineDir = endPoint - startPoint
	local viewDir = endPoint - origin

	local cross = lineDir:Cross(viewDir)
	cross:Normalize()

	tracerColor:Set(color or color_white)

	render.DrawBeam(startPoint, endPoint, scale * 2, 0, offset, tracerColor)

	tracerColor:SetBrightness(0.25)

	render.DrawBeam(startPoint, endPoint, scale * 4, 0, offset, tracerColor)

	return true
end
