#!/usr/bin/env lua

function love.load()
  snakeSize = 43
  scoreBoardHeight = 70
  fullWidth = snakeSize * 10
  fullHeight = snakeSize * 18 + scoreBoardHeight

  love.window.setTitle("Sn4keGame")
  love.window.setMode(
    fullWidth,
    fullHeight,
    { resizable = false, vsync = true }
  )

  snake = {}
  snake.pos = { 9, 17 }
  snake.parts = {}
  table.insert(snake.parts, snake.pos)

  snake.direction = ""
  snake.size = 1

  food = {}
  repeat
    food.pos = { math.random(0,10), math.random(0,16) }
  until food.pos[1] ~= 10 and food.pos[2] ~= 7

  speed = 0.3
  count = 0

  drawed = true
  updated = true

  red = 115/255
  green = 27/255
  blue = 135/255
  alpha = 50/100

  love.graphics.setBackgroundColor(red, green, blue, alpha)

  currentScore = 0
  nextScore = 100
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

      currentScore = currentScore + nextScore
      nextScore = 100
    else
      table.remove(snake.parts, 1)
    end

    for k, v in ipairs(snake.parts) do
      if k ~= #snake.parts then
        if v[1] == snake.pos[1] and v[2] == snake.pos[2] then love.load() end
      end
    end

    updated = true
  end
end

function love.draw()
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

  local font = love.graphics.newFont(40)

  love.graphics.printf(
    {{ 0/255, 0/255, 0/255 }, currentScore},
    font,
    fullWidth-100,
    scoreBoardHeight / 2 - 25,
    100,
    "right")

  love.graphics.setColor(255,0,0,1)
  love.graphics.rectangle(
    "fill",
    food.pos[1] * snakeSize,
    food.pos[2] * snakeSize + scoreBoardHeight,
    snakeSize,
    snakeSize,
    snakeSize)

  for k,v in ipairs(snake.parts) do
    if k == #snake.parts then
      love.graphics.setColor(255,255,255,1)
    else
      love.graphics.setColor(255,255,255,0.7)
    end

    love.graphics.rectangle(
      "fill",
      v[1] * snakeSize,
      v[2] * snakeSize + scoreBoardHeight,
      snakeSize - 1,
      snakeSize -1 )

    firstColor = false
  end

  drawed = true
end

function love.keypressed(key, scancode, isrepeat)
  local allowed_keys = {"up", "down", "left", "right"}

  if not contains(allowed_keys, key) then
    return
  end

  if not drawed or not updated then
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

  drawed = false
  updated = false

  snake.direction = key
end

function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end

  return false
end
