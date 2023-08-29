//Turtle Controls:
//craft(limit)
//forward()
//back()
//up()
//down
//turnLeft()
//turnRight()
//dig(side)
//digUp(side)
//digDown(side)
//place(text)
//placeUp(text)
//placeDown(text)
//drop(count)
//dropUp(count)
//dropDown(count)
//select(slot)
//getItemCount(slot)
//getItemSpace(slot)
//detect()
//detectUp()
//detectDown()
//compare()
//compareUp()
//compareDown()
//attack(side)
//attackUp(side)
//attackDown(side)
//suck(count)
//suckUp(count)
//suckDown(count)
//getFuelLevel()
//refuel(count)
//compareTo(slot)
//transferTo(slot, count)
//getSelectedSlot()
//getFuelLimit()
//equipLeft()
//equipRight()
//inspect()
//inspectUp()
//inspectDown()
//getItemDetail(slot, detailed)
//"Content-Type: application/json"
//0.0.0.0:0
//255.255.255.255:65536
//Check if the Turtle is already Registered.
//if yes set web ui to last known info, if no keep web ui empty until the data has been retrieved from the turtle.
//in both cases update as the respective commands are used.
//a turtle should always start as an empty advanced turtle with wireless modem peripheral.
//all required items (fuel, tools etc.) should be in the turtles inventory.
//Get Turtle Peripherals
//Set Profession
//function GetMaxFuelLevel() {}
//function GetCurrentFuelLevel() {}
//function Refuel() {}
//function getInventory() {}
//function GetHeight() {}
//function Box() {}
//function ParseBlockID(BlockID) { var parsed = { source : "", material : "", variant : ""} if (BlockID.includes(":") && BlockID("_")) { parsed.source = BlockID.slice(0, BlockID.indexOf(":")-1) return parsed} else {return "Invalid Block ID"}}
const hostName = "127.0.0.1"
const hostPort = 3000
const socket = require("ws")
var webSocket = new socket.Server({ host: hostName, port: hostPort })
var devices = require("./Devices.json")
const fs = require("fs")
//Parameter must be a File as string. Will return retrieved data without any further Processing.
function load_from_file(file) {
	try {
		var data = fs.readFileSync(file)
		return data
	} catch (error) {
		console.error(error)
		throw error
	}
}
//First Parameter must be a File as String, Second Parameter must be the data to be saved. Wont do any further Processing before saving. Will return true if operation was successful.
function write_to_file(file, data) {
	try {
		fs.writeFileSync(file, data)
		return true
	} catch (error) {
		console.error(error)
		throw error
	}
}
devices = load_from_file("Devices.json")
if (Object.keys(devices).length > 0) {
	devices = JSON.parse(devices)
	console.debug(devices)
} else {
	console.info("Devices List Empty!")
}
var clients = []
var requestQueue = {}
//Creates a 128-bit value. Taken from https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
function create_UUID() {
	var dt = new Date().getTime();
	var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
		var r = (dt + Math.random() * 16) % 16 | 0;
		dt = Math.floor(dt / 16);
		return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
	});
	return uuid;
}
function HandlePackets(serializedRequest, wsClient, wsRequest) {
	var request = JSON.parse(serializedRequest.toString())
	console.debug(request)
	switch (request.type) {
		case "GetDeviceData":
			//var request = { [] }
			//requestQueue = requestQueue + request
			//console.debug(requestQueue)
			var deviceID = Number(request.data)
			var deviceData = devices[deviceID]
			var packet = { ["source"]: "server", ["destination"]: "server", ["data"]: deviceData, ["type"]: "GetTurtleData-Response" }
			packet = JSON.stringify(packet)
			console.debug(packet)
			wsClient.send(packet)
			break
		case "Identify":
			//Example JSON: "UUID": { "ip": "127.0.0.1:3002", "type": "Client", "id": "" }
			if (request.source == "client") {
				var client = { ["uuid"]: create_UUID(), ["ip"]: wsRequest.socket.remoteAddress, ["port"]: wsRequest.socket.remotePort }
				clients.push(client)
				console.debug(clients)
				//deviceList = JSON.parse(devices)
				console.debug(Object.keys(devices).length)
				if (Object.keys(devices).length == 0) {
					var deviceList = { "0": { "label": "Test Computer", "modem": { "side": "right", "present": true, "type": "Wireless" }, "broadcastNetwork": 0, "type": "Computer", "id": 0 }, "4": { "label": "Test Pocket", "modem": { "side": "right", "present": true, "type": "Wireless" }, "broadcastNetwork": 0, "type": "Pocket", "id": 4 }, "5": { "label": "Test Turtle", "profession": "Miner", "tool": "minecraft:diamond_pickaxe", "modem": { "side": "right", "present": true, "type": "Wireless" }, "broadcastNetwork": 0, "fuel": { "max": 0, "current": 0, "name": "minecraft:coal", "fuelPerItem": 0 }, "type": "Turtle", "id": 5 } }
					devices = JSON.stringify(deviceList)
					write_to_file("Devices.json", devices)
				}
				console.debug(devices)
				console.debug(JSON.parse(devices))
				console.debug(Object.keys(devices).length)
				//console.debug(devicelist)
				//var packet = {}
				//wsClient.send()
			}
			break
		default:
			if (request.type != undefined) {
				console.error(`Unknown Packet Type: ${request.type}! ${serializedRequest}`)
			} else {
				console.error(`Unknown Packet structure: ${serializedRequest}`)
			}
			break
	}
}
webSocket.on("connection", (wsClient, wsRequest) => {
	console.info(`Web Socket: Incoming Connection from ${wsRequest.socket.remoteAddress}:${wsRequest.socket.remotePort}`)
	wsClient.on("message", function (serializedRequest) {
		HandlePackets(serializedRequest, wsClient, wsRequest)
	})
	wsClient.on("close", (event) => {
		console.info(`Web Socket: Connection to ${wsRequest.socket.remoteAddress}:${wsRequest.socket.remotePort} Terminated!`)
	})
})
console.info(`Web Socket Running at http://${hostName}:${hostPort}`)
