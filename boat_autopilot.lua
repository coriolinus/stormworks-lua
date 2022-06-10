--- Boat Autopilot
---
--- When waypoints are present, steer a boat towards the next waypoint.
--- When active but waypoints are not present, engage stationkeeping mode: attempt to
--- remain stationary, and when drifting beyond a threshold, return to that point.
---
--- input:
---   Numbers:
---     1. gps x
---     2. gps y
---     3. touch1 x
---     4. touch1 y
---     5. compass (degrees)
---     6. throttle in
---     7. steering in
---     11. number of waypoints
---     12. next waypoint x
---     13. next waypoint y
---   Bools:
---     1. touch1 pressed
---     2. toggle active (each tick, use a threshold detector)
---
--- Outputs:
---   Numbers:
---     1. speed (knots)
---     2. dist to next waypoint (km)
---     3. dist to next waypoint (nm)
---     4. compass heading to next waypoint (degrees)
---     5. relative bearing to next waypoint (degrees)
---     6. throttle out
---     7. steering out
---     8. integer minutes to next waypoint
---     9. integer seconds to next waypoint
---   Bools:
---     1. engaged (autopilot is on)
---     2. cruise (autopilot has an explicit next waypoint)
---
--- Properties:
---   Numbers:
---     driftRadius: dist (m) within which to drift before attempting to return to stationkeeping
---

--- tick timers for interacting with clock time
TICKS_PER_SECOND = 60
TICKS_PER_SLOW_UPDATE = TICKS_PER_SECOND / 2

--- counter to make certain calculations more stable
counter = 0

--- whether or not the autopilot is active and should attempt to navigate
engaged = false

--- whether or not the autopilot is responding to user waypoints (cruise) or is in stationkeeping mode
cruise = false

--- where the autopilot is trying to take the boat
target = {x = 0, y = 0}

--- position tracking
veryold = {x = 0, y = 0}
old = {x = 0, y = 0}
gps = {x = 0, y = 0}

--- whether or not the screen is currently being touched
touching = false

--- properties
driftRadius = property.getNumber("driftRadius")


--- constrain x to be between low and high
function clamp(x, low, high)
	if x < low then
		x = low
	elseif	x > high then
		x = high
	end
	return x
end

--- nilize touch
function nt()
	touchX = nil
	touchY = nil
end

--- toggle engaged mode
function toggleEngaged()
	engaged = not engaged
	--- enable stationkeeping at the current location
	if engaged and not cruise then
		target.x = gpsx
		target.y = gpsy
	end
end

function handleinput()
	old = gps
	if counter == 0 then veryold = gps end
	gps = {x = input.getNumber(1), y = input.getNumber(2)}
	compass = input.getNumber(5)
	throttleIn = input.getNumber(6)
	steeringIn = input.getNumber(7)
	cruise = input.getNumber(11) > 0
	if cruise then
		target.x = input.getNumber(12)
		target.y = input.getNumber(13)
	end
	if not touching and input.getBool(1) then
		touchX = input.getNumber(3)
		touchY = input.getNUmber(4)
	else
		nt()
	end
	if input.getBool(2) then
		toggleEngaged()
	end
end

function dist(a, b)
	return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) ^ 0.5
end

function handleMathOutputs()
	--- 1. speed (knots)
	traveled = dist(gps, old)
	speed_meter_per_second = traveled * TICKS_PER_SECOND
	output.setNumber(1, speed_meter_per_second * 1.94384)
	--- 2. dist to next waypoint (km)
	distM = dist(gps, target)
	output.setNumber(2, distM / 1000)
	--- 3. dist to next waypoint (nm)
	output.setNumber(3, distM / 1852)
	--- 4. compass heading to next waypoint
	heading = math.deg(math.atan(target.y - gps.y, target.x - gps.x)) % 360
	output.setNumber(4, heading)
	--- 5. relative bearing to next waypoint
	bearing = (heading - compass) % 360
	if bearing > 180 then bearing = bearing - 360 end
	output.setNumber(5, bearing)

	if counter == (-1 % TICKS_PER_SLOW_UPDATE) then
		local long_travel = dist(gps, veryold)
		local long_speed = long_travel * TICKS_PER_SLOW_UPDATE
		eta_seconds = distM / long_speed
		--- 8. integer minutes to next waypoint
		eta_int_minutes = clamp(math.floor(eta_seconds / 60), 0, 999)
		output.setNumber(8, eta_int_minutes)
		--- 9. integer seconds to next waypoint
		eta_int_seconds = math.floor(eta_seconds % 60)
		if eta_int_seconds ~= eta_int_seconds then
			--- nan
			eta_int_seconds = 99
		end
		output.setNumber(9, eta_int_seconds)
	end

	--- 1. engaged (autopilot is on)
	output.setBool(1, engaged)
	--- 2. cruise (autopilot has an explicit next waypoint)
	output.setBool(2, cruise)
end

function handleCruise()
	--- TODO

	--- 6. throttle out
	--- 7. steering out
end

function handleStationkeeping()
	-- TODO

	--- 6. throttle out
	--- 7. steering out
end

function passthrough()
	--- 6. throttle out
	output.setNumber(6, throttleIn)
	--- 7. steering out
	output.setNumber(7, steeringIn)
end

function onTick()
	devPosition() -- REMOVE THIS FROM THE REAL THING

	--- update the counter, so we can do slow updates only if it is 0
	counter = (counter + 1) % TICKS_PER_SLOW_UPDATE
	handleinput()
	handleMathOutputs()
	if engaged then
		if cruise then
			handleCruise()
		else
			handleStationkeeping()
		end
	else
		passthrough()
	end
end

--- DO NOT INCLUDE THIS IN THE VEHICLE
theta = 0
thetastep = math.pi / TICKS_PER_SECOND / 2
function devPosition()
	theta = theta + thetastep
	local x = 500 * math.sin(theta)
	local y = 500 * math.cos(theta)
	local c = (math.deg(theta) + 90) % 360
	devinput.setNumber(1, x)
	devinput.setNumber(2, y)
	devinput.setNumber(5, c)
end
