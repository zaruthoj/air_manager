img_add_fullscreen("verticalspeed.png")
img_needle = img_add_fullscreen("needle.png")

---------------
-- Functions --
---------------
function new_vs(fpm)
	
	fpm = var_cap(fpm, -2000, 2000)

	if fpm >= 0 and fpm < 500 then
		img_rotate(img_needle, 30 / 500 * fpm)
	elseif fpm >= 500 and fpm < 1000 then
		img_rotate(img_needle, (50 / 500 * (fpm - 500)) + 30)
	elseif fpm >= 1000 then
		img_rotate(img_needle, (95 / 1000 * (fpm - 1000)) + 80)
	elseif fpm < 0 and fpm > -500 then
		img_rotate(img_needle, 30 / 500 * fpm)
	elseif fpm <= -500 and fpm > -1000 then
		img_rotate(img_needle, (50 / 500 * (fpm + 500)) - 30)
	elseif fpm <= -1000 then
		img_rotate(img_needle, (95 / 1000 * (fpm + 1000)) - 80)
	end
end

-------------------
-- Bus subscribe --
-------------------
fsx_variable_subscribe("VERTICAL SPEED", "Feet per minute", new_vs)