-- Turn coordinator --
-- Add images --
img_add_fullscreen("turncoback.png")
img_ball = img_add("turncoball.png", 132, 182, 36, 49)
img_needle = img_add_fullscreen("turnconeedle.png")
img_add_fullscreen("turncofront.png")

-- Functions --
function new_turn_xpl(turnrate, slip)
-- Turn indicator standard rate (one) turn 
	img_rotate(img_needle, var_cap(turnrate, -90, 90) * 0.62)

-- Slip indicator
 	slip = var_cap(slip, -7, 7)
	slip_rad = math.rad(slip * 0.75)
	
	x = - (750 * math.sin(slip_rad))
	y = (750 * math.cos(slip_rad))
	
    move(img_ball, x + 132, y - 568, nil, nil)
	img_rotate(img_ball, slip * 0.41)
end

function new_turn_fsx(turnrate, slip)

	new_turn_xpl(turnrate * -670, slip * -230)
	
end

xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/turn_rate_heading_deg_pilot", "FLOAT",
					  "sim/cockpit2/gauges/indicators/slip_deg", "FLOAT", new_turn_xpl)
fsx_variable_subscribe("TURN INDICATOR RATE", "Radians per second", 
					   "INCIDENCE BETA", "Radians", new_turn_fsx)