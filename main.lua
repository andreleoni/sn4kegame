#!/usr/bin/env lua

function love.load()
  snakeSize = 43
  scoreBoardHeight = 70
  fullWidth = snakeSize * 10
  fullHeight = snakeSize * 17 + scoreBoardHeight
  if maxScore == nil then
    maxScore = 0
  end

  love.window.setTitle("Sn4keGame")
  love.window.setMode(
    fullWidth,
    fullHeight,
    { resizable = false, vsync = true }
  )

  snake = {}
  snake.pos = { 9, 16 }
  snake.parts = {}
  table.insert(snake.parts, snake.pos)

  snake.direction = ""
  snake.lastKeyDirection = ""
  snake.size = 1

  food = {}
  repeat
    food.pos = { math.random(0,10), math.random(0,16) }
  until food.pos[1] ~= 10 and food.pos[2] ~= 7

  speed = 0.3
  count = 0

  currentScore = 0
  nextScore = 100

  snakeSprite = love.graphics.newImage("src/images/snake.png")
  background = love.graphics.newImage("src/images/grass.png")

  sortNewFruit()
end

function isEmpty(pos)
  for k, v in ipairs(snake.parts) do
    if pos[1] == v[1] and pos[2] == v[2] then return nil end
  end
  return true
end

function love.update(dt)
  count = count + 1.2 * dt

  if count > speed then
    snake.direction = snake.lastKeyDirection

    if nextScore > 10 then
      nextScore = nextScore - 3
    else
      nextScore = 10
    end

    count = 0

    if snake.direction == "up" then
      snake.pos[2] = snake.pos[2] - 1 < 0 and 16 or snake.pos[2] - 1
    elseif snake.direction == "down" then
      snake.pos[2] = snake.pos[2] + 1 >= 17 and 0 or snake.pos[2] + 1
    elseif snake.direction == "left" then
      snake.pos[1] = snake.pos[1] - 1 < 0 and 9 or snake.pos[1] - 1
    elseif snake.direction == "right" then
      snake.pos[1] = snake.pos[1] + 1 >= 10 and 0 or snake.pos[1] + 1
    end

    table.insert(snake.parts, {snake.pos[1], snake.pos[2]})

    if food.pos[1] == snake.pos[1] and food.pos[2] == snake.pos[2] then
      repeat
        food.pos = {math.random(0,9), math.random(0,16)}
      until isEmpty(food.pos)

      speed = speed - 0.005 < 0.08 and 0.08 or speed - 0.005

      sortNewFruit()
      currentScore = currentScore + nextScore
      nextScore = 100
    else
      table.remove(snake.parts, 1)
    end

    for k, v in ipairs(snake.parts) do
      if k ~= #snake.parts then
        if v[1] == snake.pos[1] and v[2] == snake.pos[2] then
          if maxScore < currentScore then
            maxScore = currentScore
          end

          love.load()
        end
      end
    end
  end
end

function love.draw()
  for i = 0, love.graphics.getWidth() / background:getWidth() do
    for j = 0, love.graphics.getHeight() / background:getHeight() do
        love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
    end
  end

  love.graphics.setColor(255, 255, 255, 1)
  love.graphics.rectangle("fill", 0, 0, fullWidth, scoreBoardHeight)

  local titleFont = love.graphics.newFont(30)

  love.graphics.printf(
    {{ 0/255, 0/255, 0/255 }, "Sn4keGame"},
    titleFont,
    5,
    scoreBoardHeight / 2 - 20,
    200,
    "right")

  local scoreboardSize = love.graphics.newFont(40)

  love.graphics.printf(
    {{ 0/255, 0/255, 0/255 }, currentScore},
    scoreboardSize,
    fullWidth-100,
    scoreBoardHeight / 2 - 25,
    100,
    "right")

    local scoreboardSize = love.graphics.newFont(14)
    love.graphics.printf(
      {{ 0/255, 0/255, 0/255 }, "Recorde: "..maxScore},
      scoreboardSize,
      fullWidth-100,
      scoreBoardHeight / 2 + 15,
      100,
      "right")

  love.graphics.draw(
    currentFoodSprite,
    food.pos[1] * snakeSize + 5,
    food.pos[2] * snakeSize + scoreBoardHeight + 5)

  for k,v in ipairs(snake.parts) do
    if k == #snake.parts then
      local spritRight = snakeSize * 4
      local spritDown = 0

      if snake.direction == "up" then
        spritRight = snakeSize * 3
        spritDown = 0
      elseif snake.direction == "down" then
        spritRight = snakeSize * 3
        spritDown = snakeSize
      elseif snake.direction == "left" then
        spritRight = snakeSize * 4
        spritDown = snakeSize
      end

      curSnakeSprite = love.graphics.newQuad(
        spritRight,
        spritDown,
        snakeSize,
        snakeSize,
        snakeSprite:getDimensions())

      love.graphics.draw(
        snakeSprite,
        curSnakeSprite,
        v[1] * snakeSize,
        v[2] * snakeSize + scoreBoardHeight)
    else

      -- Fix logic related with the sprite of snake
      local spritRight = snakeSize * 3
      local spritDown = 0

      if k == 1 then
        if v[1] > v[2] then
          spritRight = snakeSize
        elseif v[1] == v[2] then
          spritRight = snakeSize * 2
        end
      end

      curSnakeSprite = love.graphics.newQuad(
        spritRight,
        spritDown,
        snakeSize,
        snakeSize,
        snakeSprite:getDimensions())

      love.graphics.draw(
        snakeSprite,
        curSnakeSprite,
        v[1] * snakeSize,
        v[2] * snakeSize + scoreBoardHeight)
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  local allowed_keys = {"up", "down", "left", "right"}

  if not contains(allowed_keys, key) then
    return
  end

  if snake.direction == "up" and key == "down" then
    return
  elseif snake.direction == "down" and key == "up" then
    return
  elseif snake.direction == "left" and key == "right" then
    return
  elseif snake.direction == "right" and key == "left" then
    return
  end

  snake.lastKeyDirection = key
end

function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end

  return false
end

function sortNewFruit()
  fruits = {"apple", "burger", "carrot", "cherry", "egg", "fries", "ham", "pizza", "strawberry", "sushi", "watermelon"}

  getFruidFromIndex = math.random(1, #fruits)
  currentFoodSprite = love.graphics.newImage("src/images/"..fruits[getFruidFromIndex]..".png")
end
