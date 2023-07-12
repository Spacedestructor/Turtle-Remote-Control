const path = require("path");
const http = require("http")
const fs = require("fs")
const HOSTNAME = "127.0.0.1"
const PORT = 3001;

const MIME_TYPES = {
	default: "application/octet-stream",
	html: "text/html; charset=UTF-8",
	js: "application/javascript",
	css: "text/css",
	png: "image/png",
	jpg: "image/jpg",
	gif: "image/gif",
	ico: "image/x-icon",
	svg: "image/svg+xml",
	json: "application/json "
};

const STATIC_PATH = path.join(process.cwd(), "./");

const toBool = [() => true, () => false];

const prepareFile = async (url) => {
	const paths = [STATIC_PATH, url];
	if (url.endsWith("/")) paths.push("WebServer.html");
	const filePath = path.join(...paths);
	const pathTraversal = !filePath.startsWith(STATIC_PATH);
	const exists = await fs.promises.access(filePath).then(...toBool);
	const found = !pathTraversal && exists;
	const streamPath = found ? filePath : STATIC_PATH + "/404.html";
	const ext = path.extname(streamPath).substring(1).toLowerCase();
	const stream = fs.createReadStream(streamPath);
	return { found, ext, stream };
};

http.createServer(async (req, res) => {
	const file = await prepareFile(req.url);
	const statusCode = file.found ? 200 : 404;
	const mimeType = MIME_TYPES[file.ext] || MIME_TYPES.default;
	res.writeHead(statusCode, { "Content-Type": mimeType });
	file.stream.pipe(res);
	console.log(`Web Server: [${req.socket.remoteAddress}:${req.socket.remotePort}] ${req.method} ${req.url} ${statusCode}`);
})
	.listen(PORT, HOSTNAME);

console.log(`Web Server running at http://${HOSTNAME}:${PORT}/`);
