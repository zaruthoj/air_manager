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

function new_var_xpl(volts, oil_press)

    val = 0
	if volts[1] > 10 then
        val = oil_press[1]
	end
    val = var_cap(val, 0, 100)
	img_rotate(needle , -29 + val*.56)

end

function new_var_fsx(volts, oil_press, a2a_oil_press)
    val = 0
	if volts > 10 then
	    if a2a_oil_press ~= 0 then
	        val = a2a_oil_press
	    else
	        val = oil_press
		end
	end
    val = var_cap(val, 0, 100)
	img_rotate(needle , -29 + val*.56)
end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		  
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]",
					  "sim/cockpit2/engine/indicators/oil_pressure_psi","FLOAT[8]",
					  new_var_xpl)
					   
fsx_variable_subscribe("ELECTRICAL MAIN BUS VOLTAGE", "Volts",
					   "ENG OIL PRESSURE:1", "PSI",
                       "L:Eng1_OilPressure", "PSI", new_var_fsx)
---------------------------------------------
--   END                                   --
---------------------------------------------		                         