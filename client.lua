U = require("utils")
os.loadAPI("json")

collation = {}
collation["minecraft:coal_ore"]=0
collation["minecraft:iron_ore"]=0
collation["minecraft:gold_ore"]=0
collation["minecraft:diamond_ore"]=0
items = {
  "minecraft:coal_ore",
  "minecraft:iron_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore"
}

items_count = U.table_length(items)
collate = function ()
  for i = 1, 16 do
    local j = turtle.getItemDetail(i)
    if j ~= nil then
      if U.contains(items, j.name) then
        collation[j.name] = collation[j.name] + j.count
      end
    end
  end
end

report = function (s)
  rednet.open("left")
  rednet.send(0, s, 'report')
  rednet.close("left")
end

function can_fit_item(name)
  can_fit = false
  for i = 1, 16 do
    if turtle.getItemSpace(i) == 64 then
      -- There is an empty space.
      return true
    end
    if turtle.getItemSpace(i) > 0 then
      -- There is space in this slot.
      item = turtle.getItemDetail(i)
      if name == item.name then
        -- There is space for name in this slot.
        return true
      end
    end
  end
  return can_fit
end

y = 13
chunk_miner_pro = function ()
  while y > 6 do
    slab_miner_pro()

    collate()
    report(json.encode(collation))

    turnRight(1)
    mine_forward(15)
    mine_down(1)
    y = y - 1
  end
end

slab_miner_pro = function ()
  lines = 16
  turn = true
  while lines > 0 do
    mine_forward(15)
    if turn then
      turn_right()
    else
      turn_left()
    end
    turn = not turn
    lines = lines - 1
  end
end

mine_forward = function (blocks)
  local forward = blocks
  while forward > 0 do
    local success, data = turtle.inspect()
    if success then
      space = can_fit_item(data.name)
      if space then
        turtle.dig()
      else
        report(json.encode('turtle is full'))
        print('Waiting to be emptied.')
        read()
      end
    end
    turtle.forward()
    forward = forward - 1
  end
end

mine_down = function (blocks)
  local down = blocks
  while down > 0 do
    local success, data = turtle.inspectDown()
    if success then
      space = can_fit_item(data.name)
      if space then
        turtle.digDown()
      else
        report(json.encode('turtle is full'))
        print('Waiting to be emptied.')
        read()
      end
    end
    turtle.down()
    down = down - 1
  end
end

turn_right = function ()
  turtle.turnRight()
  mine_forward(1)
  turtle.turnRight()
end

turn_left = function ()
  turtle.turnLeft()
  mine_forward(1)
  turtle.turnLeft()
end

chunk_miner_pro()
