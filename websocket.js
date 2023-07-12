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
//if yes set web ui to last known info, if no keep web ui empty.
//in both cases update as the respective commands are used.
//a turtle should always start as an empty advanced turtle with wireless modem peripheral.
//all required items (fuel, tools etc.) should be either in the turtles inventory or in an adjecent inventory that the turtle can acess.
//Get Turtle Peripherals
//Set Profession
/*
function GetMaxFuelLevel() {}
function GetCurrentFuelLevel() {}
function Refuel() {}
function getInventory() {}

function GetHeight() {}

function Box() {}

function ParseBlockID(BlockID) {
	var parsed = {
		source : "",
		material : "",
		variant : ""
	}
	if (BlockID.includes(":") && BlockID("_")) {
		parsed.source = BlockID.slice(0, BlockID.indexOf(":")-1)
		return parsed
	}
	else {
		return "Invalid Block ID"
	}

}
*/
const hostname = "127.0.0.1"
const port = 3000
const socket = require("ws")

const WebServerIP = "127.0.0.1"
const WebServerPort = "3000"

var WebSocket = new socket.Server({ port: port })
var turtles = require("./Turtle.json")
//var computers = require("./ComputerData.json")
//var pockets = require("./PocketData.json")

function isJson(Paremeterstring, IP, Port) {
	var object
	var result = [
		string = false,
		object = false
	]
	try {
		var test = JSON.parse(Paremeterstring)
		console.info(`Web Socket: [${IP}:${Port}] ${Paremeterstring} is a json string!`)
		result.string = true
	} catch (error) {
		console.error(`Web Socket: [${IP}] ${Paremeterstring} is not a json string!`)
		result.string = false
	}
	if (!result.string) {
		try {
			var test = JSON.stringify(string)
			console.info(`Web Socket: [${IP}:${Port}] ${string} can be turned in to a json string!`)
			result.object = true
		} catch (error) {
			console.error(`Web Socket: [${IP}:${Port}] ${string} can not be turned in to a json string!`)
			result.object = false
		}
	}
	return result.string, result.object
}
WebSocket.on("connection", (WSClient) => {
	console.info(`Web Socket: Incoming Connection from ${WSClient._socket.remoteAddress}:${WSClient._socket.remotePort}`)
	WSClient.on("message", serializedrequest => {
		var IP = WSClient._socket.remoteAddress
		var Port = WSClient._socket.remotePort
		var JsonTestString, JsonTestObject = [isJson(serializedrequest, IP, Port)]
		var request
		if (JsonTestString) { request = JSON.parse(serializedrequest) }
		else if (JsonTestObject) { request = serializedrequest }
		else {console.error(`What?`)}
		console.error(request.type)
		switch (request.type) {
			case "GetProfession":
				Packet = { ["source"]: "server", ["destination"]: ID }
			case "GetProfession-Response":
			case "GetTurtleData":
				var ID = Number(request.data)
				var TurtleData = turtles[ID]
				console.log(TurtleData)
				if (JsonTestString) {
					Packet = JSON.parse(TurtleData)
				} else if (JsonTestObject) {
					Packet = TurtleData
				}
				WSClient.send(Packet)
			default:
				if (request.type != undefined) {
					console.error(`Unknown Packet Type: ${request.type}! ${serializedrequest}`)
				} else {
					console.error(`Unknown Packet structure: ${serializedrequest}`)
				}
				break
		}
		/*} else if (JsonTestObject){
			console.log(`Web Socket: [${IP}:${Port}] ${serializedrequest.toString()} is an Object!`)
		} else {
			console.log(`Web Socket: [${IP}:${Port}] What is ${serializedrequest} ?`)
		}*/
	})
	WSClient.on("close", (event) => {
		console.log(`Web Socket: Connection to ${IP}:${Port} Terminated!`)
	})
})
console.log(`Web Socket Running at http://${hostname}:${port}`)