--- map controller: show a centered, north-up map with position arrow for the current craft, centered on GPS coordinates
---
--- Inputs:
---   Numbers:
---     1. gps x
---     2. gps y
---     3. touch1 x
---     4. touch1 y
---     5. compass
---   Bools:
---     1. touch1 pressed
---     2. clear waypoints
---
--- Outputs:
---   Numbers:
---     1. number of waypoints
---     2. next waypoint x
---     3. next waypoint y
---     4. final waypoint x
---     5. final waypoint y
---   Bools:
---     1. waypoint reached (single tick activation)
---
--- Properties:
---   Numbers:
---     wptRadius: dist (m) within which we advance to the next GPS point


--- character dimensions
CH = 5
CW = 5

--- screen dimensions
W = 1
H = 1

--- current zoom level
zoom = 1
zoomFactor = 2
minZoom = zoomFactor ^ -3
maxZoom = zoomFactor ^ 4

--- borders of clickable zoom buttons; set on draw
lowY = 99999

--- whether or not the screen is currently being touched
touching = false

--- queue impl; see https://www.lua.org/pil/11.4.html
List = {}
function List.new ()
	return {first = 0, last = -1}
end

function List.pushright (list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popleft (list)
	local first = list.first
	if first > list.last then return nil end
	local value = list[first]
	list[first] = nil        -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.peekleft (list)
	if list.first > list.last then return nil end
	return list[list.first]
end

function List.peekright (list)
	if list.first > list.last then return nil end
	return list[list.last]
end

function List.window2 (list, callback)
	local left = list.first
	local right = left + 1
	while right <= list.last do
		callback(list[left], list[right])
		left = right
		right = right + 1
	end
end

function List.len(list)
	return list.last - list.first + 1
end

--- list of waypoints
waypoints = List.new()

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

	handleZoom()
	handleWaypoints()
end

function rotatePoint(x, y, degrees)
	theta = math.rad(degrees)
	sint = math.sin(theta)
	cost = math.cos(theta)
	local xp = x * cost - y * sint
	local yp = y * cost + x * sint
	return xp, yp
end

function handleZoom()
	if touchX ~= nil and touchY ~= nil then
		if touchY >= lowY then
			if touchX >= centerX - CW and touchX < centerX then
				zoom = clamp(zoom * zoomFactor, minZoom, maxZoom)
				nt()
			elseif touchX > centerX and touchX <= centerX + CW then
				zoom = clamp(zoom / zoomFactor, minZoom, maxZoom)
				nt()
			end
		end
	end
end

function clearWaypoints()
	waypoints = List.new()
	for o=2,5 do output.setNumber(o, 0) end
end

function handleWaypoints()
	local nxt = List.peekleft(waypoints)
	if nxt ~= nil then
		local dist = ((nxt.x - gpsx) ^ 2 + (nxt.y - gpsy) ^ 2) ^ 0.5
		if dist < property.getNumber("wptRadius") then
			List.popleft(waypoints)
			output.setBool(1, true)
		else
			output.setBool(1, false)
		end
	end

	if input.getBool(2) or List.len(waypoints) == 0 then --- clear waypoints list
		clearWaypoints()
	end

	if touchX ~= nil and touchY ~= nil then
		if touchY >= lowY - 1 and touchX <= CW then
			clearWaypoints()
			nt()
		elseif touchY < lowY or touchX < centerX - CW or touchX > centerX + CW	then
			local worldx, worldy = map.screenToMap(gpsx, gpsy, zoom, W, H, touchX, touchY)
			List.pushright(waypoints, {x = worldx, y = worldy})
			nt()
		end
	end

	output.setNumber(1, List.len(waypoints))
	local nxt = List.peekleft(waypoints)
	if nxt ~= nil then
		output.setNumber(2, nxt.x)
		output.setNumber(3, nxt.y)
	end
	local last = List.peekright(waypoints)
	if last ~= nil then
		output.setNumber(4, last.x)
		output.setNumber(5, last.y)
	end
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

function drawZoom()
	lowY = H - CH

	screen.setColor(0, 0, 0, 200)
	screen.drawRectF(centerX - CW, lowY, CW, CH)
	screen.drawRectF(centerX + 1, lowY, CW, CH)

	screen.setColor(255, 255, 255)
	screen.drawText(centerX - CW + 1, lowY, "-")
	screen.drawText(centerX + 2, lowY, "+")
end

function drawWaypoints()
	if List.len(waypoints) > 0 then
		--- line to next waypoint is magenta
		local nxt = List.peekleft(waypoints)
		local wptx, wpty = map.mapToScreen(gpsx, gpsy, zoom, W, H, nxt.x, nxt.y)

		screen.setColor(69,0,48,175)
		screen.drawLine(centerX, centerY, wptx, wpty)

		--- line between subsequent waypoints is white
		screen.setColor(96,96,96,175)
		List.window2(waypoints, function(left, right)
			lx, ly = map.mapToScreen(gpsx, gpsy, zoom, W, H, left.x, left.y)
			rx, ry = map.mapToScreen(gpsx, gpsy, zoom, W, H, right.x, right.y)
			screen.drawLine(lx, ly, rx, ry)
		end)

		--- clear waypoints button
		screen.setColor(0, 0, 0, 200)
		screen.drawRectF(0, lowY - 1, CW + 1, CH + 2)
		screen.setColor(255, 0, 0)
		screen.drawText(1, lowY, "X")
	end
end

function onDraw()
	W = screen.getWidth()
	H = screen.getHeight()

	centerX = W / 2
	centerY = H / 2
	screen_dimension = math.min(W, H)

    screen.drawMap(gpsx, gpsy, zoom)
    drawWaypoints()
    drawSelfArrow()
    drawZoom()
end
