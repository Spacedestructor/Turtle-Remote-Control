---@diagnostic disable: undefined-field
Adress = "ws://127.0.0.1:3000"
Type = "Turtle"
Label = ""
Modem = { present = false, side = "", wrap = "" }
Profession = ""
ID = os.getComputerID()
BroadcastNetwork = "0"
Tool = ""
Fuel = {
	max = turtle.getFuelLimit(),
	current = turtle.getFuelLevel(),
	name = "",
	FuelPerItem = 0
}
Packet = { ["source"] = ID, ["destination"] = "server", ["data"] = "", ["type"] = "" }
SerializedPacket = textutils.serializeJSON(Packet)
--Get Peripherals
if peripheral.find("modem") ~= nil then
	Modem.present = true
end
assert(peripheral.getType("left") == "modem" or peripheral.getType("right") == "modem",
	"There most be exactly 1 Wireless Modem and 1 Empty Slot!")
if peripheral.getType("left") == "modem" then
	Modem.side = "left"
elseif peripheral.getType("right") == "modem" then
	Modem.side = "right"
end
assert(Modem.side == "left" or "right",
	"We somehow failed to save what side the Modem is on, after defining what side it is?")
Modem.wrap = peripheral.wrap(Modem.side)
assert(Modem.wrap.isWireless(), "Modem has to be Wireless for this Script to work!")
print("Modem Present: " .. tostring(Modem.present) .. ", Side: " .. Modem.side)
--Hardcoded Instructions
local websocket, err = assert(http.websocket(Adress))
while true do
	local event, url, message, binary = os.pullEvent()
	if event == "websocket_message" then
		message = textutils.unserializeJSON(message)
		if message.type == "GetDeviceData" then
			local DeviceData = {
				Label,
				Profession,
				Tool,
				Modem,
				BroadcastNetwork,
				Fuel,
				Type
			}
			Text = textutils.serializeJSON(DeviceData)
			textutils.slowPrint(Text, 5)
		elseif message.type == "GetProfession" then
			for i = 1, 16, 1 do
				if turtle.getItemCount(i) > 0 then
					ItemDetail = textutils.serializeJSON(turtle.getItemDetail(i, true))
					if string.match(ItemDetail.name, "diamond_shovel") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Digging"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Digging"
							end
						end
					elseif string.match(ItemDetail.name, "crafting_table") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Crafty"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Crafty"
							end
						end
					elseif string.match(ItemDetail.name, "diamond_axe") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Felling"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Felling"
							end
						end
					elseif string.match(ItemDetail.name, "diamond_hoe") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Farming"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Farming"
							end
						end
					elseif string.match(ItemDetail.name, "diamond_pickaxe") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Mining"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Mining"
							end
						end
					elseif string.match(ItemDetail.name, "diamond_sword") ~= nil then
						turtle.select(i)
						if peripheral.ispresent("right") and not peripheral.ispresent("left") then
							Status, Reason = turtle.equipRight()
							if not Status then
								print(Reason)
							else
								Profession = "Melee"
							end
						elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
							Status, Reason = turtle.equipLeft()
							if not Status then
								print(Reason)
							else
								Profession = "Melee"
								os.setComputerLabel = tostring(ID) .. Profession
							end
						end
					end
				end
			end
			Packet = {
				["source"] = ID,
				["destination"] = "server",
				["data"] = Profession,
				["type"] = "GetProfession-Response"
			}
			SerializedPacket = textutils.serializeJSON(Packet)
			websocket.send(SerializedPacket)
		end
	elseif event == "websocket_closed" then
		print(event .. ", the websocket to " .. url .. " closed. Reason: " .. message .. " (" .. binary .. ")")
		os.reboot()
	end
end
--Old Part
--Join Network
Modem.open(BroadcastNetwork)
Modem.transmit("Device " .. Label .. "(" .. ID .. ")" .. " joined the Broadcast Network!")
print("Joined Broadcast Network " .. BroadcastNetwork)
--Broadcast Setup Summary
TurtleMetaData = {
	["type"] = "Turtle",
	["label"] = Label,
	["modem"] = { ["present"] = Modem.present, ["side"] = Modem.side },
	["profession"] = Profession
}
Packet = { ["source"] = ID, ["destination"] = "server", ["data"] = TurtleMetaData, ["type"] = "setup-notice" }
SerializedPacket = textutils.serializeJSON(Packet)
http.get(SerializedPacket)
