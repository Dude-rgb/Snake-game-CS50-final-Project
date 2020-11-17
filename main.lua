--[[ import libraries ]]--
inteligence = require 'Decision'  -- import our Decision algorithm
push = require 'push'             -- import push library
-----------------------------------------------------------------------------------------------------------------------

--[[ create dimensions ]]--
WINDOW_WIDTH = 1280 -- Real width
WINDOW_HEIGHT = 720 -- Real height

VIRTUAL_WIDTH = 432  -- Virtual width
VIRTUAL_HEIGHT = 243 -- Virtual height


--[[ create a varible with a value initial ]]--
state = 'initial' -- this variable set the state of the game
initial_state = '' -- this variable set the state to the invicible time when game was started

--[[ set initial directions in the x and y axis ]]--
direction = 'left' -- this variable set the direction of the snake

--[[ Score ]]--
score = 0 -- this variable stores the Score of the game

--[[ position of the snake ]]--
x = math.floor(VIRTUAL_WIDTH / 2)  -- stores the x position of snake --> initialize in the center of window
y = math.floor(VIRTUAL_HEIGHT / 2) -- stores the y position of snake --> initialize in the center of window

--[[ apple position ]]--
x_apple = math.random(30, VIRTUAL_WIDTH - 30) -- randomize the x position of the apple
y_apple = math.random(30, VIRTUAL_HEIGHT - 30) -- randomize the y position of the apple

--[[ size of snake ]]--
SIZE = 4 -- a Constant --> stores the width and height of the snake

--[[ Velocity ]]--
increment = 1 -- Velocity of the snake

--[[ mechanism to make the syrup move ]]--
tail = {} -- table to the tail
oldx = 0  -- old x position
oldy = 0  -- old y position

--[[ fakes apples ]]--
fake = {} -- stores the fake apples positions

--[[ timers ]]--
timer_current = 0 -- stores the current time in the game
current_invincible = 0 -- stores the current time in the invincible moment

-----------------------------------------------------------------------------------------------------------------------
function love.load()
    --[[ set a window filter ]]--
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --[[ set the Title of the game ]]--
    love.window.setTitle('Snake game')

    --[[ get fonts ]]--
    FONT = love.graphics.newFont('fonts/font.ttf', 32)      -- Big    size
    MediumFONT = love.graphics.newFont('fonts/font.ttf', 16)-- Medium size

    --[[ set default FONT ]]--
    love.graphics.setFont(FONT)

    --[[ set a seed to random ]]--
    math.randomseed(os.time()) -- this random is based on the time

    --[[ obstacles sprites ]]--
    obstacles = {
        ['banana'] = love.graphics.newImage('assets/banana.png'),    -- banana      sprite
        ['apple'] = love.graphics.newImage('assets/apple.png'),      -- apple       sprite
        ['scenario'] = love.graphics.newImage('assets/scenario.png'),-- background  sprite
        ['fast1'] = love.graphics.newImage('assets/fast1.png'),      -- x2 obstacle sprite
        ['fast2'] = love.graphics.newImage('assets/fast2.png')       -- x3 obstacle sprite
    }

    --[[ sounds ]]--
    sounds = {
        ['apple'] = love.audio.newSource('sounds/coin01.wav', 'static'),  -- get apple  sound
        ['banana'] = love.audio.newSource('sounds/key01.wav', 'static'),  -- get banana sound
        ['died'] = love.audio.newSource('sounds/jump01.wav', 'static')    -- died       sound
    }
    --[[ setup the screen options ]]--
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

end

function love.keypressed(key)
    --[[ quit the game ]]--
    if key == 'escape' then
        love.event.quit() -- quit game

    --[[ human player ]]--
    elseif key == 'return' or key == 'kpenter' and state == 'initial' then
        create_fakes() -- create fake apples and bananas
        state = 'play' -- change state to human play
        initial_state = 'invincible' -- change initial_state to invincible when game is started

    --[[ ai player ]]--
    elseif key == 'space' and state == 'initial' then
        create_fakes() -- create fake apples and bananas
        state ='ai'    -- change state to ai play
        initial_state = 'invincible' -- change initial_state to invincible when game is started


    --[[ back to the initial screen ]]--
    elseif key == 'backspace' then
        state = 'initial' -- change to initial screen (with the initial state)
        reset() -- reset variables
    end
end

function reset()
    --[[ reset all variables ]]--
    -- set all to default
    score = 0
    x = math.floor(VIRTUAL_WIDTH / 2)
    y = math.floor(VIRTUAL_HEIGHT / 2)
    x_apple = math.random(20, VIRTUAL_WIDTH - 62)
    y_apple = math.random(20, VIRTUAL_HEIGHT - 20)
    tail = {}
    increment = 1
    direction = 'left'
    timer_current = 0
    history = 0
    initial_state = ''
    current_invincible = 0
