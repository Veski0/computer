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

collate()
for k,v in pairs(collation) do
  print(k, v)
end
