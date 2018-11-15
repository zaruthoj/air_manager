img_add_fullscreen("clock.png")
txt_load_font("lcd.ttf")
txt_load_font("arial_black.ttf")

v_temp_txt 	 	  = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:right;", 5  , 90, 180, 80)
d_temp_txt 	 	  = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 200  , 90, 180, 80)
v_volts_txt  	  = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 110  , 90, 180, 80)
d_volts_txt  	  = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 220  , 90, 180, 80)
v_ut_hour_txt     = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 150  , 160, 180, 80)
v_lt_hour_txt     = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 150  , 160, 180, 80)
v_ft_hour_txt     = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 150  , 160, 180, 80)
v_et_hour_txt     = txt_add(" ", "font:lcd.ttf; size:48; color:black; halign:RIGHT;", 150  , 160, 180, 80)
--##########################################################################################################################################################################################
-- Clock desc
d_ut_txt 	 	 = txt_add(" ", "font:arial_black.ttf; size:18; color:black; halign: LEFT;", 50  , 160, 180, 80)
img_UT 			 = img_add("arrowup.png",52,180,26,8)
d_lt_txt 	 	 = txt_add(" ", "font:arial_black.ttf; size:18; color:black; halign: LEFT;", 90  , 160, 180, 80)
img_LT 			 = img_add("arrowup.png",90,180,26,8)
d_ft_txt 	 	 = txt_add(" ", "font:arial_black.ttf; size:18; color:black; halign: LEFT;", 50  , 190, 180, 80)
img_FT 			 = img_add("arrowup.png",49,210,26,8)
d_et_txt 	 	 = txt_add(" ", "font:arial_black.ttf; size:18; color:black; halign: LEFT;", 90  , 190, 180, 80)
img_ET 			 = img_add("arrowup.png",90,210,26,8)

-- Setting global variables
oat_volts_state = 0
select_state = 0			-- 0:Stopped and reset 1:running 2:stopped
timer_state = 0			-- 0:Stopped and reset 1:running 2:stopped
timer_value = 0


function oat_vlts_pressed()
	if oat_volts_state == 2 then
		oat_volts_state = 0
		oat_volts_state = 0
	else
		oat_volts_state = oat_volts_state + 1
	end
end

-- Bind to Raspberry Pi 2, Header P1, Pin 40
button_add("oat_vlts.png", "oat_vlts.png", 169,35,22,22,oat_vlts_pressed)
oat_volts_button = hw_button_add("ARDUINO_NANO_A_D10", oat_vlts_pressed)

function select_pressed()
	if select_state == 3 then
		select_state = 0
		select_value = 0
	else
		select_state = select_state + 1
	end
end

-- Bind to Raspberry Pi 2, Header P1, Pin 40
button_add("ctrl_select.png", "ctrl_select.png", 107,276,22,22,select_pressed)
select_button = hw_button_add("ARDUINO_NANO_A_D11", select_pressed)

function control_pressed()
	if timer_state == 2 then
		timer_state = 0
		timer_value = 0
	else
		timer_state = timer_state + 1
	end
end

-- Bind to Raspberry Pi 2, Header P1, Pin 40
button_add("ctrl_select.png", "ctrl_select.png", 230,276,22,22,control_pressed)
control_button = hw_button_add("ARDUINO_NANO_A_D12", control_pressed)

function timer_callback()
	
	if timer_state == 1 then
		timer_value = timer_value + 1
	end
end

