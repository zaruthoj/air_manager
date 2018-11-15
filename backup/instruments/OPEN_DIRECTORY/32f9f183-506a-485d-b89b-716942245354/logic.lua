---------------------------------------------
--           Tachometer                    --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_DO = user_prop_add_boolean("Dimming Overlay",false,"Enable dimming overlay?")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
--   RPM ticker / hours built first        --
--   then overlayed with gauge             --
---------------------------------------------
img_add_fullscreen("RPMhours.png")

function value_callback(item_nr)
  return tostring(item_nr)
end
 
-- This will generate 7 text_objects vertically. Text objects are 200x100.
tach0_id = running_txt_add_ver(240,134,10,80,37,value_callback,"font:arial.ttf; size:36px; color: black; halign: right;")
viewport_rect(tach0_id,300,324,80,36)
tach1_id = running_txt_add_ver(238,134,10,50,37,value_callback,"font:arial.ttf; size:36px; color: white; halign: right;")
viewport_rect(tach1_id,260,324,80,36)
tach2_id = running_txt_add_ver(204,134,10,50,37,value_callback,"font:arial.ttf; size:36px; color: white; halign: right;")
viewport_rect(tach2_id,227,324,80,36)
tach3_id = running_txt_add_ver(171,134,10,50,37,value_callback,"font:arial.ttf; size:36px; color: white; halign: right;")
viewport_rect(tach3_id,194,324,80,36)
tach4_id = running_txt_add_ver(138,134,10,50,37,value_callback,"font:arial.ttf; size:36px; color: white; halign: right;")
viewport_rect(tach4_id,162,324,80,36)

-- Ticker
running_img_tick  = running_img_add_ver("RPMticker.png",332,200,4,17,67)
running_img_move_carot(running_img_tick, 0)
img_add("RPMhoursshadow.png", 162, 324, nil, nil)

-- Images

img_add_fullscreen("RPM.png")

img_needle = img_add_fullscreen ("RPMneedle.png")
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

---------------------------------------------
--   Init                                  --
---------------------------------------------
local gbl_fsx_hours = 0
img_rotate(img_needle, -125)

---------------------------------------------
--   Functions                             --
---------------------------------------------
function PT_rpm(rpm_XPL, rpm_AFL)
	rpm = fif(rpm_AFL > 0, rpm_AFL, rpm_XPL[1])
	img_rotate(img_needle, rpm * (250/3490) - 125)
end

function rpm_fsx(rpma2a, rpmfsx)
  if rpma2a > 0 then
    rpm = rpma2a
  else
    rpm = rpmfsx
  end
    
  rpm = var_cap(rpm, 0 , 3500)
	img_rotate(img_needle, rpm * (250/3500) - 125)

end

function flight_time_fsx(hours, counter)

	-- Make FSX default timer global
	gbl_fsx_hours = hours

	if counter * 12960000 > 0 then
		seconds = counter * 12960000
	else
		seconds = hours * 60 * 60
	end
	
	flight_time(seconds, 0)
	
end

function flight_time(time_sec_XPL, time_sec_AFL)
	
	time_sec = fif(time_sec_AFL > 0, time_sec_AFL, time_sec_XPL)

    -- minutes
    minutes = time_sec / 60
    
    -- hours
    hours = minutes / 60

	digit0 = math.floor(hours * 10) % 10 
	digit1 = math.floor(hours) % 10
	digit2 = math.floor(hours/10) % 10	
	digit3 = math.floor(hours/100) % 10
	digit4 = math.floor(hours/1000) % 10

	whole = digit1 + (digit2*10) + (digit3*100) + (digit4*1000)
	digit0 = (hours - whole) * 10
	
	if (digit0 > 9.0) then
		part = digit0 - math.floor(digit0)
		digit1 = digit1 + part
	end
	
	if (digit1 > 9.0 and digit0 > 9.0) then
		digit2 = digit2 + part
	end
	
	if (digit2 > 9.0 and digit0 > 9.0) then
		digit3 = digit3 + part
	end
	
	if (digit3 > 9.0 and digit0 > 9.0) then
		digit4 = digit4 + part
	end
	
	tick = ((hours-whole)*10000)%10

	running_txt_move_carot(tach0_id, digit0)
	running_txt_move_carot(tach1_id, digit1)
	running_txt_move_carot(tach2_id, digit2)
	running_txt_move_carot(tach3_id, digit3)
	running_txt_move_carot(tach4_id, digit4)

	-- Move ticker according default or add-on aircraft time
	tick_time = fif(gbl_fsx_hours > 0, gbl_fsx_hours, time_sec)
	running_img_move_carot(running_img_tick, tick_time / 18)

end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe("sim/cockpit2/engine/indicators/prop_speed_rpm", "FLOAT[8]",
					  "172/engine/engine_rpm", "FLOAT", PT_rpm)
xpl_dataref_subscribe("sim/time/hobbs_time", "FLOAT",
					  "172/instruments/hobbs_time_total", "FLOAT", flight_time)

fsx_variable_subscribe("L:Eng1_RPM", "RPM",
                       "GENERAL ENG RPM:1", "rpm", rpm_fsx)
fsx_variable_subscribe("GENERAL ENG ELAPSED TIME:1", "hours",
					   "L:Counter1Hours", "hours", flight_time_fsx)
					   
---------------------------------------------
-- END                                     --
---------------------------------------------					   