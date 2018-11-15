
background = img_add_fullscreen("ff_background.png")

--mode enum
mode_flow_hp = 1
mode_rem = 2
mode_used = 3
mode_t_to_e = 4
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
green_x_vals[mode_t_to_e] = 317
green_x_vals[mode_aux] = 398

red_y = 39

initial_rem_blink_state = true
mode = mode_rem
option = option_main
left_press = false
right_press = false
needs_update = false
double_prog = false
fuel_remaining = persist_add("fuel_remaining", "INT[3]", {0, 3, 4})

green_on = img_add("ff_green.png", green_x_vals[mode_rem], green_y, 34, 34)
low_fuel_on = img_add("ff_red.png", 193, red_y, 37, 37)
hl_aux_on = img_add("ff_red.png", 278, red_y, 37, 37)

main_text = {}
alternate_text = {}
for i = mode_flow_hp,mode_aux do
  main_text[i] = txt_add("","",x,y,400,100)
  visible(main_text[i], false)
  alternate_text[i] = txt_add("","",x,y,400,100)
  visible(alternate_text[i], false)
end
visible(main_text[mode_rem], true)
txt_set(main_text[mode_aux], "OFF")

prog_fuel_digits = {}
for i = 1,3 do
  prog_fuel_digits[i] = txt_add("", x,y,100,100)
  visible(prog_fuel_digits[i], false)
end


function self_test_finished()
  visible(low_fuel_on, false)
  visible(hl_aux_on, false)
end

function initial_rem_blink()
  initial_rem_blink_state = ~initial_rem_blink_state
  visible(green_on, initial_rem_blink_state)
end

function cancel_rem_blink()
  visible(green_on, true)
  timer_stop(initial_rem_blink_timer)
end

function main_step_handler(step)
  visible(main_text[mode], false)
  visible(alternate_text[mode], false)
  
  mode = mode + step
  if (mode < mode_flow_hp) then
    mode = mode_aux
  elseif (mode > mode_aux) then
    mode = mode_flow_hp
  end
  option = option_main

  visible(main_text[mode], true)
  move(green_on, green_x_vals[mode], green_y)
end

function main_prog_release_handler(side)
  if (left_press or right_press) then
    return
  end
  if (double_prog) then
    double_prog = false
    return
  end
  option = fif(option == option_main, option_alternate, option_main)
  visible(main_text[mode], option == option_main)
  visible(alternate_text[mode], option == option_alternate)
end

function maybe_enter_prog()
  if (not (left_press and right_press) then
    return
  end
  double_prog = true
  if (mode == mode_rem) then
    option = option_program
  end
end

step_handlers = {}
step_handlers[option_main] = main_step_handler
step_handlers[option_alternate] = main_step_handler

prog_release_handlers = {}
prog_release_handlers[option_main] = main_prog_release_handler
prog_release_handlers[option_alternate] = main_prog_release_handler

function render()
  if (not needs_update) then
    return
  end
  move(green_on, green_x_vals[mode], green_y)

  for i = mode_flow_hp,mode_aux do
    visible(main_text[i], i == mode and option == option_main)
  end

  for i = mode_flow_hp,mode_aux do
    visible(alternate_text[i], i == mode and option == option_alternate)
  end

  for i = 1,3 do
    visible(prog_fuel_digits[i], option == option_program)
  end
  
  needs_update = false
end

function prog_blink()
  if (option ~=
end

function step_left_press()
  cancel_rem_blink()
  step_handlers[mode](-1)
  needs_update = true
end

function step_right_press()
  cancel_rem_blink()
  step_handlers[mode](1)
  needs_update = true
end

function prg_left_press()
  cancel_rem_blink()
  left_press = true
  maybe_enter_prog()
  needs_update = true
end

function prg_left_release()
  left_press = false
  prog_release_handlers[mode](1)
  needs_update = true
end

function prg_right_press()
  cancel_rem_blink()
  right_press = true
  maybe_enter_prog()
  needs_update = true
end

function prg_right_release()
  right_press = false
  prog_release_handlers[mode](-1)
  needs_update = true
end

self_test_timer = timer_start(2000, nil, self_test_finished)
initial_rem_blink_timer = timer_start(1000, 1000, initial_rem_blink)
render_timer = timer_start(50, 50, render)

