---------------------------------------------
--         Turn Coordinator                --
-- Modification of Jason Tatum's original  --
--                   Turn & Balance gauge  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------
---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background Display",true,"Display background?")
prop_DO = user_prop_add_boolean("Dimming Overlay",false,"Enable dimming overlay?")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
if user_prop_get(prop_BG) == false then
	img_add_fullscreen("turnslip.png")
else
	img_add_fullscreen("turnslipwBG.png")
end	
img_flag     		= img_add_fullscreen("turnslipflag.png")
img_plane       = img_add("turnslipplane.png",0,0,512,512)
img_ball        = img_add("turnslipball.png", 229,327,53,53)
img_bg_bubble   = img_add_fullscreen("turnslipbubble.png")
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

---------------------------------------------
--   Init                                  --
---------------------------------------------

---------------------------------------------
--   Functions                             --
---------------------------------------------
function new_ball_deflection(slip)
	slip = var_cap(slip, -8.1, 8.1)
	slip_rad = math.rad(slip * 1.6)
	x = (0 * math.cos(slip_rad)) - (482 * math.sin(slip_rad))
	y = (0 * math.sin(slip_rad)) + (482 * math.cos(slip_rad))
	move(img_ball, x + 230,y - 155,nil,nil)
	
end

function new_turnrate(roll)
	roll = var_cap(roll, -45, 45)
	img_rotate(img_plane, roll)
end

function new_ball_deflection_fsx(slip)
	slip = slip * -5.5
	new_ball_deflection(slip)
end

function new_battery(battery)
	visible(img_flag, battery[1] == 0)
end

function new_battery_fsx(busvolts)
	visible(img_flag, busvolts < 6)
end

function new_turnrate_fsx(roll)
	roll = roll * 400
	new_turnrate(roll)
end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/slip_deg", "FLOAT", new_ball_deflection)
xpl_dataref_subscribe("sim/flightmodel/misc/turnrate_roll", "FLOAT", new_turnrate)
xpl_dataref_subscribe("sim/cockpit/electrical/battery_array_on", "INT[8]", new_battery)

fsx_variable_subscribe("TURN COORDINATOR BALL", "Position", new_ball_deflection_fsx)
fsx_variable_subscribe("TURN INDICATOR RATE", "Radians", new_turnrate_fsx)
fsx_variable_subscribe("ELECTRICAL MAIN BUS VOLTAGE", "volts", new_battery_fsx)

---------------------------------------------
-- END       Turn & Slip                   --
---------------------------------------------							   					   