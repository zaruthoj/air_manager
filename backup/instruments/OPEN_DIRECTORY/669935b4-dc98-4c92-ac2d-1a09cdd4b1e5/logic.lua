---------------------------------------------
--           Vacuum & Ammeter              --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
img_add_fullscreen("background.png")
needle = img_add("needle.png", 0, 0, 190, 280)

-----------------------------------------
-- Init default visibility & rotation --
-----------------------------------------
rotate(needle, -29)

---------------------------------------------
--   Functions                             --
---------------------------------------------

function new_var_xpl(volts, oil_temp)

    val = 0
	if volts[1] > 10 then
        val = 32 + oil_temp[1] * 9.0 / 5.0
	end
    val = var_cap(val, 75, 260)
	img_rotate(needle , -29 + (val - 75)*.305)

end

function new_var_fsx(volts, oil_temp, a2a_oil_temp)
    val = 0
	if volts > 10 then
	    if a2a_oil_temp ~= 0 then
	        oil_temp = a2a_oil_temp
		end
		val = 32 + 9.0 / 5.0 * oil_temp
	end
    val = var_cap(val, 75, 260)
	img_rotate(needle , -29 + (val - 75)*.305)
end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		  
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]",
					  "sim/cockpit2/engine/indicators/oil_temperature_deg_C","FLOAT[8]",
					  new_var_xpl)
					   
fsx_variable_subscribe("ELECTRICAL MAIN BUS VOLTAGE", "Volts",
					   "ENG OIL TEMPERATURE:1", "Fahrenheit",
                       "L:Eng1_OilTemp", "Celsius",
					   new_var_fsx) 
---------------------------------------------
--   END                                   --
---------------------------------------------		                         