LOW = false
HIGH = true

row_rs_pin = "RPI_V2_P1_24"
col_bs_pin = "RPI_V2_P1_26"
row_lb_pin = "RPI_V2_P1_32"
col_rl_pin = "RPI_V2_P1_36"

rs_row = 1
lb_row = 2
bs_col = 1
rl_col = 2

state_off = 0
state_right = 1
state_left = 2
state_both = 3

fsx_left = false
fsx_right = false
fsx_start = false

debug_txt = txt_add("None", "font:arial_black.ttf; size:18; color:white; halign: LEFT;", 0, 0, 200, 100)
pin_txt = txt_add("None", "font:arial_black.ttf; size:18; color:white; halign: LEFT;", 0, 50, 200, 100)

function off_timeout()
  txt_set(debug_txt, "off")
  --fsx_variable_write("L:Magnetos1","enum", state_off)
  send_state(false, false, false)
end

off_timer = timer_start(500, nil, off_timeout)
timer_stop(off_timer)

function send_state(left, right, start)
  if left ~= fsx_left then
    fsx_event("MAGNETO1_LEFT")
  end
  if right ~= fsx_right then
    fsx_event("MAGNETO1_RIGHT")
  end
  if start ~= fsx_start then
    --fsx_event("MAGNETO1_START")
    --fsx_variable_write("L:Eng1_StarterSwitch", "bool", start)
  end
  
end

function state_changed(row, col, val, full_report)
  if val == LOW then
    if timer_running(off_timer) then
      timer_stop(off_timer)
    end
    if row == rs_row then
      if col == rl_col then
        txt_set(debug_txt, "right")
        send_state(false, true, false)
      elseif col == bs_col then
        txt_set(debug_txt, "start")
        if not full_report then
          --fsx_event("MAGNETO1_START")
          fsx_variable_write("L:Eng1_StarterSwitch", "bool", true)
        end
        --send_state(true, true, true)
      end
    elseif row == lb_row then
      if col == rl_col then
        txt_set(debug_txt, "left")
        send_state(true, false, false)
      elseif col == bs_col then
        txt_set(debug_txt, "both")
        send_state(true, true, false)
      end
    end
  else
    if not full_report then
      off_timer = timer_start(500, nil, off_timeout)
    elseif row == rs_row and col == bs_col and not full_report then
      --fsx_event("MAGNETO1_START")
      fsx_variable_write("L:Eng1_StarterSwitch", "bool", false)
    end
  end
end

function no_op()
end

current_row = 1
rows = {}
rows[rs_row] = hw_output_add(row_rs_pin, LOW)
rows[lb_row] = hw_output_add(row_lb_pin, HIGH)
cols = {}
cols[rl_col] = hw_input_add(col_rl_pin, no_op)
cols[bs_col] = hw_input_add(col_bs_pin, no_op)

-- Add dummy buttons to enable internal pullups
hw_button_add(col_bs_pin, no_op)
hw_button_add(col_rl_pin, no_op)

last_vals = {{HIGH, HIGH}, {HIGH, HIGH}}

function tick()
  tick_internal(false)
end

full_report = 0
function tick_internal(suppress)
  full_report = (full_report + 1) % 21 -- full report on half the pins every 1 seconds.
  for col=1,2 do
    local val = hw_input_read(cols[col])
    local last = last_vals[current_row][col]
    last_vals[current_row][col] = val
    if (val ~= last or full_report == 0) and not suppress then
      state_changed(current_row, col, val, full_report == 0)
    end
  end
  hw_output_set(rows[current_row], HIGH)
  current_row = current_row % 2 + 1
  hw_output_set(rows[current_row], LOW)
end

tick_internal(true)
tick_internal(true)

tick_timer = timer_start(50, 50, tick)

function new_fsx_data(left, right, start)
  fsx_left = left
  fsx_right = right
  fsx_start = start
  txt_set(pin_txt, tostring(fsx_start))
end
fsx_variable_subscribe("RECIP ENG LEFT MAGNETO:1", "Bool", "RECIP ENG RIGHT MAGNETO:1", "Bool", "GENERAL ENG STARTER:1", "Bool", new_fsx_data)

--hw_button_array_add(2, 2, row_ls_pin, row_rb_pin, col_lr_pin, col_bs_pin, button_pressed, button_released)
