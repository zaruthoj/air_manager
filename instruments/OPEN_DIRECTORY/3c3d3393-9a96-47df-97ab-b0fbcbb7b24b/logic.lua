
background = img_add_fullscreen("background.png")

--mode enum
mode_flow_hp = 1
mode_rem = 2
mode_used = 3
mode_time = 4
mode_aux = 5

--option enum
option_main = 1
option_alternate = 2
option_program = 3

green_y = 329
green_x_vals = {}
green_x_vals[mode_flow_hp] = 78
green_x_vals[mode_rem] = 158
green_x_vals[mode_used] = 238
green_x_vals[mode_time] = 317
green_x_vals[mode_aux] = 398

red_y = 39

power_on = false
initial_rem_blink_state = true
mode = mode_rem

fuel_set = 34
fuel_used_flight = 0
fuel_used = 0
fuel_actual = 0
flow = 8
fuel_flow_75p = 7

low_fuel_on = img_add("red.png", 193, red_y, 37, 37)
hl_aux_on = img_add("red.png", 278, red_y, 37, 37)
visible(low_fuel_on, false)
visible(hl_aux_on, false)

Mode = {}
function Mode:new (o)
  local empty = o == nil
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Mode:insert(before, after, other, prog)
  self.before = before
  self.after = after
  self.other = other
  self.prog = prog
end

function Mode:prog_both()
  if not self.prog then return end
  self:exit()
  current = self.prog
  self.prog:start()
end

Display = Mode:new()
function Display:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.text_box = txt_add(o.text, "font:lcd.ttf; size:70; color:black; halign:left;", 130, 160, 300, 80)
  o.led_img = img_add("green.png", o.green_x, green_y, 34, 34)
  visible(o.text_box, false)
  visible(o.led_img, false)
  o.visible = false
  return o
end

function Display:blink()
  if current ~= self then return end
  self.visible = not self.visible;
  visible(self.text_box, self.visible);
end

function Display:step(side)
  if not self.after then return end
  self:exit()
  current = fif(side == -1, self.before, self.after)
  current:start()
end

function Display:start()
  visible(self.text_box, true)
  visible(self.led_img, true)
  self.visible = true
end

function Display:exit()
  visible(self.text_box, false)
  visible(self.led_img, false)
  self.visible = false;
end

function Display:prog_release(side)
  if (self.other ~= nil) then
    self:exit()
    current = self.other
    self.other:start()
  end
end

Programmable = Mode:new()
function Programmable:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.digits = {}
  o.led_img = img_add("green.png", o.green_x, green_y, 34, 34)
  for i = 1,o.num_digits do
    o.digits[i] = txt_add("1", "font:lcd.ttf; size:70; color:black; halign:left;", 130+50*i, 160, 50, 80)
	visible(o.digits[i], false);
  end
  visible(o.led_img, false);
  o.visible = false;
  o.edit_digit = 1
  return o
end

function Programmable:start()
  visible(self.led_img, true)
  for i = 1,self.num_digits do
    visible(self.digits[i], true);
  end
  self.visible = true
  self.edit_digit = 1
end

function Programmable:exit()
  visible(self.led_img, false)
  for i = 1,self.num_digits do
    visible(self.digits[i], false);
  end
  self.visible = false
end

function Programmable:blink()
  if current ~= self then return end
  self.visible = not self.visible
  visible(self.digits[self.edit_digit], self.visible)
end

function Programmable:step(side)
  self.val_digits[self.edit_digit] = (self.val_digits[self.edit_digit] + side) % 10
  txt_set(self.digits[self.edit_digit], string.format("%01d", self.val_digits[self.edit_digit]))
end

function Programmable:prog_release(side)
  visible(self.digits[self.edit_digit], true)
  self.edit_digit = (self.edit_digit + side - 1) % (self.num_digits) + 1
  visible(self.digits[self.edit_digit], false)
end

green_flow = 78
green_rem = 158
green_used = 238
green_time = 317
green_aux = 398

flow_main = Display:new{text="flow", green_x=green_flow}
rem_main = Display:new{text="rem", green_x=green_rem}
used_main = Display:new{text="used", green_x=green_used}
time_main = Display:new{text="time", green_x=green_time}
aux_main = Display:new{text="Off", green_x=green_aux}

flow_alt = Display:new{text="hp", green_x=green_flow}
used_alt = Display:new{text="flight used", green_x=green_used}

add_blink = Display:new{text="Add", green_x=green_rem}
prog_rem = Programmable:new{num_digits=3, green_x=green_rem}

flow_main:insert(aux_main, rem_main, flow_alt, nil)
rem_main:insert(flow_main, used_main, nil, add_blink)
used_main:insert(rem_main, time_main, used_alt, nil)
time_main:insert(used_main, aux_main, nil, nil)
aux_main:insert(time_main, flow_main, nil, nil)

flow_alt:insert(aux_main, rem_main, flow_main)
used_alt:insert(rem_main, time_main, used_main)

add_blink:insert(nil, nil, prog_rem)
prog_rem:insert(nil, nil, nil, rem_main)

current = rem_main

function prog_rem:start()
  self.val_digits = {}
  local rem = string.format("%03d", math.floor(fuel_set - fuel_used))
  for i = 1, self.num_digits do
    local digit = rem:sub(i, i)
    self.val_digits[i] = tonumber(digit)
    txt_set(self.digits[i], digit)
  end
  Programmable.start(self)
