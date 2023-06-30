---@diagnostic disable: undefined-field
Path = tostring(arg[0])
IP = tostring(arg[1])
Port = tostring(arg[2])
Link = "ws://" .. IP .. ":" .. Port
Type = "Turtle"
Label = ""
Tool = { present = false, side = "", name = "" }
Modem = { present = false, side = "", wrap = "" }
Profession = ""
ID = os.getComputerID()
BroadcastNetwork = arg[3]
SetupComplete = false
function Setup()
	WS, Error = assert(http.websocket(Link))
	assert(WS, "Failed to establish a websocket connection!")
	Packet = { ["source"] = ID, ["destination"] = "server", ["data"] = "", ["type"] = "self-request" }
	SerializedPacket = textutils.serializeJSON(Packet)
	print("Request: " .. SerializedPacket)
	WS.send(SerializedPacket)
	Response, Binary = WS.receive()
	if type(Response) == "nil" then
		print("Websocket Connection timedout!")
	else
		print("Response: " .. Response)
	end
	if Response.data == nil then
		if peripheral.find("modem") ~= nil then
			Modem.present = true
		end
		print("Modem Present: " .. tostring(Modem.present))
		assert(peripheral.getType("left") == "modem" or peripheral.getType("right") == "modem",
			"There most be exactly 1 Wireless Modem and 1 Empty Slot!")
		if peripheral.getType("left") == "modem" then
			Modem.side = "left"
		elseif peripheral.getType("right") == "modem" then
			Modem.side = "right"
		end
		print("Modem Side: " .. Modem.side)
		Modem.wrap = peripheral.wrap(Modem.side)
		--Set Profession
		for i = 1, 16, 1 do
			print("Checking Inventory Slot " .. i .. " out of 16")
			if turtle.getItemCount(i) > 0 then
				print("Item Count: " .. turtle.getItemcount(i))
				ItemDetail = turtle.getItemDetail(i, true)
				SerializedItemDetail = textutils.serializedJSON(ItemDetail)
				print("Item Details: " .. SerializedItemDetail)
				local namepos = string.find(ItemDetail.name, ":", 1, true)
				print(namepos)
				local namestring = string.sub(ItemDetail.name, namepos + 1, -1)
				print(namestring)
				assert(string.match(ItemDetail.name, "minecraft:diamond"), "Must be a Diamond Minecraft Tool!")
				assert(not ItemDetail.enchantments, "Tool must be Unenchanted!")
				assert(not ItemDetail.damage, "Tool must be Undamaged!")
				if namestring == "diamond_shovel" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "digging"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
					break
				elseif namestring == "crafting_table" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "crafty"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
					break
				elseif namestring == "diamond_axe" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "felling"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
					break
				elseif namestring == "diamond_hoe" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "farming"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
					break
				elseif namestring == "diamond_pickaxe" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "mining"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
					break
				elseif namestring == "diamond_sword" then
					print("Found a " .. ItemDetail.name .. " in slot " .. i)
					Profession = "melee"
					print("Profession: " .. Profession)
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						else
							Tool.present = true
							print("Tool Present: " .. tostring(Tool.present))
							Tool.side = "right"
							print("Tool Side: " .. Tool.side)
							Tool.name = ItemDetail.name
							print("Tool Name: " .. Tool.name)
						end
					end
				end
			end
		end
		print("Tool Present: " .. tostring(Tool.present))
		print("Tool Side: " .. Tool.side)
		print("Tool Name: " .. Tool.name)
		os.setComputerLabel(Profession .. " | " .. tostring(ID))
		print("Label: " .. Label)
		--Join Network
		assert(Modem.isWireless, "We cant work with a wired Modem, replace it with a Whireless Modem!")
		Modem.open(BroadcastNetwork)
		Modem.transmit("Device " .. Label .. "(" .. ID .. ")" .. " joined the Broadcast Network!")
		print("Joined Broadcast Network " .. BroadcastNetwork)
		--Broadcast Setup Summary
		TurtleMetaData = { ["type"] = "Turtle", ["label"] = Label,
			["modem"] = { ["present"] = Modem.present, ["side"] = Modem.side }, ["profession"] = Profession,
			["setup_complete"] = SetupComplete }
		Packet = { ["source"] = ID, ["destination"] = "server", ["data"] = TurtleMetaData, ["type"] = "setup-notice" }
		SerializedPacket = textutils.serializeJSON(Packet)
		http.get(SerializedPacket)
	else
		--Placeholder
	end
end

function Preperations() end

function Main() end

OK, Error = pcall(function()
	Setup()
	--Preperations()
	--Main()
end)
if not OK then
	--No more writing Errors to Monitors, Error Files or sending it to the Server.
	--Now we just print it to the current Device Display.
	if Modem.present and Modem.wrap ~= "" then
	else
		printError(Error)
	end
	--shell.run(Path,IP,Port,BroadcastNetwork)
end
