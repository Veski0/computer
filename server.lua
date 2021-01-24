rednet.open("top")
while true do
  senderId, message, protocol = rednet.receive("report")
  print('turtle '..senderId..' said '..message)
end
rednet.close("top")
