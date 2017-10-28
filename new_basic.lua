local g = golly()
g.autoupdate(true)

local ov = g.overlay
ov("create 1000 1000")

local op = require "oplus"

Population = 10
TopPerformers = 2
CreatureRunTimeMS = 180000

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
  while (g.millisecs() - startTime  < CreatureRunTimeMS) do
    if g.empty() then
      op.maketext( "Fitness: " .. calcFitness(), "fitness")
      op.pastetext(500, 0, op.identity, "fitness")
      break
    end

    g.fit()
    g.step()

    op.maketext( "Fitness: " .. calcFitness(), "fitness")
    op.pastetext(500, 0, op.identity, "fitness")
  end
end

epochCount = 0

-- The Epoch Lifestyle
while true do
  epochCount = epochCount + 1
  op.maketext( "Epoch: " .. epochCount, "epoch")
  op.pastetext(0, 0, op.identity, "epoch")
  for creatureIndex = 1, Population do
    op.maketext( "Creature: " .. creatureIndex, "creature")
    op.pastetext(250, 0, op.identity, "creature")
    run()
  end
  ov("delete epoch")
  ov("delete creature")
  ov("delete fitness")
end
