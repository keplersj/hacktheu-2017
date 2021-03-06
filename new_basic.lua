local g = golly()
g.autoupdate(true)

local ov = g.overlay
ov("create 1000 1000")

local op = require "oplus"

Population = 10
TopPerformers = 1
CreatureRunTimeMS = 1 * 60 * 1000
SwapMutationOdd = 0.25
RandomResetOdd = 0.10
NumCellsMutateOdd = 0.15
StagnantGenerationCutoff = 200

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
  return ((popSize * area) / startPop) + math.log10(startPop)
end

-- Creates an initial creature with vary stupid defaults.
function createCreature ()
  local creature = {}
  creature.cellsPlaced = 0
  creature.cellArray = {}
  creature.fitness = 0.0
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
      local newVal = math.random(-50, 50)
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
      table.insert(creature.cellArray, math.random(-50, 50) )
      table.insert(creature.cellArray, math.random(-50, 50) )
    elseif cellChangeVal < 0 then
      for i = 1, cellChangeVal * -1 do
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

  startPop = tonumber( g.getpop() )

  local lastPop = g.getpop()
  local generationsStagnant = 0
  local creatureFitness = 0

  local startTime = g.millisecs()
  while (g.millisecs() - startTime  < CreatureRunTimeMS) do
    if g.empty() then
      op.maketext( "Fitness: " .. calcFitness(), "fitness")
      op.pastetext(500, 0, op.identity, "fitness")
      break
    end
    if lastPop == g.getpop() then
      if generationsStagnant == StagnantGenerationCutoff then
        creature.fitness = calcFitness()
        return creature
      else
        generationsStagnant = generationsStagnant + 1
      end
    else
      generationsStagnant = 0
    end

    g.fit()
    g.step()

    op.maketext( "Fitness: " .. calcFitness(), "fitness")
    op.pastetext(500, 0, op.identity, "fitness")

    lastPop = g.getpop()
  end

  creature.fitness = calcFitness()

  return creature
end

function table.clone(org)
  return {table.unpack(org)}
end

epochCount = 0
creatures = {}
eliteCreatures = {}

for creatureIndex = 1, Population do
  creatures[creatureIndex] = createCreature()
end

for creatureIndex = 1, TopPerformers do
  eliteCreatures[creatureIndex] = createCreature()
end

-- The Epoch Lifecycle
while true do
  epochCount = epochCount + 1

  op.maketext( "Epoch: " .. epochCount, "epoch")
  op.pastetext(0, 0, op.identity, "epoch")

  local highestFitness = 0

  for creatureIndex = 1, #creatures do
    g.new("epoch_".. epochCount .. "_creature_" .. creatureIndex)

    op.maketext( "Creature: " .. creatureIndex, "creature")
    op.pastetext(250, 0, op.identity, "creature")

    local mutatedCreature = mutateCreature(creatures[creatureIndex])

    local executedCreature = executeCreature(mutatedCreature)
    creatures[creatureIndex] = executedCreature

    if executedCreature.fitness > highestFitness then
      highestFitness = executedCreature.fitness
    end

    op.maketext( "Epoch Max: " .. highestFitness, "epochMaxFit")
    op.pastetext(500, 25, op.identity, "epochMaxFit")

    op.maketext( "Elite fitness: " .. eliteCreatures[1].fitness, "elitefitness")
    op.pastetext(250, 25, op.identity, "elitefitness")

  end

  for eliteIndex = 1, TopPerformers do
    local fittestIndex = 1
    for creatureIndex = 1, #creatures do
      if creatures[creatureIndex].fitness > creatures[fittestIndex].fitness then
        fittestIndex = creatureIndex
      end
    end

    for savedEliteIndex = 1, TopPerformers do
      if creatures[fittestIndex].fitness > eliteCreatures[savedEliteIndex].fitness then
        
        eliteCreatures[savedEliteIndex].cellsPlaced = creatures[fittestIndex].cellsPlaced
        eliteCreatures[savedEliteIndex].fitness = creatures[fittestIndex].fitness
        for i = 1, #creatures[fittestIndex].cellArray do
          eliteCreatures[savedEliteIndex].cellArray[i] = creatures[fittestIndex].cellArray[i]
        end
        break
      end
    end
  end

  for creatureIndex = 1, #creatures do
    creatures[creatureIndex] = eliteCreatures[1]
  end

  ov("delete epoch")
  ov("delete creature")
  ov("delete fitness")
end
