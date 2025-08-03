---Will Resume an invalidated Session.
local function Resume()
	--Session_ID, Resume_Gateway_URL, SequenceNumber

	local Payload = {
		OP = 6,
		d = {
			token = Bot_Token,
			session_id = Session_ID,
			seq = SequenceNumber
		}
	}
	Websocket.send(Payload)
end
return Resume