end

function prog_rem:exit()
  local rem = 0
  local power = 1
  for i = self.num_digits, 1, -1 do
    rem = rem + self.val_digits[i] * power
	  power = power * 10
  end
  fuel_used = 0
  fuel_set = rem
  txt_set(rem_main.text_box, string.format("%.1f", fuel_set))
  txt_set(used_main.text_box, string.format("%.1f", 0))
  Programmable.exit(self)
end

function self_test_finished()
  visible(low_fuel_on, false)
  visible(hl_aux_on, false)
end

function initial_rem_blink()
  initial_rem_blink_state = not initial_rem_blink_state
  visible(current.led_img, initial_rem_blink_state)
end

function cancel_rem_blink()
  visible(current.led_img, true)
  timer_stop(initial_rem_blink_timer)
end


function step_left_press()
  if not power_on then return end
  cancel_rem_blink()
  current:step(-1)
end

function step_right_press()
  if not power_on then return end
  cancel_rem_blink()
  current:step(1)
end


prog_left_pressed = false
prog_right_pressed = false
prog_both_triggered = false

function prog_left_press()
  prog_left_pressed = true
  if prog_right_pressed then
    prog_both_triggered = true
    prog_both_press()
  end
  if not power_on then return end
  cancel_rem_blink()
end

function prog_left_release()
  prog_left_pressed = false
  prog_both_triggered = false
  if not power_on then return end
  current:prog_release(-1)
end

function prog_right_press()
  prog_right_pressed = true
  if prog_left_pressed then
    prog_both_triggered = true
    prog_both_press()
  end
  if not power_on then return end
  cancel_rem_blink()
end

function prog_right_release()
  prog_right_pressed = false
  prog_both_triggered = false
  if not power_on then return end
  current:prog_release(1)
end

function prog_both_press()
  if not power_on then return end
  cancel_rem_blink()
  current:prog_both()
end

function blink()
  add_blink:blink()
  prog_rem:blink()
end
blink_timer = timer_start(500, 500, blink)

--step_left_button = button_add(nil, nil, 219, 396, 37, 73, step_left_press, nil)
--step_right_button = button_add(nil, nil, 256, 396, 37, 73, step_right_press, nil)
--prog_left_button = button_add(nil, nil, 131, 396, 50, 50, prog_left_press, prog_left_release)
--prog_right_button = button_add(nil, nil, 329, 396, 50, 50, prog_right_press, prog_right_release)
--prog_both_button = button_add(nil, nil, 131, 469, 248, 50, prog_both_press, nil)

step_left_button = hw_button_add("RPI_V2_P1_16", step_left_press, nil)
step_right_button = hw_button_add("RPI_V2_P1_18", step_right_press, nil)
prog_left_pin = "RPI_V2_P22"
prog_right_pin = "RPI_V2_P1_12"
prog_left_button = hw_button_add(prog_left_pin, prog_left_press, prog_left_release)
prog_right_button = hw_button_add(prog_right_pin, prog_right_press, prog_right_release)

function new_fsx_volts(volts)
  if (not power_on and volts > 11) then
    power_on = true
	fuel_used_flight = 0
	visible(low_fuel_on, true)
	visible(hl_aux_on, true)
	current:start()
    self_test_timer = timer_start(2000, nil, self_test_finished)
	initial_rem_blink_timer = timer_start(1000, 1000, initial_rem_blink)
  elseif (power_on and volts < 10) then
    power_on = false
	visible(low_fuel_on, false)
	visible(hl_aux_on, false)
	current:exit()
	current = rem_main
    timer_stop(self_test_timer)
	timer_stop(initial_rem_blink_timer)
  end
end

function update_time_to_empty()
  local hours = (fuel_set - fuel_used) / flow
  local minutes = math.floor((hours % 1) * 60)
  txt_set(time_main.text_box, string.format("%.0f", hours)..":"..string.format("%02d", minutes))
end

function new_fsx_flow(a2a_flow, flow)
  if not power_on then return end
  flow = fif(a2a_flow ~= nil, a2a_flow, flow)
  txt_set(flow_main.text_box, string.format("%.1f", flow))
  txt_set(flow_alt.text_box, "HP"..string.format("%02d", math.floor(flow / (fuel_flow_75p * 1.786) * 75)))
  update_time_to_empty()
end

function new_fsx_fuel_quantity(gallons)
  if not power_on then return end
  local diff = fuel_actual - gallons
  if (diff > 0) then
    fuel_used = fuel_used + diff
	fuel_used = math.min(fuel_used, fuel_set)
	fuel_used_flight = fuel_used + diff
  end
  fuel_actual = gallons
  txt_set(rem_main.text_box, string.format("%.1f", fuel_set - fuel_used))
  txt_set(used_main.text_box, string.format("%.1f", fuel_used))
  txt_set(used_alt.text_box, "F "..string.format("%.1f", fuel_used))
  update_time_to_empty()
end

fsx_variable_subscribe("ELECTRICAL AVIONICS BUS VOLTAGE", "Volts", new_fsx_volts)
fsx_variable_subscribe("L:Eng1_GPH", "Gallons", "ENG FUEL FLOW GPH:1", "Gallons", new_fsx_flow)
fsx_variable_subscribe("FUEL TOTAL QUANTITY", "Gallons", new_fsx_fuel_quantity)

