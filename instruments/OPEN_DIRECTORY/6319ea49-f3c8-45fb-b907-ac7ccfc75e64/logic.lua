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
rotate(needle, -35)

---------------------------------------------
--   Functions                             --
---------------------------------------------

function new_fp_xpl(fp)

    fp = var_cap(fp[1], 0, 10)
	img_rotate(needle , -35 + fp*6.5)

end

function new_fp_fsx(fp, fp_a2a)
	if (fp_a2a ~= 0) then
		fp = fp_a2a
	end
    fp = var_cap(fp, 0, 10)
	img_rotate(needle , -35 + fp*6.5)
end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		  
xpl_dataref_subscribe("sim/cockpit2/engine/indicators/fuel_pressure_psi", "FLOAT[8]", new_fp_xpl)
fsx_variable_subscribe("GENERAL ENG FUEL PRESSURE:1", "PSI", "L:Eng1_FuelPressure", "PSI", new_fp_fsx)
---------------------------------------------
--   END                                   --
---------------------------------------------		                         