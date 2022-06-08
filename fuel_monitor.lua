--- These constants are approximate; they can vary in real life.
--- Hopefully the game physics locks internal time so we experience
--- in-game slowdowns instead of random high consumption moments.
TICKS_PER_SECOND = 60
SECONDS_PER_TICK = 1 / TICKS_PER_SECOND
BOX_HEIGHT = 6
MAXN = 9999

max_fuel = 0
max_charge = 0

function maxclamp(x)
	if x > MAXN then x = MAXN end
	return x
end

function onTick()
	old_fuel = fuel
    fuel = input.getNumber(1)
	if old_fuel == nil then old_fuel = fuel end
	max_fuel = math.max(max_fuel, fuel)
	fuel_fraction = fuel / max_fuel

    fuel_consumption = old_fuel - fuel
    fuel_per_minute = maxclamp(fuel_consumption * TICKS_PER_SECOND * 60)

    minutes_remaining = maxclamp(fuel / fuel_per_minute)
    int_minutes_remaining, seconds_remaining = math.modf(minutes_remaining)
    seconds_remaining = math.tointeger(math.floor(seconds_remaining * 60))

    output.setNumber(1, fuel)
    output.setNumber(2, fuel_fraction)
    output.setNumber(3, fuel_per_minute)
    output.setNumber(4, minutes_remaining)
    output.setNumber(5, int_minutes_remaining)
    output.setNumber(6, seconds_remaining)

    old_charge = charge
    charge = input.getNumber(11)
    if old_charge == nil then old_charge = charge end
    max_charge = math.max(max_charge, charge)
    charge_fraction = charge / max_charge

    charge_consumption = old_charge - charge
    charge_per_minute = maxclamp(charge_consumption * TICKS_PER_SECOND * 60)

    charge_minutes_remaining = maxclamp(charge / charge_per_minute)
    int_charge_minutes_remaining, charge_seconds_remaining = math.modf(charge_minutes_remaining)
    charge_seconds_remaining = math.tointeger(math.floor(charge_seconds_remaining * 60))

    output.setNumber(11, charge)
    output.setNumber(12, charge_fraction)
    output.setNumber(13, charge_per_minute)
    output.setNumber(14, charge_minutes_remaining)
    output.setNumber(15, int_charge_minutes_remaining)
    output.setNumber(16, charge_seconds_remaining)
end

function halfline()
	v = v + (BOX_HEIGHT / 2)
end

function lf()
	v = v + BOX_HEIGHT
end

function textPair(left, right)
	screen.drawText(0, v, left)
	screen.drawText(c2, v, right)
	lf()
end

--- create a bar graph spanning the screen with the given single-character label
function barFraction(label, fraction)
	screen.drawText(0, v, label)
	screen.setColor(0, 64, 0)
	local avail_width = w - BOX_HEIGHT
	local fill_width = math.floor(fraction * avail_width)
	local rest_width = avail_width - fill_width
	screen.drawRectF(BOX_HEIGHT, v, fill_width, BOX_HEIGHT - 1)
	screen.setColor(20, 20, 20)
	screen.drawRectF(BOX_HEIGHT + fill_width, v, rest_width, BOX_HEIGHT - 1)
	screen.setColor(255, 255, 255)
	lf()
end

--- this can handle drawing on any screen, but works best with at least 2x1
function onDraw()
	w = screen.getWidth()
	h = screen.getHeight()

	if fuel_label == nil then
		if w <= 32 then
			fuel_label = "F"
			rate_label = "R"
			rate_format = "%.1f"
			endurance_label = "E"
			endurance_format = "%2u:%02u"
			charge_label = "C"
			w2 = BOX_HEIGHT
		elseif w <= 64 then
			fuel_label = "Fuel"
			rate_label = "Rate"
			rate_format = "%.1f/m"
			endurance_label = "End."
			endurance_format = "%3u:%02u"
			charge_label = "Chg."
			w2 = math.floor(w / 3)
		else
			fuel_label = "Fuel"
			rate_label = "Rate"
			rate_format = "%.1f/m"
			endurance_label = "Endure."
			endurance_format = "%3u:%02u"
			charge_label = "Charge"
			w2 = math.floor(w / 2)
		end
	end

	c2 = w2 + 1
	v = 0

	textPair(fuel_label, fuel)
	textPair(rate_label, string.format(rate_format, fuel_per_minute))
	textPair(endurance_label, string.format(endurance_format, int_minutes_remaining, seconds_remaining))

	halfline()

	textPair(charge_label, charge)
	textPair(rate_label, string.format(rate_format, -charge_per_minute))

	if h > 32 then
		textPair(endurance_label, string.format(endurance_format, int_charge_minutes_remaining, charge_seconds_remaining))
		halfline()

		barFraction("F", fuel_fraction)
		barFraction("C", charge_fraction)
	end
end
