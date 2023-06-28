const http = require("http")
const fs = require("fs")

const hostname = "127.0.0.1"
const port = 3001

const server = http.createServer((req, res) => {
	res.writeHead(200, {"content-type": "text/html"})
	fs.createReadStream("server/webserver.html").pipe(res)
})

server.listen(port, hostname, () => {
	console.log("Web Server running at http://" + hostname + ":" + port + "/")
})

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