-------------------
--- GENERIC VOR ---
-------------------

horizontal_target = 0
vertical_target = 0
horizontal_cur = 0
vertical_cur = 0
factor = 0.05

-- BUTTON, SWITCH AND DIAL FUNCTIONS --
function new_obs(obs)

	if obs == -1 then
		xpl_command("sim/radios/obs1_up")
		fsx_event("VOR1_OBI_INC")
	elseif obs == 1 then
		xpl_command("sim/radios/obs1_down")
		fsx_event("VOR1_OBI_DEC")
	end

end

-- ADD IMAGES --
img_add_fullscreen("vorback.png")
img_to = img_add_fullscreen("to.png")
img_fr = img_add_fullscreen("fr.png")
img_NAV = img_add_fullscreen("navon.png")
img_BC = img_add_fullscreen("bcon.png")
img_horbar = img_add_fullscreen("horizontalbar.png")
img_verbar = img_add_fullscreen("verticalbar.png")
img_navflag = img_add_fullscreen("navflag.png")
img_gsflag = img_add_fullscreen("gsflag.png")
img_compring = img_add_fullscreen("compassring.png")
img_add_fullscreen("compasspointers.png")
--img_add_fullscreen("obsknobback.png")
--img_add_fullscreen("ring.png")

-- DEFAULT VISIBILITY --
visible(img_to, false)
visible(img_fr, false)
visible(img_navflag, false)
visible(img_gsflag, false)
visible(img_NAV, false)
visible(img_BC, false)

-- FUNCTIONS --
function new_obsheading(obs)
-- Rotate the omni bearing selector
	img_rotate(img_compring, obs*-1)

end

function new_info(tofromnav, glideslopeflag, avionics, backcourse)

-- tofromnav
-- 0: NAV flag
-- 1: To station
-- 2: From station

-- Is there a horizontal (localizer) signal?
	visible(img_navflag, tofromnav == 0)
	
-- Is there a vertical (glideslope) signal?	
	visible(img_gsflag, glideslopeflag < 2)
	
-- Are we flying to or from the station?
	visible(img_to, tofromnav == 1)
	visible(img_fr, tofromnav == 2)

-- Avionics are on and we are linked to NAV2
	visible(img_NAV, avionics == 1)
	
-- Is the autopilot back course mode on?
	visible(img_BC, backcourse == 1)
	
end

function new_dots(horizontal, vertical)	
	horizontal_target = horizontal
	vertical_target = vertical
end

function timer_callback()
    -- Move the CDI bar	
	move(img_horbar, 100 / 2 * horizontal_cur, nil, nil, nil)
-- Move the glideslope indicator
	move(img_verbar, nil, 100 / 2 * vertical_cur, nil, nil)
	
	diff = horizontal_target - horizontal_cur
	horizontal_cur = horizontal_cur + diff * factor
	if (math.abs(diff) < 0.01) then
	  horizontal_cur = horizontal_target
	end
	
	diff = vertical_target - vertical_cur
	vertical_cur = vertical_cur + diff * factor
	if (math.abs(diff) < 0.01) then
	  vertical_cur = vertical_target
	end
end
timer_start(0, 50, timer_callback)

function new_dots_fsx(vertical, horizontal)
-- Convert FSX localizer and glideslope dots to X-Plane dots
	vertical = 2 / 119 * vertical
	horizontal = 2 / 127 * horizontal
-- Send the calculated data to the X-Plane function	
	new_dots(horizontal, vertical)
	
end

function new_info_fsx(tofromnav, glideslopeflag, avionics, backcourse)

-- Turn the glideslope flag information from FSX to X-Plane information
	if glideslopeflag == true then
		gsflag = 2
	else
		gsflag = 0
	end

-- Turn avionics on/off information from FSX to X-Plane information
	avionics = fif(avionics, 1, 0)
	
-- Turn back course information from FSX to X-Plane information
	backcourse = fif(backcourse, 1, 0)
	
-- Send the information to the X-Plane function
	new_info(tofromnav, gsflag, avionics, backcourse)

end

-- DIALS ADD --
dial_obs = hw_dial_add("RPI_V2_P1_08", "RPI_V2_P1_10", new_obs)


-- DATABUS SUBSCRIBE --
fsx_variable_subscribe("NAV OBS:1", "Degrees", new_obsheading)
fsx_variable_subscribe("NAV TOFROM:1", "Enum",
					   "NAV GS FLAG:1", "Bool",
					   "CIRCUIT AVIONICS ON", "Bool",
					   "AUTOPILOT BACKCOURSE HOLD", "Bool", new_info_fsx)
fsx_variable_subscribe("NAV GSI:1", "Number",
					   "NAV CDI:1", "Number", new_dots_fsx)
xpl_dataref_subscribe("sim/cockpit/radios/nav1_obs_degm", "FLOAT", new_obsheading)
xpl_dataref_subscribe("sim/cockpit2/radios/indicators/nav1_flag_from_to_pilot", "INT", 
					  "sim/cockpit2/autopilot/glideslope_status", "INT",
					  "sim/cockpit/electrical/avionics_on", "INT",
					  "sim/cockpit/autopilot/backcourse_on", "INT", new_info)
xpl_dataref_subscribe("sim/cockpit/radios/nav1_hdef_dot", "FLOAT",
					  "sim/cockpit/radios/navq_vdef_dot", "FLOAT", new_dots)				  
