---Self Written JSON Parser that inspects strings and returns the fields relevant for my bot.
---@param JSON string
local function Converter(JSON)
	---Turns stringified booleans to boolean type if its a case sensitive match.
	---@param string string
	local function ToBoolean(string)
		if string == "true" then
			return true
		elseif string == "false" then
			return false
		end
	end
	local Results = {}
	local OP_Start, OP_End = JSON:find('"op":[%d]+', 1, false)
	if OP_Start and OP_End then
		Results.OP = tonumber(JSON:sub(OP_Start + 5, OP_End))
		if Results.OP == 0 then
			local T_Start, T_End = JSON:find('"t":"[^"]+"', 1, false)
			Results.T = JSON:sub(T_Start + 5, T_End - 1)
			local S_Start, S_End = JSON:find('"s":[%d%a]+')
			local Number = JSON:sub(S_Start + 4, S_End)
			if Number ~= "null" then
				SequenceNumber = tonumber(Number)
			end
			if Results.T == "READY" then
				local Session_ID_Start, Session_ID_End = JSON:find('"session_id":"[^"]+"', 1, false)
				Results.Session_ID = JSON:sub(Session_ID_Start + 14, Session_ID_End - 1)
				local Resume_Gateway_URL_Start, Resume_Gateway_URL_End = JSON:find('"resume_gateway_url":"[^"]+"', 1, false)
				Results.Resume_Gateway_URL = JSON:sub(Resume_Gateway_URL_Start - 22, Resume_Gateway_URL_End - 1)
				Results.Guild = {}
				local ID_Start, ID_End = JSON:find('"id":"[^"]+"', 1, false)
				Results.Guild.ID = JSON:sub(ID_Start + 6, ID_End - 1)
				local Available_Start, Available_End = JSON:find('"unavailable":[%a]+')
				Results.Guild.Available = not ToBoolean(JSON:sub(Available_Start + 14, Available_End))
				Write("Handshake Completed successfully.")
			elseif Results.T == "GUILD_CREATE" or Results.T == "GUILD_UPDATE" or Results.T == "GUILD_DELETE" then
				Results.Guild = {}
				local ID_Start, ID_End = JSON:find('"id":"[^"]+"', 1, false)
				Results.Guild.ID = JSON:sub(ID_Start + 6, ID_End - 1)
				local Available_Start, Available_End = JSON:find('"unavailable":[%a]+')
				Results.Guild.Available = not ToBoolean(JSON:sub(Available_Start + 14, Available_End))
			elseif Results.T == "INTERACTION_CREATE" then
				local Meta = Commands.Metadata(JSON)
				Results.Interaction = Meta.Interaction --Interaction Metadata
				Results.Command = Meta.Command --Command Metadata
				Results.User = Meta.User --User Metadata
			elseif Results.T == "MESSAGE_CREATE" then
			elseif Results.T == "MESSAGE_UPDATE" then
			elseif Results.T == "MESSAGE_DELETE" then
			else
				Write("Unknown Dispatch " .. JSON)
				DebugToFile("Dispatch", JSON)
			end
		elseif Results.OP == 1 then --Heartbeat requested by discord. Doesnt contain any data we could capture outside of op, t, and s.
		elseif Results.OP == 7 then --Discord wants us to close connection and reconnect. Leaving this empty to avoid triggering an unknown Payload.
		elseif Results.OP == 9 then --Invalid session, "d" is a boolean saying if we can resume.
			local D_Start, D_End = JSON:find('"d":%a+')
			Results.D = JSON:sub(D_Start + 4, D_End)
		elseif Results.OP == 10 then
			local HeartBeat_Start, HeartBeat_End = JSON:find('"heartbeat_interval":[%d]+', 1, false)
			HeartBeat_interval = YieldRounding(tonumber(JSON:sub(HeartBeat_Start + 21, HeartBeat_End)) / 1000, "DOWN")
			Write("Recieved Hello Event by Discord! Expected Heart Beat Interval: " .. HeartBeat_interval)
		elseif Results.OP == 11 then -- We dont need any Data from the Heartbeat Payload but we include this so it wont show up as unknown Payload.
		else
			Write("Unknown Payload " .. JSON)
			DebugToFile("Payload", JSON)
		end
		return Results
	else
		error("Invalid Payload.")
	end
end

return Converter