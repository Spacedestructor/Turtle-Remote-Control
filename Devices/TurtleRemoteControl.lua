---@diagnostic disable: undefined-field
Websocket = "ws://127.0.0.1:3000"
Webserver = "ws://127.0.0.1:3001"
Type = "Turtle"
Label = ""
Modem = { present = false, side = "", wrap = "" }
Profession = ""
ID = os.getComputerID()
BroadcastNetwork = "0"
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
print("Modem Present: " .. tostring(Modem.present) .. ", Side: " .. Modem.side)
--Hardcoded Instructions
local websocket, err = assert(http.websocket(Websocket))
while websocket do
	local event, url, message, binary = os.pullEvent()
	if event == "websocket_message" then
		message = textutils.unserializeJSON(message)
		if message.destination == os.getComputerID() then
			if message.type == "instruction" and message.data == "GetInventory" then
			elseif message.type == "instruction" and message.data == "GetProfession" then
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
									Profession = "digging"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "digging"
								end
							end
						elseif string.match(ItemDetail.name, "crafting_table") ~= nil then
							turtle.select(i)
							if peripheral.ispresent("right") and not peripheral.ispresent("left") then
								Status, Reason = turtle.equipRight()
								if not Status then
									print(Reason)
								else
									Profession = "crafty"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "crafty"
								end
							end
						elseif string.match(ItemDetail.name, "diamond_axe") ~= nil then
							turtle.select(i)
							if peripheral.ispresent("right") and not peripheral.ispresent("left") then
								Status, Reason = turtle.equipRight()
								if not Status then
									print(Reason)
								else
									Profession = "felling"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "felling"
								end
							end
						elseif string.match(ItemDetail.name, "diamond_hoe") ~= nil then
							turtle.select(i)
							if peripheral.ispresent("right") and not peripheral.ispresent("left") then
								Status, Reason = turtle.equipRight()
								if not Status then
									print(Reason)
								else
									Profession = "farming"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "farming"
								end
							end
						elseif string.match(ItemDetail.name, "diamond_pickaxe") ~= nil then
							turtle.select(i)
							if peripheral.ispresent("right") and not peripheral.ispresent("left") then
								Status, Reason = turtle.equipRight()
								if not Status then
									print(Reason)
								else
									Profession = "mining"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "mining"
								end
							end
						elseif string.match(ItemDetail.name, "diamond_sword") ~= nil then
							turtle.select(i)
							if peripheral.ispresent("right") and not peripheral.ispresent("left") then
								Status, Reason = turtle.equipRight()
								if not Status then
									print(Reason)
								else
									Profession = "melee"
								end
							elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
								Status, Reason = turtle.equipLeft()
								if not Status then
									print(Reason)
								else
									Profession = "melee"
									os.setComputerLabel = tostring(ID) .. Profession
								end
							end
						end
					end
				end
				Packet = { ["source"] = ID, ["destination"] = "server", ["data"] = Profession, ["type"] = "GetProfession-Response" }
				SerializedPacket = textutils.serializeJSON(Packet)
				websocket.send(SerializedPacket)
			end
		end
	elseif event == "websocket_closed" then
		print(event .. ", the websocket to " .. url .. " closed. Reason: " .. message .. " (" .. binary .. ")")
		websocket, err = assert(http.websocket(Websocket))
	end
end
--Old Part
os.setComputerLabel(Label .. " " .. tostring(ID))
print("Label: " .. Label)
--Join Network
assert(Modem.isWireless, "We cant work with a wired Modem, replace it with a Whireless Modem!")
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
