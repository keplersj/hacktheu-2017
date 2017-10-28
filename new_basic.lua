local g = golly()
g.autoupdate(true)

local ov = g.overlay
ov("create 1000 1000")

local op = require "oplus"

-- fitness is function of pop size vs. initial and area covered
function calcFitness ()
 local popSize = tonumber( g.getpop() )
 local rectArr = g.getrect()
 local area = 0
 if #rectArr >= 1 then
    area = rectArr[3] * rectArr[4]
  end
  if startPop == 0 then
    return 0
  end
  return (popSize * area) / startPop
end

function run ()
  local fitness = 0
  startPop = tonumber( g.getpop() )

  local startTime = g.millisecs()
  -- 3 minutes = 180000
  while (g.millisecs() - startTime  < 180000) do
    if g.empty() then
      op.maketext( "Fitness: " .. calcFitness())
      op.pastetext(0, 0)
      break
    end

    g.fit()
    g.step()

    op.maketext( "Fitness: " .. calcFitness())
    op.pastetext(0, 0)
  end
end

run()
  -- take top 2
