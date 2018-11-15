--dbg = txt_add("None", "font:lcd.ttf; size:15; color:white; halign:left;", 0, 0, 100, 50)

HIGH = true
LOW = false

avionics_on = false

function avionics(state)
  if state == avionics_on then
    fsx_event("TOGGLE_AVIONICS_MASTER")
    if state == LOW then
      timer_start(1000, nil, function() fsx_variable_write("L:ApMaster", "Bool", false) end)
    end
  end
end

function avionics_fsx(avionics)
  avionics_on = avionics
end

function vacuum_fsx(vacuum)
  if vacuum < 3 then
    hw_led_set(vacuum_led, 0.3)
  else
    hw_led_set(vacuum_led, 0.0)
  end
end

function aoa_fsx(aoa)
  --txt_set(dbg, tostring(aoa))
  if aoa > 0.175 then
    hw_led_set(stall_led, 0.3)
  else
    hw_led_set(stall_led, 0.0)
  end
end

function autopilot(state)
  fsx_variable_write("L:ApMaster", "Bool", state == LOW)
end

function scan()
  avionics(hw_input_read(avionics_toggle))
  --autopilot(hw_input_read(autopilot_toggle))
end

avionics_toggle = hw_input_add("ARDUINO_NANO_A_D09", avionics)
vacuum_led = hw_led_add("ARDUINO_NANO_A_D08", 0.0)
stall_led = hw_led_add("ARDUINO_NANO_A_D07", 0.0)
autopilot_toggle = hw_input_add("ARDUINO_NANO_A_D06", autopilot)

--scan_timer = timer_start(0, 2000, scan) 

fsx_variable_subscribe("AVIONICS MASTER SWITCH", "Bool", avionics_fsx)
fsx_variable_subscribe("SUCTION PRESSURE", "Inches of Mercury", vacuum_fsx)
fsx_variable_subscribe("INCIDENCE ALPHA", "Radians", aoa_fsx)

function noop()
end

--hw_button_add("ARDUINO_NANO_A_D09", noop)
--hw_button_add("ARDUINO_NANO_A_D06", noop)