end


function love.update(dt)
    --[[
        if is a human player
        check the keyboard and update the direction variable
    ]]--
    if state == 'play' then
        if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
            direction = 'up'
        elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
            direction = 'down'
        elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
            direction = 'left'
        elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
            direction = 'right'
        end
    end

    if state ~= 'win' and state ~= 'gameover' and state ~= 'initial' then
        --[[ timer ]]--
        -- check if game was started and init the invincible time else count the five seconds to die
        if initial_state == 'invincible' then
            current_invincible = current_invincible + dt -- update tthe invincible time
        else
            timer_current = timer_current + dt -- update the current time
        end

        -- check if current time is equal 5 if true and is not invincible then game over
        if math.floor(timer_current) == 5 and initial_state ~= 'invincible' then
            state = 'gameover'    -- change state to gameover
            sounds['died']:play() -- play died sound
        -- check if is invincible time and current time is 3 seconds, if true then modify the initial_state variable and go to the 5 seconds time
        elseif math.floor(current_invincible) == 3 and initial_state == 'invincible' then
            initial_state = '' -- change initial state if invincible time is done
        end
    end
end


function create_fakes()
    --[[
        this function is responsible to create fake apples and bananas
    ]]--
    for i=1, 10 do
        -- create fake apples positions and put him into the fake table
        fake[i] = {math.random(30, VIRTUAL_WIDTH - 30), math.random(30, VIRTUAL_HEIGHT - 30)}
    end
    for i=11,21 do
        -- create bananas positions and put him into the fake table
        fake[i] = {math.random(30, VIRTUAL_WIDTH - 30), math.random(30, VIRTUAL_HEIGHT - 30)}
    end

end

function create_obstacles()
    --[[
        create the fast1 and fast2 obstacles
    ]]--

    -- create fast1
    local positions_fast1 = {{130, 120}, {300, 94}, {230, 190}}
    for _, v in ipairs(positions_fast1) do
        love.graphics.draw(obstacles['fast1'], v[1], v[2])
	end

    --create fast2
	local positions_fast2 = {{35, 165}, {150, 45}, {200, 100}}
	for _, v in ipairs(positions_fast2) do
        love.graphics.draw(obstacles['fast2'], v[1], v[2])
	end
end

function check_obstacles_collides()

    --[[
        this function check if snake is colliding with an obstacle
    ]]--

    -- check if colliding with fast1
    if (x >= 130 and y >= 120 and x <= 155 and y >= 120 and x <= 155 and y <= 145 and x >= 130 and y <= 145 ) or (x >= 300 and y >= 94 and x <= 325 and y >= 94  and x <= 325 and y <= 119 and x >= 300 and y <= 119 ) or (x >= 230 and y >= 190 and x <= 255 and y >= 190 and x <= 255 and y <= 215 and x >= 230 and y <= 215 ) then
        increment = 2 -- change velocity for 2
    -- check if colling with fast2
    elseif (x >= 35 and y >= 165 and x <= 60 and y >= 165 and x <= 60 and y <= 190 and x >= 35 and y <= 190) or (x >= 150 and y >= 45 and x <= 175 and y >= 45 and x <= 175 and y <= 70 and x >= 150 and y <= 70) or (x >= 200 and y >= 100 and x <= 225 and y >= 100 and x <= 225 and y <=125  and x >= 200 and y <= 125) then
        increment = 3 -- change velocity for 3
    else
    -- if is not colliding change the volocity to default
        increment = 1 -- chage to default velocity
    end

    for i=11,21 do
        -- check all bananas positions and check if snake is colliding with one and is not invincible time
        if x + 10 >= fake[i][1] and x - 10 <= fake[i][1] and y + 12 >= fake[i][2] and y - 12 <=fake[i][2] and initial_state ~= 'invincible' then
            score = score - 1 -- remove 1 to score
            x_apple = math.floor(math.random(20, VIRTUAL_WIDTH - 62)) -- rand
            y_apple = math.floor(math.random(20, VIRTUAL_HEIGHT - 20))
            table.remove(tail, 1)
            if score > -1 then
                sounds['banana']:play()
            end
            create_fakes()
        end
    end
end


