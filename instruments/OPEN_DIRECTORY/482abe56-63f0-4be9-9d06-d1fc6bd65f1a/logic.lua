img_add_fullscreen("trimback.png")
img_trim = img_add("trimindicator.png", 38, 145, 33, 10)
img_add_fullscreen("trimcover.png")

-- 20 = top
-- 170 = take off
-- 270 = bottom

function new_trim(trim)
	-- -1 = full nose down trim
	-- 0 = take off setting
	-- 1 = full nose down trim
	
	-- pixel range is 250
	move(img_trim, 38, 145 + (125 * var_cap(trim, -1, 1)), nil, nil)

end

function new_trim_fsx(trim)
	-- -0.43 = full nose down trim
	-- 0.43 = full nose up trim

	trim = trim
	new_trim(trim)
	
end

xpl_dataref_subscribe("sim/cockpit2/controls/elevator_trim", "FLOAT", new_trim)
fsx_variable_subscribe("ELEVATOR TRIM INDICATOR", "Position", new_trim_fsx)
