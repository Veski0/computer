-- Constants                         --
-- Valid Modem Directions
modem_directions = {
 "up", "down",
 "left", "right",
 "bottom", "top"
}
---------------------------------------

-- Functions                         --

-- Function: contains
-- Purpose : array contains item?
-- Args    : {Table, Element}
-- Returns : {Boolean}
contains = function (tab, val)
  for index, value in ipairs(tab) do
    if value == value then
      return true
    end
  end
  return false
end
---------------------------------------

-- Function: table_length
-- Purpose : calculate length of table.
-- Args    : {Table}
-- Returns : {Number}
table_length = function (t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end
---------------------------------------

return {
  modem_directions=modem_directions,
  contains=contains,
  table_length=table_length
}


-- https://tinyurl.com/yygmu9pt

------------------------------------------------------------------ utils
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}

local function isArray(t)
	local max = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		elseif k > max then
			max = k
		end
	end
	return max == #t
end

local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
function removeWhite(str)
	while whites[str:sub(1, 1)] do
		str = str:sub(2)
	end
	return str
end

------------------------------------------------------------------ encoding

local function encodeCommon(val, pretty, tabLevel, tTracking)
	local str = ""

	-- Tabbing util
	local function tab(s)
		str = str .. ("\t"):rep(tabLevel) .. s
	end

	local function arrEncoding(val, bracket, closeBracket, iterator, loopFunc)
		str = str .. bracket
		if pretty then
			str = str .. "\n"
			tabLevel = tabLevel + 1
		end
		for k,v in iterator(val) do
			tab("")
			loopFunc(k,v)
			str = str .. ","
			if pretty then str = str .. "\n" end
		end
		if pretty then
			tabLevel = tabLevel - 1
		end
		if str:sub(-2) == ",\n" then
			str = str:sub(1, -3) .. "\n"
		elseif str:sub(-1) == "," then
			str = str:sub(1, -2)
		end
		tab(closeBracket)
	end

	-- Table encoding
	if type(val) == "table" then
		assert(not tTracking[val], "Cannot encode a table holding itself recursively")
		tTracking[val] = true
		if isArray(val) then
			arrEncoding(val, "[", "]", ipairs, function(k,v)
				str = str .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		else
			arrEncoding(val, "{", "}", pairs, function(k,v)
				assert(type(k) == "string", "JSON object keys must be strings", 2)
				str = str .. encodeCommon(k, pretty, tabLevel, tTracking)
				str = str .. (pretty and ": " or ":") .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		end
	-- String encoding
	elseif type(val) == "string" then
		str = '"' .. val:gsub("[%c\"\\]", controls) .. '"'
	-- Number encoding
	elseif type(val) == "number" or type(val) == "boolean" then
		str = tostring(val)
	else
		error("JSON only supports arrays, objects, numbers, booleans, and strings", 2)
	end
	return str
end

function encode(val)
	return encodeCommon(val, false, 0, {})
end

function encodePretty(val)
	return encodeCommon(val, true, 0, {})
end

------------------------------------------------------------------ decoding

local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end

function parseNull(str)
	return nil, removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end

function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end

function parseArray(str)
	str = removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseObject(str)
	str = removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end

function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end

function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

function decodeFromFile(path)
	local file = assert(fs.open(path, "r"))
	local decoded = decode(file.readAll())
	file.close()
	return decoded
end

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

    -- collate()
    report(json.encode(collation))

    turtle.turnRight()
    mine_forward(2)
    mine_down(1)
    y = y - 1
  end
end

slab_miner_pro = function ()
  lines = 3
  turn = true
  while lines > 0 do
    mine_forward(2)
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