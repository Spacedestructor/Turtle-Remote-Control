---Identifies the Bot to the Gateway.
local function Identify()
	local Identity = '{"op":2,"d":{"token":"'..Bot_Token..'","intents":'..Bot_Intent..',"properties":{"os":"linux","browser":"computercraft","device":"computercraft"}}}'
	Websocket.Send(Identity) --Response is the "READY" Event.
end

return Identify