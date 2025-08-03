---Sends Heartbeat to Discord, handling "null" value if Sequence Number is not set.
local function SendHeartbeat()
	Write("Sending Heartbeat.")
	SequenceNumber = SequenceNumber
	if SequenceNumber then
		Websocket.Send('{"op":1,"d":'..SequenceNumber..'}')
	else
		Websocket.Send('{"op":1,"d":null}')
	end
	if HeartBeat_Timer then
		---@diagnostic disable-next-line: undefined-field
		os.cancelTimer(HeartBeat_Timer)
	end
	---@diagnostic disable-next-line: undefined-field
	HeartBeat_Timer = os.startTimer(HeartBeat_interval)
end

return SendHeartbeat