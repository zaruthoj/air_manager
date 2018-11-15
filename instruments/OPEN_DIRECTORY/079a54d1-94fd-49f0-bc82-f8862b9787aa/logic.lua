---------------------------------------------
--    Heading Indicator, Vacuum driven     --
-- Modification of Jason Tatum's original  --
-- Brian McMullan 20180327                 -- 
-- Property for background off/on          --
-- Property for dimming overlay            --
-- Property for Pilot or Co-pilot          --
-- Added Vacuum fail flag added            -- 
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background",true,"Display background?")
prop_DO = user_prop_add_boolean("Dimming overlay",false,"Enable dimming overlay?")
prop_Vx = user_prop_add_enum("X-Plane: Pilot or Co-Pilot","PILOT,CO-PILOT","PILOT","Pilot = vac1, Co-pilot = vac2")
prop_AF = user_prop_add_boolean("Animated fail flag",true,"Use animated fail flag or not")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
if user_prop_get(prop_BG) == false then
	img_add_fullscreen("heading.png")
else
	img_add_fullscreen("headingwBG.png")
end	
img_background_compass = img_add_fullscreen("CompassRing.png")
img_bug = img_add_fullscreen("HeadingBug.png")
img_plane = img_add_fullscreen("PlaneRing.png")
img_flag = img_add("FailFlag.png", -124, -188, 512, 512)
img_add_fullscreen("Bezel.png")
--img_add("knobshadow.png", 30, 406, 85, 85)
--img_add("knobshadow.png", 390, 406, 85, 85)
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

---------------------------------------------
--   Init                                  --
---------------------------------------------
flag_rotation = -25
img_rotate(img_flag, flag_rotation)   -- failed on startup until SIM engages
flag_state = 0                        -- 0 = do nothing, 1 = extend, 2 = retract
flag_state_prev = 0

---------------------------------------------
--   Functions                             --
---------------------------------------------

function new_rotation(rotation)
	img_rotate(img_background_compass, rotation * -1)
end

function new_headbug(heading, bug)
	img_rotate(img_bug, bug - heading)
end

function new_headbug_fsx(heading_FSX, bug_FSX, heading_A2A, bug_A2A)
	heading = fif(heading_A2A ~= 0, heading_A2A, heading_FSX)
	bug = fif(bug_A2A ~= 0, bug_A2A, bug_FSX)
	new_headbug(heading, bug)
end

function new_knob_gyro(direction)
	if direction == -1 then
		xpl_command("sim/instruments/DG_sync_up")
		fsx_event("GYRO_DRIFT_INC")
	elseif direction == 1 then
		xpl_command("sim/instruments/DG_sync_down")
		fsx_event("GYRO_DRIFT_DEC")
	end
end


function new_knob_hdg(direction)
	if direction == -1 then
		xpl_command("sim/autopilot/heading_up")
		fsx_event("HEADING_BUG_INC")
	elseif direction == 1 then
		xpl_command("sim/autopilot/heading_down")
		fsx_event("HEADING_BUG_DEC")
	end
end

-- Vacuum failure flag animation via timer callback
-- timer continuously runs, function determines if needs to act
function animation_timer_callback()
	
	if flag_state > 0 then  -- if need to move the flag (1 or 2)
		-- extend
		if flag_state == 1 then
			flag_rotation = flag_rotation - 0.5
			if flag_rotation <= -25 then flag_rotation = -25 flag_state = 0 end
    end
	  -- retract (is faster than extend)
		if flag_state == 2 then
			flag_rotation = flag_rotation + 2
			if flag_rotation >= -2 then flag_rotation = -2 visible(img_flag, false) flag_state = 0 end
		end
	  -- do the rotation
		img_rotate(img_flag, flag_rotation)
  end
end  -- function animation_timer_callback


function new_vacfail_XP(vac1fail, vac2fail, vac1, vac2)
  -- XP uses vac1 for pilot, vac2 for co-pilot steam gauges
  	
  if user_prop_get(prop_Vx) == "PILOT" then
	  if (vac1fail > 0) or (vac1 < 1.8) then	
			visible(img_flag, true)
			flag_state = 1
		else
			flag_state = 2
		end
	
	else -- is co-pilot
	  if (vac2fail > 0) or (vac2 < 1.8) then	
			visible(img_flag, true)
			flag_state = 1
		else
			flag_state = 2
		end
	end
	
	if user_prop_get(prop_AF) == false then
		-- no animation, just flick the flag
		-- extend
		if flag_state == 1 then flag_rotation = -25	img_rotate(img_flag, flag_rotation) end
    -- retract
    if flag_state == 2 then flag_rotation = -2 img_rotate(img_flag, flag_rotation) visible(img_flag, false) end
    flag_state = 0   -- operation done, clear flag	  
	end
end


function new_vacfail_fsx(fail, vac)
	if fail > 0 or vac < 1.8 then
		visible(img_flag, true)
		flag_state = 1
	else
		flag_state = 2
	end
end


---------------------------------------------
--   Controls Add                          --
---------------------------------------------
dial_knob = hw_dial_add("RPI_V2_P1_31", "RPI_V2_P1_33", new_knob_gyro)

dial_knob = hw_dial_add("RPI_V2_P1_29", "RPI_V2_P1_23", "TYPE_1_DETENT_PER_PULSE", new_knob_hdg)

---------------------------------------------
--   Timer start                           --
---------------------------------------------
tmr_flag = timer_start(0, 50, animation_timer_callback)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe("sim/cockpit/gyros/psi_vac_ind_degm", "FLOAT", new_rotation)

xpl_dataref_subscribe("sim/cockpit/gyros/psi_vac_ind_degm", "FLOAT",
					  "sim/cockpit/autopilot/heading_mag", "FLOAT", new_headbug)

xpl_dataref_subscribe("sim/operation/failures/rel_vacuum", "INT",
					  "sim/operation/failures/rel_vacuum2", "INT",
					  "sim/cockpit/misc/vacuum", "FLOAT", 
					  "sim/cockpit/misc/vacuum2", "FLOAT", new_vacfail_XP)

					  
fsx_variable_subscribe("HEADING INDICATOR", "degrees", new_rotation)

fsx_variable_subscribe("HEADING INDICATOR", "degrees",
					   "AUTOPILOT HEADING LOCK DIR", "degrees",
					   "L:HeadingGyro", "degrees", 
					   "L:AutopilotHeadingBug", "number", new_headbug_fsx)
					   
fsx_variable_subscribe("PARTIAL PANEL VACUUM", "Enum",
					   "SUCTION PRESSURE", "Inches of Mercury", new_vacfail_fsx)						   
					   
---------------------------------------------
-- END       Heading                       --
---------------------------------------------							   					   
