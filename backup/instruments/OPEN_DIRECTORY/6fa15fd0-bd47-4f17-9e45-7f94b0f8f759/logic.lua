---------------------------------------------
--            Fuel Gauge Dual              --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_DO = user_prop_add_boolean("Dimming Overlay",false,"Enable dimming overlay?")
prop_is_left = user_prop_add_boolean("Left Tank",true,"Left or right tank.")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
if user_prop_get(prop_is_left) then
  --img_add_fullscreen("background_left.png")
  img_add_fullscreen("background_left.png")
else
  img_add_fullscreen("background_right.png")
end
img_needle = img_add("needle.png", 0, 0, 190, 280)

if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end


-----------------------------------------
-- Init: default visibility & rotation --
-----------------------------------------
local left		= 0
local right		= 0
local cur_left 	= 0
local cur_right	= 0
local speedl	= 0.5
local speedr	= 0.5
local factor	= 0.045

---------------------------------------------
--   Functions                             --
---------------------------------------------

function new_fuel(quan, bus_volts, fuel_L_AFL, fuel_R_AFL)

	fuel_L_XPL = var_cap(((quan[1]* 2.20462) / 6.0), 0, 26)
	fuel_R_XPL = var_cap(((quan[2]* 2.20462) / 6.0), 0, 26)
	
	fuel_left = fif(fuel_L_AFL > 0, fuel_L_AFL, fuel_L_XPL)
	fuel_right = fif(fuel_R_AFL > 0, fuel_R_AFL, fuel_R_XPL)

-- X-plane gives fuel in weight (pounds), so we have to divide by 6 lbs per gallon)
	if bus_volts[1] >= 10 then
		left = fuel_left
		right = fuel_right
	else
		left = 0
		right = 0
	end

end

function new_fuel_fsx(lefttank_FSX, righttank_FSX, lefttank_A2A, righttank_A2A, volts)

	lefttank = fif(lefttank_A2A > 0, lefttank_A2A, lefttank_FSX)
	righttank = fif(righttank_A2A > 0, righttank_A2A, righttank_FSX)

	if volts > 10 then
		left = lefttank
		right = righttank
	else
		left = 0
		right = 0
	end
end

function timer_callback()
    cur = fif(user_prop_get(prop_is_left) == true, left, right)
	img_rotate(img_needle , (cur * 2.28) - 29)
	
	
	if (cur_left < left) then
		diff = left - cur_left
		if (diff < 0.001) then
			speedl = 0
			cur_left = left
		else
			speedl = diff * factor
		end
		cur_left = cur_left + speedl
	elseif (cur_left > left) then
		diff = cur_left - left
		if (diff < 0.001) then
			speedl = 0
			cur_left = left
		else
			speedl = diff * factor
		end
		cur_left = cur_left - speedl
	end
	
	if (cur_right < right) then
		diff = right - cur_right
		if (diff < 0.001) then
			speedr = 0
			cur_right = right
		else
			speedr = diff * factor
		end
		cur_right = cur_right + speedr
	elseif (cur_right > right) then
		diff = cur_right - right
		if (diff < 0.001) then
			speedr = 0
			cur_right = right
		else
			speedr = diff * factor
		end
		cur_right = cur_right - speedr
	end
end
timer_start(0, 50, timer_callback)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe( "sim/cockpit2/fuel/fuel_quantity","FLOAT[9]",
					   "sim/cockpit2/electrical/bus_volts", "FLOAT[6]", 
					   "172/instruments/uni_fuel_L", "FLOAT", 
					   "172/instruments/uni_fuel_R", "FLOAT", new_fuel)

fsx_variable_subscribe("FUEL TANK LEFT MAIN QUANTITY", "gallons",
					   "FUEL TANK RIGHT MAIN QUANTITY", "gallons", 
					   "L:FuelLeftWingTank", "gallons",
					   "L:FuelRightWingTank", "gallons", 
					   "ELECTRICAL MAIN BUS VOLTAGE", "VOLTS", new_fuel_fsx)
---------------------------------------------
--   END                                   --
---------------------------------------------					   