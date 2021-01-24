os.loadAPI("json")

rednet.open("top")
while true do
  senderId, message, protocol = rednet.receive("report")
  print('turtle '..senderId..' said '..json.decode(message))
end
rednet.close("top")
