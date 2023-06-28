const socket = require("ws")
const hostname = '127.0.0.1'
const port = 3000
const WebSocket = new socket.Server({port: port})
console.log(`Websocket Server Running at http://${hostname}:${port}`)
var clients=[]
var turtles = require("./TurtleData.json")
var computers = require("./ComputerData.json")
var pockets = require("./PocketData.json")
WebSocket.on("connection", WSClient => {
	console.log("Incoming Connection!")
	WSClient.on("message", serializedrequest => {
		var request
		if (typeof serializedrequest == "string") {
			request = JSON.parse(serializedrequest)
		} else {
			request = serializedrequest
		}
		var id = request.source
		switch (request.type) {
			case "self-request":
				console.debug(request)
				//console.log("Received Message Type " + JSON.stringify(request.type) + " from " + JSON.stringify(request.source) + " : " + JSON.stringify(request.data))
				var response = {["source"]:"server",["destination"]:id.toString(),["data"]:"",["type"]:"self-request-report"}
				var serializedresponse = JSON.stringify(response)
				WSClient.send(serializedresponse)
				console.info("Response Send: " + serializedresponse)
				break
			case "setup-notice":
				console.log(`Received Message Type ${request.type} from ${request.source}: ` + JSON.stringify(request.data))
				console.log(`${serializedrequest}`)
				var type = request.data[id].type
				var label = request.data[id].label
				var peripherals = [
					{
						"command":{
							"present":`${request.data[id].peripherals.command.present}`,
							"position":`${request.data[id].peripherals.command.position}`
						},
						"computer":{
							"present":`${request.data[id].peripherals.computer.present}`,
							"position":`${request.data[id].peripherals.computer.position}`
						},
						"drive":{
							"present":`${request.data[id].peripherals.drive.present}`,
							"position":`${request.data[id].peripherals.drive.position}`
						},
						"modem":{
							"present":`${request.data[id].peripherals.modem.present}`,
							"position":`${request.data[id].peripherals.modem.position}`
						}
					}
				]
				//clients.push()
				console.log(clients.toString())
				break
			default:
				if (request.type != undefined) {
					console.error(`Unknown Packet Type: ${request.type}! ${serializedrequest}`)
				}
				else{
					console.error(`Unknown Packet structure: ${serializedrequest}`)
				}
				break
		}
	})
	WSClient.on("close", () => {
		console.log("Connection Terminated!")
	})
})