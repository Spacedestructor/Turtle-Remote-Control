---@diagnostic disable: undefined-field
Path = tostring(arg[0])
IP = tostring(arg[1])
Port = tostring(arg[2])
Link = "ws://" .. IP .. ":" .. Port
Type = "Turtle"
Label = ""
Modem = {present = false, side = "", wrap = ""}
Profession = ""
ID = os.getComputerID()
BroadcastNetwork = arg[3]
SetupComplete = false
function Setup()
	--Check if Setup was already Completed before
	Packet = {["source"] = ID, ["destination"] = "server", ["data"] = "", ["type"] = "self-request"}
	SerializedPacket = textutils.serializeJSON(Packet)
	print("Self Request: " .. SerializedPacket)
	Response = http.get(Link,Packet)
	local responsestring = ""
	if type(Response) == "nil" then
		responsestring = tostring(Response)
	else
		responsestring = textutils.serializeJSON(Response)
	end
	print("Response: " .. responsestring)
	if Response == nil then
		--Get Peripherals
		if peripheral.find("modem") ~= nil then
			Modem.present = true
		end
		assert(peripheral.getType("left") == "modem" or peripheral.getType("right") == "modem", "There most be exactly 1 Wireless Modem and 1 Empty Slot!")
		if peripheral.getType("left") == "modem" then
			Modem.side = "left"
		elseif peripheral.getType("right") == "modem" then
			Modem.side = "right"
		end
		assert(Modem.side == "left" or "right", "We somehow failed to save what side the Modem is on, after defining what side it is?")
		Modem.wrap = peripheral.wrap(Modem.side)
		print("Modem Present: " .. tostring(Modem.present) .. ", Side: " .. Modem.side)
		--Set Profession
		for i = 1, 16, 1 do
			if turtle.getItemCount(i) > 0 then
				ItemDetail = textutils.serializeJSON(turtle.getItemDetail(i, true))
				if string.match(ItemDetail.name, "shovel") ~= nil then
					Profession="digging"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						end
					end
				elseif string.match(ItemDetail.name, "crafting_table") ~= nil then
					Profession="crafty"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						end
					end
				elseif string.match(ItemDetail.name, "axe") ~= nil then
					Profession = "felling"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						end
					end
				elseif string.match(ItemDetail.name, "hoe") ~= nil then
					Profession = "farming"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						end
					end
				elseif string.match(ItemDetail.name, "pickaxe") ~= nil then
					Profession = "mining"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then
							print(Reason)
						end
					end
				elseif string.match(ItemDetail.name, "sword") ~= nil then
					Profession="melee"
					turtle.select(i)
					if peripheral.ispresent("right") and not peripheral.ispresent("left") then
						Status, Reason = turtle.equipRight()
						if not Status then
							print(Reason)
						end
					elseif peripheral.isPresent("left") and not peripheral.ispresent("right") then
						Status, Reason = turtle.equipLeft()
						if not Status then print(Reason)
						end
					end
				end
			end
		end
		os.setComputerLabel(Label .. " " .. tostring(ID))
		print("Label: " .. Label)
		--Join Network
		assert(Modem.isWireless, "We cant work with a wired Modem, replace it with a Whireless Modem!")
		Modem.open(BroadcastNetwork)
		Modem.transmit("Device " .. Label .. "(" .. ID .. ")" .. " joined the Broadcast Network!")
		print("Joined Broadcast Network " .. BroadcastNetwork)
		--Broadcast Setup Summary
		TurtleMetaData = {["type"] = "Turtle", ["label"] = Label, ["modem"] = { ["present"] = Modem.present, ["side"] = Modem.side }, ["profession"] = Profession, ["setup_complete"] = SetupComplete }
		Packet = {["source"] = ID, ["destination"] = "server", ["data"] = TurtleMetaData, ["type"] = "setup-notice"}
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
