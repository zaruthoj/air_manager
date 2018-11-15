---------------------------------------------
--         Oil Temp & Pressure             --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background",true,"Hide background?")
prop_DO = user_prop_add_boolean("Dimming overlay",false,"Enable dimming overlay?")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
img_add_fullscreen("OilPressTempFace.png")
img_oilt = img_add("needle3.png", -150, 0, 512, 512)
img_oilp = img_add("needle3.png", 150, 0, 512, 512)
if user_prop_get(prop_BG) == false then
	img_add_fullscreen("OilPressTempCover.png")
else
	img_add_fullscreen("OilPressTempCoverwBG.png")
end	
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

---------------------------------------------
--   INIT                                  --
---------------------------------------------
local target_oilt	= 75
local target_oilp	= 0
local cur_oilt		= 75
local cur_oilp		= 0
local factor		= 0.2

---------------------------------------------
--   Functions                             --
---------------------------------------------
function new_oil(bus_volts, opress_xpl, otemp_xpl, otemp_afl, opress_afl)

	opress = fif(opress_afl > 0, opress_afl, opress_xpl[1])
	otemp = fif(otemp_afl > 0, otemp_afl, otemp_xpl[1])
	
	opress = var_cap(opress, 0, 115)
	otemp = var_cap(otemp, 75, 250 )

	if bus_volts[1] >= 10 then
		target_oilt = otemp
		target_oilp = opress
	else
		target_oilt = 75
		target_oilp = 0
	end
    
end

function new_oil_fsx(bus_volts, pressfsx, tempfsx, tempa2a, pressa2a)

	tempfsx = var_cap(tempfsx, 75, 250)

    if tempa2a ~= 0 then
        temp = tempa2a * 1.8 + 32
    else
        temp = tempfsx
    end
	
	pressfsx = var_cap(pressfsx, 0, 115)

    if pressa2a ~= 0 then
        press = pressa2a
    else
        press = pressfsx
    end

	if bus_volts >= 10 then
		target_oilt = temp
		target_oilp = press
	else
		target_oilt = 75
		target_oilp = 0
	end

end 	

function timer_callback()	
	
    rotate(img_oilt, var_cap(180.0 - (cur_oilt * 0.58), 36, 144) )
    rotate(img_oilp, 180 + 40 + (cur_oilp * 0.91))

    cur_oilt = cur_oilt + ((target_oilt - cur_oilt) * factor)
	cur_oilp = cur_oilp + ((target_oilp - cur_oilp) * factor)
	
end

timer_start(0, 50, timer_callback)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]",
					  "sim/cockpit2/engine/indicators/oil_pressure_psi","FLOAT[8]",
					  "sim/cockpit2/engine/indicators/oil_temperature_deg_C","FLOAT[8]",
					  "172/instruments/uni_oil_F", "FLOAT", 
					  "172/instruments/uni_oil_press", "FLOAT", new_oil)
					   
fsx_variable_subscribe("ELECTRICAL MAIN BUS VOLTAGE", "Volts",
					   "ENG OIL PRESSURE:1", "PSI",
					   "ENG OIL TEMPERATURE:1", "Fahrenheit",
                       "L:Eng1_OilTemp", "Celsius",
                       "L:Eng1_OilPressure", "PSI", new_oil_fsx) 
---------------------------------------------
--   END                                   --
---------------------------------------------		             