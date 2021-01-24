U = require("utils")

items = {
  "minecraft:coal_ore",
  "minecraft:iron_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore"
}

report = function (s)
  rednet.open("back")
  rednet.send(0, s, 'report')
  rednet.close("back")
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

y = 13
chunk_miner_pro = function ()
  while y > 6 do
    slab_miner_pro()
    mine_down(1)
    y = y - 1
    report('turtle mined a slab')
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
    turn = !turn
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
        report('turtle is full')
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
        report('turtle is full')
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
