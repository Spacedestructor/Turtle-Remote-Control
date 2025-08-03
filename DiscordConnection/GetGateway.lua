--Gets Discord's Gateway URL.
local function GetGateway()
	local Response = http.get("https://discord.com/api/gateway/bot", HTTP_Header, false)
	Gateway = textutils.unserializeJSON(Response.readAll()).url
	Write('Recieved Gatway URL "' .. Gateway .. '".')
end

return GetGateway