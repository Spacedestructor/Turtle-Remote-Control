---When given a Payload it will send it over the Websocket Connection.
---@param Payload string | table
local function send(Payload)
	if type(Payload) == "table" then
		Payload = textutils.serializeJSON(Payload)
		Write("Turned Payload of type table in to type " .. type(Payload) .. ", New Payload: " .. Payload)
	end
	local Success, Error = pcall(WS.send, Payload)
	if Success then
		Write("Message send Successfully.")
	else
		Write("Failed to send Message. Error: " .. Error)
	end
end
local function close()
	if WS then
		local Success, Error = pcall(WS.close)
		if Success then
			WS = nil
			EventQueue = {}
			Write("Closed Websocket connection.")
		else
			Write("Failed to close Websocket connection. Error: " .. Error)
		end
	end
end
return {Send = send, Close = close}