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
const hostName = "127.0.0.1"
const hostPort = 3000
const socket = require("ws")
var webSocket = new socket.Server({ host: hostName, port: hostPort })
var devices = require("./Devices.json")
const fs = require("fs")
const { assert } = require("console")
const { isNumberObject } = require("util/types")
//Parameter must be a File as string. Will return retrieved data without any further Processing.
function load_from_file(file) {
	try {
		var data = fs.readFileSync(file)
		return data
	} catch (error) {
		console.error("Error: ", error)
		throw error
	}
}
//First Parameter must be a File as String, Second Parameter must be the data to be saved. Wont do any further Processing before saving. Will return true if operation was successful.
function write_to_file(file, data) {
	try {
		fs.writeFileSync(file, data)
		return true
	} catch (error) {
		console.error("Error: ", error)
		throw error
	}
}
devices = load_from_file("Devices.json")
if (Object.keys(devices).length > 0) {
	devices = JSON.parse(devices)
	console.log("Web-socket: Device List loaded successfully! ", devices)
} else {
	console.log("Devices List Empty! ", devices)
}
var clients = []
//Creates a 128-bit value. Taken from https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
function create_UUID() {
	var dt = new Date().getTime();
	var uuid = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
		var r = (dt + Math.random() * 16) % 16 | 0;
		dt = Math.floor(dt / 16);
		return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
	});
	return uuid;
}
function check_client_existence(ip, port) {
	var index = 0
	if (Object.keys(clients).length > 0) {
		while (index <= Object.keys(clients).length - 1) {
			if (ip == clients[index].ip) {
				console.debug(clients[index])
				return clients[index]
			}
			index++
		}
		return false
	} else {
		return false
	}
}
function HandlePackets(serializedRequest, wsClient, wsRequest) {
	var request = JSON.parse(serializedRequest)
	var code = request.code
	var data = request.data
	switch (code) {
		case 100: //User lets us know it wants to be Identified.
			var ip = wsRequest.socket.remoteAddress
			var port = wsRequest.socket.remotePort
			var client = check_client_existence(ip, port)
			if (client == false) {
				//Example JSON: 0: { "ip": "127.0.0.1:3002", "type": "Client", "uuid": "example-uuid" }
				client = { ["uuid"]: create_UUID(), ["ip"]: ip, ["port"]: port }
				//console.debug("Client: ", client)
				clients.push(client)
				//console.debug("Clients: ", clients)
				var packet = { ["code"]: code, ["data"]: client }
				var serializedPacket = JSON.stringify(packet)
				wsClient.send(serializedPacket)
			} else {
				console.log(`Client has already registered as ${JSON.stringify(client)}!`)
				var packet = { ["code"]: code, ["data"]: client }
				var serializedPacket = JSON.stringify(packet)
				wsClient.send(serializedPacket)
			}
			break
		case 101: //User lets us know what Cookie in the Headers of this Connection has been Modified.
			console.error(`${code} not yet implemented!`)
			break
		case 199: //User lets us know it has disconnected.
			var remoteAddress = wsRequest.connection.remoteAddress
			var remotePort = wsRequest.connection.remotePort
			var uuid
			let i = 0
			while (i < clients.length) {
				var client = clients[i]
				if (client.ip == remoteAddress && client.port == remotePort) {
					uuid = clients[i].uuid
					//console.debug("Clients: ", clients)
					clients.splice(i, 1)
					//console.debug("Clients: ", clients)
				}
				i++
			}
			console.log("Client" + uuid + "from" + remoteAddress + ":" + remotePort + " has disconnected!")
			break
		case 300: //User lets us know what Twitch/Youtube/Other Platform Account they have logged in to. This will be Platform Name and UserID of the Platform.
			break
		case 301: //User is requesting all Data of all Devices it has access to.
			//console.debug(`Devices: `, devices)
			var packet = { ["code"]: code, ["data"]: devices }
			//console.debug("Packet: ", packet)
			var serializedPacket = JSON.stringify(packet)
			//console.debug("Serialized Packet: ", serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 302: //User is requesting all Data of a specific Device.
			//console.debug(`Device: `, devices[data])
			var packet = { ["code"]: code, ["data"]: devices[data] }
			//console.debug("Packet: ", packet)
			var serializedPacket = JSON.stringify(packet)
			//console.debug("Serialized Packet: ", serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 303: //User is requesting the Type of a specific Device.
			//console.debug(`Device Type: `, devices[data].type)
			var packet = { ["code"]: code, ["data"]: devices[data].type }
			//console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			//console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 304: //User is requesting the Label of a specific Device.
			console.debug(`Device Label: `, devices[data].label)
			var packet = { ["code"]: code, ["data"]: devices[data].label }
			console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 305: //User is requesting the Fuel of a specific Device.
			console.debug(`Device Fuel: `, devices[data].fuel)
			var packet = { ["code"]: code, ["data"]: devices[data].fuel }
			console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 306: //User is requesting the Modem of a specific Device.
			console.debug(`Device Modem: `, devices[data].modem)
			var packet = { ["code"]: code, ["data"]: devices[data].modem }
			console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 307: //User is requesting the Tool of a specific Device.
			console.debug(`Device Tool: `, devices[data].tool)
			var packet = { ["code"]: code, ["data"]: devices[data].tool }
			console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		case 308: //User is requesting the Braodcast Network of a specific Device.
			console.debug(`Device Broadcast Network: `, devices[data].broadcastNetwork)
			var packet = { ["code"]: code, ["data"]: devices[data].broadcastNetwork }
			console.debug(`Packet: `, packet)
			var serializedPacket = JSON.stringify(packet)
			console.debug(`Serialized Packet: `, serializedPacket)
			wsClient.send(serializedPacket)
			break
		default: //Logs all unknown Packet Codes and Structures.
			if (request.type != undefined) {
				console.error(`Unknown Packet Code: ${request.type}! ${serializedRequest}`)
			} else {
				console.error(`Unknown Packet Structure: ${serializedRequest}`)
			}
			break
	}
}
webSocket.on("connection", (wsClient, wsRequest) => {
	console.log(`Web-socket: Incoming Connection from ${wsRequest.socket.remoteAddress}:${wsRequest.socket.remotePort}`)
	wsClient.on("message", function (serializedRequest) {
		HandlePackets(serializedRequest, wsClient, wsRequest)
	})
	wsClient.on("close", (event) => {
		var result = false
		var counter = 0
		var uuid = ""
		while (!result) {
			if (clients[counter].ip == wsRequest.socket.remoteAddress && clients[counter].port == wsRequest.socket.remotePort) {
				uuid = clients[counter].uuid
				result = true
			}
		}
		console.log(`Web-socket: Connection to ${uuid} from ${wsRequest.socket.remoteAddress}:${wsRequest.socket.remotePort} Terminated!`)
	})
})
console.log(`Web-socket Running at http://${hostName}:${hostPort}`)