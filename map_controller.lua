--- map controller: show a centered, north-up map with position arrow for the current craft, centered on GPS coordinates
--- TODO: store, display a waypoint list; emit next waypoint and final waypoint
--- TODO: on-screen zoom

--- current zoom level
zoom = 1

--- constrain x to be between low and high
function clamp(x, low, high)
	if x < low then
		x = low
	elseif	x > high then
		x = high
	end
	return x
end

--- get or zero
function goz(t)
	if t == nil then t = 0 end
	return t
end

function onTick()
	if screen_dimension ~= nil and self_len == nil then
		self_len = clamp(screen_dimension / 10, 4, 100)
		self_width = self_len / 2
		print(self_len, self_width)
	end

	gpsx = goz(input.getNumber(1))
	gpsy = goz(input.getNumber(2))
	compass = goz(input.getNumber(3))
end

function rotatePoint(x, y, degrees)
	theta = math.rad(degrees)
	sint = math.sin(theta)
	cost = math.cos(theta)
	local xp = x * cost - y * sint
	local yp = y * cost + x * sint
	return xp, yp
end

function drawSelfArrow()
	if gpsx ~= nil and gpsy ~= nil and compass ~= nil and self_width ~= nil then
		centerX = screen.getWidth() / 2
		centerY = screen.getHeight() / 2
		ax, ay = rotatePoint(0, -self_width, compass)
		bx, by = rotatePoint(-self_width, self_width, compass)
		cx, cy = rotatePoint(self_width, self_width, compass)

		ax = ax + centerX
		ay = ay + centerY
		bx = bx + centerX
		by = by + centerY
		cx = cx + centerX
		cy = cy + centerY

		screen.setColor(0, 0, 0)
		screen.drawLine(ax, ay, bx, by)
		screen.drawLine(ax, ay, cx, cy)
		screen.drawCircleF(centerX, centerY, clamp(self_width / 8, 1, 5))
	end
end

function onDraw()
	screen_dimension = math.min(screen.getWidth(), screen.getHeight())
    screen.drawMap(gpsx, gpsy, zoom)
    drawSelfArrow()
end
