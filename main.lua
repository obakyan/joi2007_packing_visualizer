local mfl, mce = math.floor, math.ceil
local mmi = math.min
local msq = math.sqrt
local rnd = math.random
local xc, yc = {}, {}
local n = 11
local curscore = 0

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
  end
  curscore = getscore()
end

local function challenge()
  local idx = rnd(1, n)
  local px, py = xc[idx], yc[idx]
  local range = 0.05
  xc[idx] = xc[idx] + range * (rnd() - 0.5)
  yc[idx] = yc[idx] + range * (rnd() - 0.5)
  local nxtscore = getscore()
  if curscore <= nxtscore then
    curscore = nxtscore
  else
    xc[idx], yc[idx] = px, py
  end
end
function love.update(dt)
  local z = os.clock()
  while os.clock() - z < dt do
    challenge()
  end
end

function love.draw()
  local w = 500
  love.graphics.print("" .. curscore, 0, 0)
  for i = 1, n do
    local x, y = xc[i], yc[i]
    love.graphics.circle("line", x * w, y * w, curscore * w)
  end
end
