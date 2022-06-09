--- map controller: show a centered, north-up map with position arrow for the current craft, centered on GPS coordinates
--- TODO: store, display a waypoint list; emit next waypoint and final waypoint

--- character dimensions
CH = 5
CW = 5

--- current zoom level
zoom = 1
zoomFactor = 2
minZoom = zoomFactor ^ -3
maxZoom = zoomFactor ^ 4

--- whether or not the screen is currently being touched
touching = false

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

--- nilize touch
function nt()
	touchX = nil
	touchY = nil
end

function onTick()
	if screen_dimension ~= nil and self_len == nil then
		self_len = clamp(screen_dimension / 10, 4, 100)
		self_width = self_len / 2
	end

	gpsx = goz(input.getNumber(1))
	gpsy = goz(input.getNumber(2))
	compass = input.getNumber(5)

	--- when touch pressed
	if not touching and input.getBool(1) then
		touchX = input.getNumber(3)
		touchY = input.getNumber(4)
	else
		nt()
	end
	touching = input.getBool(1)
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
	if gpsx ~= nil and gpsy ~= nil and self_width ~= nil then
		screen.setColor(0, 0, 0)
		screen.drawCircleF(centerX, centerY, clamp(self_width / 8, 1, 5))

		if compass ~= nil then
			ax, ay = rotatePoint(0, -self_width, compass)
			bx, by = rotatePoint(-self_width, self_width, compass)
			cx, cy = rotatePoint(self_width, self_width, compass)

			ax = ax + centerX
			ay = ay + centerY
			bx = bx + centerX
			by = by + centerY
			cx = cx + centerX
			cy = cy + centerY

			screen.drawLine(ax, ay, bx, by)
			screen.drawLine(ax, ay, cx, cy)
		end
	end
end

function handleZoom()
	lowY = screen.getHeight() - CH
	screen.setColor(0, 0, 0, 200)
	screen.drawRectF(centerX - CW, lowY, CW, CH)
	screen.drawRectF(centerX + 1, lowY, CW, CH)
	screen.setColor(255, 255, 255)
	screen.drawText(centerX - CW + 1, lowY, "-")
	screen.drawText(centerX + 2, lowY, "+")

	if touchX ~= nil and touchY ~= nil then
		if touchY >= lowY then
			if touchX >= centerX - CW and touchX < centerX then
				zoom = clamp(zoom * zoomFactor, minZoom, maxZoom)
				nt()
			elseif touchX >= centerX + 1 and touchX < centerX + 1 + CW then
				zoom = clamp(zoom / zoomFactor, minZoom, maxZoom)
				nt()
			end
		end
	end
end

function onDraw()
	centerX = screen.getWidth() / 2
	centerY = screen.getHeight() / 2
	screen_dimension = math.min(screen.getWidth(), screen.getHeight())

    screen.drawMap(gpsx, gpsy, zoom)
    drawSelfArrow()
    handleZoom()
end