function snake_state()


    -- check if is a human player ou an ai player
    if state == 'play' or state =='ai' then
        -- set the olds position
        oldx = x -- get oldx position before x position did been modified
        oldy = y -- get oldy position before y position did been modified

        --[[ check the direction and add the increment ]]--
        if direction == 'left' then
            x = x - increment
            rotate = 3
        elseif direction == 'right' then
            x = x + increment
        elseif direction == 'up' then
            y = y - increment
        elseif direction == 'down' then
            y = y + increment
        end

        --[[
            check if the snake has been catched the apple
            if has been catched increase the tail
        ]]--
        if x + 8 >= x_apple and x - 8 <= x_apple and y + 8 >= y_apple and y - 8 <=y_apple then
            score = score + 1
            x_apple = math.floor(math.random(20, VIRTUAL_WIDTH - 62))
            y_apple = math.floor(math.random(20, VIRTUAL_HEIGHT - 20))
            table.insert(tail, {0, 0})
            sounds['apple']:play()
            create_fakes()
            timer_current = 0
        end

        --[[ check if snake has been died ]]--
        if x > VIRTUAL_WIDTH or x < 0 or y < 0 or y > VIRTUAL_HEIGHT or score < 0 then
            state = 'gameover'
            sounds['died']:play()
        end

        --[[ update snake tail ]]--
        if score > 0 then
            for _, v in ipairs(tail) do
                local snakeX, snakeY = v[1], v[2]
                v[1], v[2] = oldx, oldy
                oldx, oldy = snakeX, snakeY
            end
        end

        --[[ check the max pontuation ]]--
        if score == 999 then
            state = 'win'
        end
    end
end



function ai()
    --[[
        when state is ai this function will be called
        this function will be call the snake_state function and update direction with the Decision library
    ]]--
    snake_state()
    direction = inteligence.Decision(x, y, x_apple, y_apple, increment) -- return a direction and put into the direction variable
end


function love.draw()
    --[[ draw all ]]--
    push:apply('start') -- start the game
    --love.graphics.clear(40/255, 45/255, 52/255, 255/255) -- put a background color
    love.graphics.draw(obstacles['scenario'], 0, 0)

    --[[ initial state game ]]--
    if state == 'initial' then
        love.graphics.setFont(FONT)
        love.graphics.printf('Press Enter to play', 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Space to ai play', 0, 140, VIRTUAL_WIDTH, 'center')


    --[[ ai or play state ]]--
    elseif state =='ai' or state == 'play' then
        create_obstacles()
        check_obstacles_collides()
        love.graphics.setFont(MediumFONT)
        love.graphics.print('SCORE', VIRTUAL_WIDTH - 65, 20)
        love.graphics.print(score, VIRTUAL_WIDTH - 50, 40)
        love.graphics.print('TIMER', VIRTUAL_WIDTH - 65, 60)
        love.graphics.print(math.floor(timer_current), VIRTUAL_WIDTH - 50, 80)

        love.graphics.rectangle('fill', x, y, SIZE, SIZE)
        for _, v in ipairs(tail) do
            love.graphics.rectangle('fill', v[1], v[2], SIZE, SIZE)
        end
		--love.graphics.draw(obstacles['banana'], x_1_apple, y_1_apple)
		--love.graphics.rectangle('fill', x_apple, y_apple, SIZE, SIZE)

		love.graphics.draw(obstacles['apple'], x_apple, y_apple)


        for i=1, 10 do
            love.graphics.draw(obstacles['apple'], fake[i][1], fake[i][2])
        end
        for i=11, 21 do
            love.graphics.draw(obstacles['banana'], fake[i][1], fake[i][2])
        end



    --[[ game over state ]]--
    elseif state == 'gameover' then
        increment = 0
        love.graphics.setFont(FONT)
        love.graphics.setColor(255, 0, 0, 1)
        love.graphics.printf('GAME OVER!', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press BackSpace to restart', 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Your score was ' .. score, 0, 140, VIRTUAL_WIDTH, 'center')


    --[[ win state ]]--
    elseif state == 'win' then
        increment = 0
        love.graphics.setFont(FONT)
        love.graphics.setColor(0, 0, 255, 1)
        love.graphics.printf('CONGRATULATIONS YOU WIN!', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press BackSpace to restart', 0, 100, VIRTUAL_WIDTH, 'center')
    end

    if initial_state == 'invincible' and state ~= 'gameover' and state ~= 'win' then
        love.graphics.print('INVINCIBLE', VIRTUAL_WIDTH - 95, 100)
        love.graphics.print(math.floor(current_invincible), VIRTUAL_WIDTH - 50, 120)
    end

    --[[ check state and redirect to the ai or snake_state function ]]--
    if state == 'play' then
        snake_state()
    elseif state =='ai' then
        ai()
    end

    --[[ end the game ]]--
    push:apply('end')

end
