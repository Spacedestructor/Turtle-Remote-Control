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
/*
Get Turtle Peripherals
Set Profession
function GetMaxFuelLevel() {}
function GetCurrentFuelLevel() {}
function Refuel() {}
function getInventory() {}
function GetHeight() {}
function Box() {}
function ParseBlockID(BlockID) { var parsed = { source : "", material : "", variant : ""} if (BlockID.includes(":") && BlockID("_")) { parsed.source = BlockID.slice(0, BlockID.indexOf(":")-1) return parsed} else {return "Invalid Block ID"}}
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

WebSocket.on("connection", (WSClient, WSRequest) => {
	console.info(`Web Socket: Incoming Connection from ${WSRequest.socket.remoteAddress}:${WSRequest.socket.remotePort}`)
	WSClient.on("message", serializedrequest => {
		var IP = WSClient._socket.remoteAddress
		var Port = WSClient._socket.remotePort
		var request = JSON.parse(serializedrequest)
		console.error(request)
		switch (request.type) {
			case "GetProfession":
				Packet = { ["source"]: "server", ["destination"]: ID }
				break
			case "GetProfession-Response":
				break
			case "GetTurtleData":
				var ID = Number(request.data)
				var TurtleData = turtles[ID]
				console.log(TurtleData)
				//WSClient.send(Packet)
				break
			default:
				if (request.type != undefined) {
					console.error(`Unknown Packet Type: ${request.type}! ${serializedrequest}`)
				} else {
					console.error(`Unknown Packet structure: ${serializedrequest}`)
				}
				break
		}
	})
	WSClient.on("close", (event) => {
		console.log(`Web Socket: Connection to ${IP}:${Port} Terminated!`)
	})
})
console.log(`Web Socket Running at http://${hostname}:${port}`)