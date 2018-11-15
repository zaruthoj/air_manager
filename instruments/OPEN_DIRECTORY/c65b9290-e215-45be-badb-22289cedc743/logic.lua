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


---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
img_add_fullscreen("background.png")
img_vac = img_add_fullscreen("needle.png")

-----------------------------------------
-- Init default visibility & rotation --
-----------------------------------------
rotate(img_vac, 10)

---------------------------------------------
--   Functions                             --
---------------------------------------------
function new_vac_xpl(suct_XPL, suct_AFL)

    suct = fif(suct_AFL > 0, suct_AFL, suct_XPL)
    suct = var_cap(suct, 2.9, 7.1)
	rotate(img_vac, 215.0 - (suct * 25.0) )

end

function new_vac_fsx(suctnorm, sucta2a)
	
	-- Somehow the A2A suction LVAR doesn't match with the value in the sim, the default suction value works better.
	-- So the if statement below has been disabled for now.
    -- if sucta2a ~= 0 then
        -- suct = suctnorm
    -- else
        -- suct = suctnorm
    -- end
	suct = suctnorm
    
  --suct = var_cap(suct, 2.9, 7.1)
  suct = var_cap(suct, 0, 7.1)
	rotate( img_vac, (suct - 2) * 22.5 + 45)

end

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------		  
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/suction_1_ratio","FLOAT",
					  "172/instruments/uni_suction", "FLOAT", new_vac_xpl)

fsx_variable_subscribe("SUCTION PRESSURE", "Inches of Mercury",
                       "L:SuctionPressure", "inHg", new_vac_fsx)
---------------------------------------------
--   END                                   --
---------------------------------------------		                         