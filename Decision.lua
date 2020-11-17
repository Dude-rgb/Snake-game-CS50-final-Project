Module = {} -- create a Module table to insert our functions

function Decision(x, y, x_a, y_a, vel)
  	--[[
    	This function make the decision of the direction based on actual snake position and actual apple position
    	looking if the new direction make the snake be near to the apple

    	Arguments:
    	x   --> actual x snake position
    	y   --> actual y snake position
    	x_a --> actual x apple position
    	y_a --> actual y apple position
  	]]--
	local returnable = 'left' -- default return direction

	local h = math.abs(y - y_a)                -- height the snake to the apple y position
	local b_plus = math.abs((x + vel) - x_a)   -- distance of the snake plus the speed the lower the position of the apple
	local b_minus = math.abs((x - vel) - x_a)  -- distance of the snake less the speed the lower the position of the apple

	local controler = false  -- controler variable if true the snake is locked on obstacle

	if x == x_a and not controler then -- check if apple is in the same x position of the snake
		if math.abs((y + vel) - y_a) < math.abs((y - vel) - y_a) then -- check if snake goes down, her is get more near by the apple
			returnable = 'down'
		else
			returnable = 'up'
		end

	elseif y == y_a and not controler then -- check if apple is in the same y position of the snake
		if math.abs((x + vel) - x_a) < math.abs((x - vel) - x_a) then -- check if snake goes to the right her is get more near by the apple
			returnable = 'right'
		else
			returnable = 'left'
		end
	end

	if x ~= x_a and y ~= y_a and not controler then -- check if snake have all positions different of the apple and her is not locked
	-- checks if the diagonal (hypotenuse) between the mace and the snake with x + speed is less than with the x - speed position
		if math.sqrt(h ^ 2 + b_minus ^ 2) < math.sqrt(h ^ 2 + b_plus ^ 2) then
			returnable = 'left'
		else

			returnable = 'right'
		end

		if (((x >= 130 and y >= 120 and x <= 155 and y >= 120 and x <= 155 and y <= 145 and x >= 130 and y <= 145 ) or
			(x >= 300 and y >= 94 and x <= 325 and y >= 94  and x <= 325 and y <= 119 and x >= 300 and y <= 119 ) or
			(x >= 230 and y >= 190 and x <= 255 and y >= 190 and x <= 255 and y <= 215 and x >= 230 and y <= 215 ) )
			) or
			(((x >= 35 and y >= 165 and x <= 60 and y >= 165 and x <= 60 and y <= 190 and x >= 35 and y <= 190) or
			(x >= 150 and y >= 45 and x <= 175 and y >= 45 and x <= 175 and y <= 70 and x >= 150 and y <= 70) or
			(x >= 200 and y >= 100 and x <= 225 and y >= 100 and x <= 225 and y <=125  and x >= 200 and y <= 125))) and
			((x % 2 == 0 and x_a % 2 == 1) or (x % 2 == 1 and x_a % 2 == 0)) then -- check if the snake is locked

			local t = math.abs(x - x_a)

			if x < x_a and t >= 2 then
				returnable = 'right'

			elseif x > x_a and t >= 2 then
				returnable = 'left'

			elseif t < 2 then
				if y > y_a then
					returnable = 'up'
				else
					returnable = 'down'
				end
			end
			controler = true

		else
			controler = false
		end

	end

  	return returnable



end

-- put the functions into the module table
Module.Decision = Decision -- put D function into the module table

return Module -- return the Module table containing the functions
