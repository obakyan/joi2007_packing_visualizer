local n = 17
local mfl, mce = math.floor, math.ceil
local mmi, mma = math.min, math.max
local msq = math.sqrt
local rnd = math.random
local xc, yc = {}, {}
local curscore = 0
local step = 0
local maxscore = 0
local max_xc, max_yc = {}, {}

local function getlen(i, j)
  return msq((xc[i] - xc[j]) * (xc[i] - xc[j]) + (yc[i] - yc[j]) * (yc[i] - yc[j]))
end

local function getscore()
  local ret = 0.5
  for i = 1, n do
    ret = mmi(ret, xc[i], 1 - xc[i], yc[i], 1 - yc[i])
  end
  for i = 1, n - 1 do
    for j = i + 1, n do
      ret = mmi(ret, getlen(i, j) / 2)
    end
  end
  return ret
end

function love.load()
  math.randomseed(48)
  local sq = mce(msq(n))
  for i = 1, n do
    xc[i] = (1 + 2 * (i % sq)) / 2 / sq
    yc[i] = (2 * mce(i / sq) - 1) / 2 / sq
    xc[i] = rnd()
    yc[i] = rnd()
  end
  -- xc[1] = 0.18768061 yc[1] = 0.81231939
  -- xc[2] = 0.81231939 yc[2] = 0.50000000
  -- xc[3] = 0.60410646 yc[3] = 0.18768060
  -- xc[4] = 0.18768061 yc[4] = 0.18768061
  -- xc[5] = 0.39589354 yc[5] = 0.50000000
  -- xc[6] = 0.60410647 yc[6] = 0.81231940
  curscore = getscore()
end

local function special_challenge()
  for im = 1, n do
    local idx = rnd(1, n)
    local px, py = xc[idx], yc[idx]
    local range = 0.1
    xc[idx] = mma(0, mmi(1, xc[idx] + range * (rnd() - 0.5)))
    yc[idx] = mma(0, mmi(1, yc[idx] + range * (rnd() - 0.5)))
    local nxtscore = getscore()
    curscore = nxtscore
    xc[idx], yc[idx] = px, py
    if maxscore < curscore then
      maxscore = curscore
      for i = 1, n do
        max_xc[i] = xc[i]
        max_yc[i] = yc[i]
      end
    end
  end
end

local function challenge()
  step = step + 1
  if step % 1000000 == 0 then
    special_challenge()
    step = 0
    return
  end
  local idx = rnd(1, n)
  local px, py = xc[idx], yc[idx]
  local range = 0.02
  xc[idx] = mma(0, mmi(1, xc[idx] + range * (rnd() - 0.5)))
  yc[idx] = mma(0, mmi(1, yc[idx] + range * (rnd() - 0.5)))
  local nxtscore = getscore()
  if curscore <= nxtscore then
    curscore = nxtscore
  else
    xc[idx], yc[idx] = px, py
  end
  if maxscore < curscore then
    maxscore = curscore
    for i = 1, n do
      max_xc[i] = xc[i]
      max_yc[i] = yc[i]
    end
  end
end
function love.update(dt)
  local z = os.clock()
  local limit = 0.1
  while os.clock() - z < limit do
    challenge()
  end
end

function love.draw()
  local w = 500
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("" .. curscore, 0, 0)
  -- love.graphics.print("" .. step, 0, 30)
  for i = 1, n do
    local x, y = xc[i], yc[i]
    love.graphics.circle("line", x * w, y * w, curscore * w)
  end
  love.graphics.setColor(0.1, 0, 0.3)
  love.graphics.rectangle("fill", 500, 0, 200, 500)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("max score", 500, 0)
  love.graphics.print(tostring(maxscore), 500, 24)
  love.graphics.print("press [s] to save", 500, 48)
end

function love.keypressed(key, scancode, rep)
  if key == "s" then
    local f = io.open("out_n" .. n .. ".lua", "w")
    f:write("-- https://github.com/obakyan/joi2007_packing_visualizer\n")
    f:write("-- " .. string.format("%.12f", maxscore) .. "\n")
    for i = 1, n do
      f:write("print(\""
        .. mfl(xc[i] * 100000000 + 0.5) .. " "
        .. mfl(yc[i] * 100000000 + 0.5) .. "\")\n")
    end
    f:close()
  end
end
