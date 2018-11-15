---------------------------------------------
--           Altimeter                     --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background Display",true,"Hide background")
prop_DO = user_prop_add_boolean("Dimming Overlay",false,"Use Dimming overlay")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
setdisk = img_add("altimeterCard.png", 15, 0, 512, 512)
if user_prop_get(prop_BG) == false then
	img_add_fullscreen("altimeter.png")
else
	img_add_fullscreen("altimeterwBG.png")
end	
needle_10000 = img_add_fullscreen("altimeterdisc.png")
needle_1000 = img_add_fullscreen("needle1000.png")
needle_100 = img_add_fullscreen("needle100.png")
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end
img_add("altknobshadow.png",31,400,85,85)

---------------------------------------------
--   Functions                             --
---------------------------------------------
function new_alt(alt)
	if alt == -1 then
		xpl_command("sim/instruments/barometer_down")
		fsx_event("KOHLSMAN_DEC")
	elseif alt == 1 then
		xpl_command("sim/instruments/barometer_up")
		fsx_event("KOHLSMAN_INC")
	end
end

function new_altitude(altitude, pressure)
	k = (altitude/10000)*36
  h = ( (altitude - math.floor(altitude/10000)*10000)/1000 )*36
  t = ( altitude - math.floor(altitude/10000)*10000 )*0.36
    
  img_rotate(needle_10000, k)
  img_rotate(needle_1000, h)    
  img_rotate(needle_100, t) 
    
  kk = k/3.6
  hh = h/36
  tt = t/0.36-hh*1000
    
	barset = var_cap(pressure, 29.1, 30.7)
	
	img_rotate(setdisk, (((barset - 29.1) * 160 / 1.6) * -1)+0.6)
end

---------------------------------------------
--   Controls Add                          --
---------------------------------------------
dial_alt = dial_add("altknob.png", 31, 400, 85, 85, new_alt)
dial_click_rotate(dial_alt,1)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------

xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/altitude_ft_pilot", "FLOAT",
					  "sim/cockpit/misc/barometer_setting", "FLOAT", new_altitude)
fsx_variable_subscribe("INDICATED ALTITUDE", "Feet",
					   "KOHLSMAN SETTING HG", "inHg", new_altitude)

---------------------------------------------
-- END       Altimeter                     --
---------------------------------------------					   