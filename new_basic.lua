local g = golly()
g.autoupdate(true)

local ov = g.overlay
ov("create 1000 1000")

local op = require "oplus"

Population = 10
TopPerformers = 2
CreatureRunTimeMS = 180000
SwapMutationOdd = 0.25
RandomResetOdd = 0.10
NumCellsMutateOdd = 0.15

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

function cloneCreature (creature)
  local creature2 = {}
  creature2.cellsPlaced = creature.cellsPlaced
  creature2.cellArray = creature.cellArray
  creature2.fitness = 0
  return creature2
end

function mutateCreature (creature)
  math.randomseed( g.millisecs() )
  for i=1, #creature.cellArray do
    -- Possible swap mutation
    if math.random <= SwapMutationOdd do
      local tempCoord = creature.cellArray[i]
      local swapIndex = math.random(1, #creature.cellArray)
      creature.cellArray[i] = creature.cellArray[swapIndex]
      creature.cellArray[swapIndex] = tempCoord
    end
    -- Possible random value mutation
    if math.random <= RandomResetOdd do
      local newVal = math.random(-100, 100)
      creature.cellArray[i] = newVal
    end
  end

  -- TODO: num cells mutation
  return creature
end

function executeCreature (creature)
  g.select( g.getrect() )
  g.clear(0)
  g.putcells(creature.cellArray, 0, 0)
end

epochCount = 0
-- The Epoch Lifecycle
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
