local g = golly()

-- local ov = g.overlay
-- ov("create 1000 1000")

-- local op = require "oplus"

-- local fitness = 0

local startTime = g.millisecs()
while (g.millisecs() - startTime  < 300000) do		
  if g.empty() then
    break
  end

  g.fit()
  g.step()
  
  -- op.maketext("Fitness: " .. fitness, "log", "rgba 0 0 0 255")
end