---Connects to the Gateway.
local function Connect()
	Websocket.Close()
	http.websocketAsync(Gateway .. "?v=10&encoding=json")
	Attempting = true
end

return Connect