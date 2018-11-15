-----------------------------------------------------------------
--   Attitude Indicator, Vacuum driven                         --
-- Modification of Jason Tatum's original                      --
-- Brian McMullan 20180327                                     -- 
-- Property for background off/on                              --
-- Property for dimming overlay                                --
-- Property for Pilot or Co-pilot                              --
-- Property for animating fail flag or not                     --
-- Fixed the hoop control knob functions                       --
-- Artificial Horizon two-way updates AM to XPlane (only)      --
-----------------------------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
prop_BG = user_prop_add_boolean("Background",true,"Display background?")
prop_DO = user_prop_add_boolean("Dimming overlay",false,"Enable dimming overlay?")
prop_Vx = user_prop_add_enum("X-Plane Pilot or Co-Pilot","PILOT,CO-PILOT","PILOT","Pilot = vac1, Co-pilot = vac2")
prop_AF = user_prop_add_boolean("Animated fail flag",true,"Use animated fail flag or not")

---------------------------------------------
--   Load and display images in Z-order    --
--   Loaded images selectable with prop    --
---------------------------------------------
img_bg = img_add_fullscreen("attbg.png")
img_horizon = img_add_fullscreen("attitude_horizon.png")
img_bankind = img_add_fullscreen("attroll.png")
img_hoop = img_add_fullscreen("atthoop.png")
img_flag = img_add("FailFlag.png", -124, -188, 512, 512)
if user_prop_get(prop_BG) == false then
	img_add_fullscreen("attitude.png")
else
	img_add_fullscreen("attitudewBG.png")
end	
--img_add("airknobshadow.png",213,400,85,85)
--img_add_fullscreen("Bezel.png")
if user_prop_get(prop_DO) == true then
	img_add_fullscreen("dimoverlay.png")
end

---------------------------------------------
--   Init                                  --
---------------------------------------------
flag_rotation = -25
rotate(img_flag,flag_rotation)		-- fail flag on startup until SIM gives values
flag_state = 0                        -- 0 = do nothing, 1 = extend, 2 = retract
hoop_height = 0

---------------------------------------------
--   Functions                             --
---------------------------------------------

function change_attitude_FSX(roll, pitch)
	change_attitude(roll * -57, pitch * -37)
end

function change_attitude(roll, pitch)
  -- Roll outer ring
  roll = var_cap(roll, -60, 60)
  rotate(img_bankind, roll *-1)
  rotate(img_bg, roll *-1)
  
  -- Roll horizon
  rotate(img_horizon  , roll * -1)
    
  -- Move horizon pitch
  pitch = var_cap(pitch, -25, 25)
  radial = math.rad(roll * -1)
  x = -(math.sin(radial) * pitch * 3)
  y = (math.cos(radial) * pitch * 3)
  move(img_horizon, x, y, nil, nil)
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
		rotate(img_flag, flag_rotation)
		
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
		if flag_state == 1 then flag_rotation = -25	rotate(img_flag, flag_rotation) end
    -- retract
    if flag_state == 2 then flag_rotation = -2 rotate(img_flag, flag_rotation) visible(img_flag, false) end
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
-- Interactive artificial horizon between AM and XP
--   XP ahref ranges from -30 down to +30 up, 0 center
--   AM hoop  ranges from 103 down to -95 up, -3 center
--    use Lagrange polynomial interpolation, oh, easy website vs manual!  https://www.dcode.fr/lagrange-interpolating-polynomial
--    XP to AM (30,-95)(0,-3)(-30,103); function is f(x) = 7x^2/900 - 33x/10 - 3
--    AM to XP (-95,30)(-3,0)(103,-30); function is f(x) = 35x^2/160908 - 12260x/40227 - 49145/53636  
---------------------------------------------
  
function new_ahref(pixels)
  -- AH moved in XP simulator, adjust in AM
  -- calculate the AirManager hoop location
  hoop_height = (pixels^2 * 7)/900 - pixels * 33 / 10 - 3
  -- move the hoop
  move(img_hoop, 0, hoop_height, 512, 512)
end

function new_knob(value)
  -- AH moved in AM, adjust in XP
  -- Adjust artificial horizon in XPLANE, back to sim
	hoop_height = hoop_height + value
  -- limit values to range
  hoop_height = var_cap(hoop_height,-95,103)
	-- move the image in AM
	move(img_hoop, 0, hoop_height, 512, 512)
	-- calculate value and send to XPlane
	xpl_dataref_write("sim/cockpit/misc/ah_adjust","FLOAT", 35*hoop_height^2 / 160908 - 12260*hoop_height/40227 - 49145/53636)
end

---------------------------------------------
--   Controls Add                          --
---------------------------------------------
--dial_knob = dial_add("airknob.png", 213, 395, 85, 85, new_knob)
--dial_click_rotate(dial_knob,6)

---------------------------------------------
--   Timer start                           --
---------------------------------------------
tmr_flag = timer_start(0, 50, animation_timer_callback)

---------------------------------------------
--   Simulator Subscriptions               --
---------------------------------------------
xpl_dataref_subscribe("sim/cockpit/gyros/phi_vac_ind_deg", "FLOAT",
					  "sim/cockpit/gyros/the_vac_ind_deg", "FLOAT",	change_attitude)
					
xpl_dataref_subscribe("sim/operation/failures/rel_vacuum", "INT",
					  "sim/operation/failures/rel_vacuum2", "INT",
					  "sim/cockpit/misc/vacuum", "FLOAT", 
					  "sim/cockpit/misc/vacuum2", "FLOAT", new_vacfail_XP)

xpl_dataref_subscribe("sim/cockpit/misc/ah_adjust", "FLOAT", new_ahref)
					  					  

					  
fsx_variable_subscribe("ATTITUDE INDICATOR BANK DEGREES", "Radians",
					   "ATTITUDE INDICATOR PITCH DEGREES", "Radians", change_attitude_FSX)
					   
fsx_variable_subscribe("PARTIAL PANEL VACUUM", "Enum",
					   "SUCTION PRESSURE", "Inches of Mercury", new_vacfail_fsx)					   
					   
---------------------------------------------
-- END    Attitude                         --
---------------------------------------------					   