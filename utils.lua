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