function PT_clock(avionics,battery,volts,outtemp_c,outtemp_f,ut_hours,loc_hours,ft_hours,ft_min,et_sec)
	
	-- if avionics and battery are greater than 1 then show data else make it blank. 
	if avionics >= 1 and battery >= 1 and oat_volts_state == 0 then 
		txt_set(v_volts_txt, string.format("%.1f",var_round(volts,1)))
		txt_set(d_volts_txt, "E")
		txt_set(v_temp_txt, " ")
		txt_set(d_temp_txt, " ")
	elseif avionics >= 1 and battery >= 1 and oat_volts_state == 1 then 
		txt_set(v_temp_txt, var_round(outtemp_f)) -- then the option chosen is Fahrenheit
		txt_set(d_temp_txt, "F")
		txt_set(v_volts_txt, " ")
		txt_set(d_volts_txt, " ")
	elseif avionics >= 1 and battery >= 1 and oat_volts_state == 2 then -- then the option chosen is Celcius
		txt_set(v_temp_txt, var_round(outtemp_c))
		txt_set(d_temp_txt, "C")
		txt_set(v_volts_txt, " ")
		txt_set(d_volts_txt, " ")
	else
	    txt_set(d_volts_txt, " ")
		txt_set(v_temp_txt, " ")
		txt_set(d_temp_txt, " ")
		txt_set(v_volts_txt, " ")
		txt_set(d_volts_txt, " ")
	end
	
	if avionics >= 1 and battery >= 1 then
		txt_set(d_ut_txt, "UT")
		txt_set(d_lt_txt, "LT")
		txt_set(d_ft_txt, "FT")
		txt_set(d_et_txt, "ET")
	else
		txt_set(d_ut_txt, " ")
		txt_set(d_lt_txt, " ")
		txt_set(d_ft_txt, " ")
		txt_set(d_et_txt, " ")
	end
	
	-- show the clock position FLAG and clock values according to the selection mode
	if avionics >= 1 and battery >= 1 and select_state == 0 then -- then it is UT selection
		img_visible(img_UT,true)
		img_visible(img_LT,false)
		img_visible(img_FT,false)
		img_visible(img_ET,false)
		txt_set(v_ut_hour_txt, string.format("%02.0f:%02.0f",ut_hours,var_round(math.floor(ut_hours * 100 % 100) * 60 / 100)))
		txt_set(v_lt_hour_txt, " ")
		txt_set(v_ft_hour_txt, " ")
		txt_set(v_et_hour_txt, " ")
	elseif avionics >= 1 and battery >= 1 and select_state == 1 then -- then it is LT selection
		img_visible(img_UT,false)
		img_visible(img_LT,true)
		img_visible(img_FT,false)
		img_visible(img_ET,false)
		txt_set(v_lt_hour_txt, string.format("%02.0f:%02.0f",(ut_hours - loc_hours),var_round(math.floor(ut_hours * 100 % 100) * 60 / 100))) -- loc hours is given in timezone diffence so the GMT hours is substracted to get local time. In case of GMT + for loc time, FSX returns negative so in the end it will be minus with minus = +
		txt_set(v_ut_hour_txt, " ")
		txt_set(v_ft_hour_txt, " ")
		txt_set(v_et_hour_txt, " ")
	elseif avionics >= 1 and battery >= 1 and select_state == 2 then -- then it is FT selection
		img_visible(img_UT,false)
		img_visible(img_LT,false)
		img_visible(img_FT,true)
		img_visible(img_ET,false)
		txt_set(v_ft_hour_txt, string.format("%02.0f:%02.0f",ft_hours,var_round(math.floor((ft_min / 60) * 100 % 100) * 60 / 100)))
		txt_set(v_ut_hour_txt, " ")
		txt_set(v_lt_hour_txt, " ")
		txt_set(v_et_hour_txt, " ")
	elseif avionics >= 1 and battery >= 1 and select_state == 3 then -- then it is ET selection
		img_visible(img_UT,false)
		img_visible(img_LT,false)
		img_visible(img_FT,false)
		img_visible(img_ET,true)
		txt_set(v_et_hour_txt,string.format("%02.0f:%02.0f",math.floor(((timer_value / 60) % 60)), (timer_value % 60)))
		txt_set(v_ut_hour_txt, " ")
		txt_set(v_lt_hour_txt, " ")
		txt_set(v_ft_hour_txt, " ")
	else
		img_visible(img_UT,false)
		img_visible(img_LT,false)
		img_visible(img_FT,false)
		img_visible(img_ET,false)
		txt_set(v_ut_hour_txt, " ")
		txt_set(v_lt_hour_txt, " ")
		txt_set(v_ft_hour_txt, " ")	
		txt_set(v_et_hour_txt, " ")
	end
	
end

function PT_clock_fsx(avionics,battery,volts, outtemp_c,outtemp_f,ut_hours,loc_hours,ft_hours,ft_min)
	
	PT_clock(avionics,battery,volts,outtemp,outtemp_f,ut_hours,loc_hours,ft_hours,ft_min)
	
end

timer_start(0,1000,timer_callback)

fsx_variable_subscribe("ELECTRICAL AVIONICS BUS VOLTAGE", "Volts",
					   "ELECTRICAL BATTERY BUS VOLTAGE", "Volts",
					   "ELECTRICAL MAIN BUS VOLTAGE","Volts",
					   "AMBIENT TEMPERATURE", "Celsius", 
					   "AMBIENT TEMPERATURE", "Fahrenheit",
					   "ZULU TIME", "Hours",
					   "TIME ZONE OFFSET", "Hours",
					   "L:HoursTime","Number",
					   "L:MinutesTime","Number",PT_clock)