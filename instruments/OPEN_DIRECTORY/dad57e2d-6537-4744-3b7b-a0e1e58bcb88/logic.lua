---------------------------------------------
--           Airspeed Indicator            --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background Display",true,"Display background")
prop_DO = user_prop_add_boolean("Dimming Overlay",false,"Use Dimming overlay")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
as_card = img_add_fullscreen("asi_tas.png")
img_add_fullscreen("asi.png")
as_needle =  img_add("needle.png",0,0,512,512)
img_add("airknobshadow.png",31,400,85,85)
card = 0
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end
--img_add_fullscreen("scratches.png")
---------------------------------------------
--   Functions                             --
---------------------------------------------
function new_speed(speed)
	--speed = speed * 1.15078
	speed = var_cap(speed, 0, 190)

	if speed >= 180 then
		img_rotate(as_needle,335.4 + ((speed-180)*2.46))
	elseif speed >= 170 then
		img_rotate(as_needle,309.8 + ((speed-170)*2.56))
	elseif speed >= 160 then
		img_rotate(as_needle,283.1 + ((speed-160)*2.67))
	elseif speed >= 150 then
		img_rotate(as_needle,255.9 + ((speed-150)*2.72))
	elseif speed >= 140 then
		img_rotate(as_needle,229.7 + ((speed-140)*2.62))
	elseif speed >= 130 then
		img_rotate(as_needle,204.8 + ((speed-130)*2.49))
	elseif speed >= 120 then
		img_rotate(as_needle,181.2 + ((speed-120)*2.36))
	elseif speed >= 110 then
		img_rotate(as_needle,156.9 + ((speed-110)*2.43))
	elseif speed >= 100 then
		img_rotate(as_needle,132.2 + ((speed-100)*2.46))
	elseif speed >= 90 then
		img_rotate(as_needle,111.1 + ((speed-90)*2.12))
	elseif speed >= 80 then
		img_rotate(as_needle,90 + ((speed-80)*2.11))
	elseif speed >= 70 then
		img_rotate(as_needle,71.5 + ((speed-70)*1.85))
	elseif speed >= 60 then
		img_rotate(as_needle,54.5 + ((speed-60)*1.7))
	elseif speed >= 50 then
		img_rotate(as_needle,38 + ((speed-50)*1.65))
	elseif speed >= 40 then
		img_rotate(as_needle,23 + ((speed-40)*1.5))
	else
		img_rotate(as_needle, (speed*0.575))
	end
		
end

function new_speed_fsx(speed_FSX, speed_A2A)

	speed = fif(speed_A2A > 0, speed_A2A, speed_FSX)
	
	new_speed(speed)
	
end

-- This function isn't setup yet.  FSX doesn't appear
-- to expose this value.  X-Plane might expose it as 
-- sim/aircraft/view/acf_asi_kts	int	y	enum	air speed indicator knots calibration
-- but I have not tested it.  For now, we just allow manual manipulation on the screen by 
-- clicking on the knob.
function new_cali(degrees)
	img_rotate(as_card, degrees)
end

function new_knob(value)
	card = var_cap(card + value, -50, 70)
	img_rotate(as_card, card)
end

---------------------------------------------
--   Controls Add                          --
---------------------------------------------
dial_knob = hw_dial_add("RPI_V2_P1_35", "RPI_V2_P1_37", new_knob)
--dial_click_rotate(dial_knob,6)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/airspeed_kts_pilot", "FLOAT", new_speed)

fsx_variable_subscribe("AIRSPEED INDICATED", "knots", 
				       "L:AirspeedIndicatedNeedle", "number", new_speed_fsx)

---------------------------------------------
-- END       Airspeed Indicator            --
---------------------------------------------
