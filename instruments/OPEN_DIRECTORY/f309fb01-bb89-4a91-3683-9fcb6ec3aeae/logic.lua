---------------------------------------------
--           Vacuum & Ammeter              --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180324                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_DO = user_prop_add_boolean("Dimming overlay",false,"Enable dimming overlay?")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
img_add_fullscreen("background.png")
needle = img_add("needle.png", 0, 0, 190, 280)

if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

-----------------------------------------
-- Init default visibility & rotation --
-----------------------------------------
rotate(needle, -35)

---------------------------------------------
--   Functions                             --
---------------------------------------------

function new_amps_xpl(amps)

    amps = var_cap(amps[1], 0, 40)
	img_rotate(needle , -35 + amps*1.72)

end

function new_amps_fsx(ampsfsx, ampsa2a)

    if ampsa2a ~= 0 then
        amps = ampsa2a
    else
        amps = ampsfsx
    end
    
    amps = var_cap(amps, 0, 40)
    rotate(needle, -35 + amps*1.72)

end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		  
xpl_dataref_subscribe("sim/cockpit2/electrical/battery_amps","FLOAT[8]", new_amps_xpl)

fsx_variable_subscribe("ELECTRICAL BATTERY BUS AMPS", "Amperes",
                       "L:Ammeter1", "amps", new_amps_fsx)
---------------------------------------------
--   END                                   --
---------------------------------------------		                         