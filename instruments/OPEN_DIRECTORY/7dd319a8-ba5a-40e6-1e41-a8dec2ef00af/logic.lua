HIGH = true
LOW = false

right_pin = "RPI_V2_P1_40"
off_pin = "RPI_V2_P1_38"

right = HIGH
off = HIGH

function send_state()
  state = 1
  if (right == LOW) then
    state = 2
  elseif (off == LOW) then
    state = 0
  end
  fsx_variable_write("L:FSelCherokeeState", "number", state)
end


function fuel_right_callback(state)
  right = state
  send_state()
end

function fuel_off_callback(state)
  off = state
  send_state()
end

function noop()
end

function full_scan()
  right = hw_input_read(right_input)
  off = hw_input_read(off_input)
  send_state()
end
--scan_timer = timer_start(5, 5, full_scan)

right_input = hw_input_add(right_pin, fuel_right_callback)
off_input = hw_input_add(off_pin, fuel_off_callback)
hw_button_add(right_pin, noop)
hw_button_add(off_pin, noop)