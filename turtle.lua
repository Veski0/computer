---------------------------------------
-- File     : turtle.lua             --
-- Author   : Veski_                 --
-- Version  : Veski_                 --
-- Purpose  : Mine chunks, report    --
-- progress back to a server.        --
--                                   --
--                                   --
--                                   --
--                                   --
--                                   --
---------------------------------------

-- Dependencies                      --
U = require("utils")

-- Tables                            --
strings = {}
strings["turtle_name"] =
"Name this turtle:\nλ: "
strings["modem_direction"] =
"Locate the modem:\nλ: "
strings["report_frequency"] =
"Turtle report frequency:\nλ: "
strings["current_y"] =
"Current turtle Y value:\nλ: "
strings["chosen_protocol"] =
"Communications protocol:\nλ: "
items = {
  "minecraft:coal_ore",
  "minecraft:iron_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore"
}

-- Functions                         --

-- Function: collate
-- Purpose : collate inventory against.
-- an array of interesting items.
-- Args    : nil
-- Returns : {Collation}
items_count = U.table_length(items)
collate = function ()
  local c = {}
  for i = 0, items_count do
    c[items[i]] = 0
  end
  for i = 1, 16 do
    local j = turtle.getItemDetail(i)
    if j ~= nil then
      if U.contains(items, j.name) then
        c[j.name] = c[j.name] + 1
      end
    end
  end
  return c
end
---------------------------------------

-- Function: initialise
-- Purpose : generate config table.
-- Args    : nil
-- Returns : {ConfigTable}
initialise = function ()
  local c = {}
  for i = 1, 11 do
    print("")
  end
  print("TurtleUI λ: initialisation.")
  print("")
  write(strings.turtle_name)
  c["turtle_name"] = read()
  write(strings.modem_direction)
  c["modem_direction"] = read()
  write(strings.report_frequency)
  c["report_frequency"] = read()
  write(strings.current_y)
  c["current_y"] = tonumber(read())
  write(strings.chosen_protocol)
  c["chosen_protocol"] = read()
  return c
end
---------------------------------------

-- Function: chunk_miner
-- Purpose : mine a chunk. delicious.
-- Args    : {ConfigTable}
-- Returns : nil
slabs = 0
chunk_miner = function (cnf)
  while cnf.current_y > 5 do
    miner_slab(cnf)
    slabs = slabs + 1
    local is_free = turtle.detectDown()
    if not is_free then
      turtle.digDown()
      turtle.down()
    else
      turtle.down()
    end
    cnf.current_y = cnf.current_y - 1
    print("Progress report due!")
  end
  print("Done")
end
---------------------------------------

-- Function: miner_slab
-- Purpose : mine a slab. delicious.
-- Args    : {ConfigTable}
-- Returns : nil
miner_slab = function (cnf)
  local forward  = 0
  local sideways = 0
  local slabbed = false
  while not slabbed do
    local is_free = turtle.detect()
    if sideways ~= 15 then
      if forward ~= 15 then
        if not is_free then
          turtle.dig()
          turtle.forward()
        else
          turtle.forward()
        end
        forward = forward + 1
      else
        forward = 0
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()
        sideways = sideways + 1
      end
    else
      slabbed = true
    end
  end
end
---------------------------------------

-- Execution                         --
config = initialise()
chunk_miner(config)
