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

-- Creates an initial creature with vary stupid defaults.
function createCreature ()
  local creature = {}
  creature.cellsPlaced = 0
  creature.cellArray = {}
  creature.fitness = 0
  return creature
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
    if math.random() <= SwapMutationOdd then
      local tempCoord = creature.cellArray[i]
      local swapIndex = math.random(1, #creature.cellArray)
      creature.cellArray[i] = creature.cellArray[swapIndex]
      creature.cellArray[swapIndex] = tempCoord
    end
    -- Possible random value mutation
    if math.random() <= RandomResetOdd then
      local newVal = math.random(-100, 100)
      creature.cellArray[i] = newVal
    end
  end

  if math.random() <= NumCellsMutateOdd then
    local cellChangeVal = math.random(-2, 2)
    creature.cellsPlaced = creature.cellsPlaced + cellChangeVal
    if creature.cellsPlaced < 0 then
      creature.cellsPlaced = 0
    end
    if cellChangeVal > 0 then
      table.insert(creature.cellArray, math.random(-100, 100) )
      table.insert(creature.cellArray, math.random(-100, 100) )
    elseif cellChangeVal < 0 then
      for i = 0, cellChangeVal * -1 do
        table.remove(creature.cellArray, #creature.cellArray)
      end
    end
  end
  return creature
end

function executeCreature (creature)
  op.maketext( "Creature Cell Place Count: " .. creature.cellsPlaced, "creature")
  op.pastetext(0, 25, op.identity, "creature")

  local rect = g.getrect()
  if #rect >= 1 then
    g.select( g.getrect() )
    g.clear(0)
  end
  
  if (#creature.cellArray >= 1 and #creature.cellArray % 2 == 0) then
    g.putcells(creature.cellArray, 0, 0)
  end
  
  run()
end

epochCount = 0
creatures = {}

for creatureIndex = 1, Population do
  creatures[creatureIndex] = createCreature()
end

-- The Epoch Lifecycle
while true do
  epochCount = epochCount + 1

  op.maketext( "Epoch: " .. epochCount, "epoch")
  op.pastetext(0, 0, op.identity, "epoch")

  for creatureIndex = 1, #creatures do
    op.maketext( "Creature: " .. creatureIndex, "creature")
    op.pastetext(250, 0, op.identity, "creature")

    local creature = mutateCreature(creatures[creatureIndex])
    creatures[creatureIndex] = creature

    executeCreature(creature)
  end

  ov("delete epoch")
  ov("delete creature")
  ov("delete fitness")
end
