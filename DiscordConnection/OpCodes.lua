local function OpCodes(JSON)
	local Data = Converter(JSON)
	assert(Data, "Received Invalid JSON " .. JSON)
	if Data.OP == 0 then
		if Data.T == "GUILD_CREATE" or Data.T == "GUILD_UPDATE" or Data.T == "GUILD_DELETE" then
			Guild.ID = Data.Guild.ID
			Guild.Available = Data.Guild.Available
		elseif Data.T == "READY" then
			Session_ID = Data.Session_ID
			Resume_Gateway_URL = Data.Resume_Gateway_URL
			---@diagnostic disable-next-line: undefined-field
			os.queueEvent("Register_Commands")
			Write("Queued Command Register Event.")
		elseif Data.T == "INTERACTION_CREATE" then
			Write("Received Command: " .. Data.Command.Name)
			local Deferred = textutils.serializeJSON({
				type = 5
			})
			http.request({
				url = "https://discord.com/api/v10/interactions/" .. Data.Interaction.ID .. "/" .. Data.Interaction.Token .. "/callback",
				method = "POST",
				headers = {
					["Content-Type"] = "application/json",
					["Authorization"] = Bot_Token,
					["Content-Length"] = tostring(Deferred:len())
				},
				body = Deferred
			})
			local User = Data.User
			Write("User: " .. textutils.serialize(User))
			local Command = Data.Command
			Write("Command: " .. textutils.serialize(Command))
			local Send = {Command = Command.Name, Interaction = Data.Interaction.Token}
			if Command.Name == "bind" then
				Write('User "' .. User.Name .. '" wants to bind Turtle #' .. Command.Options[1].value)
				Send.Target = Command.Options[1].value
				Send.Value = User.ID
			elseif Command.Name == "release" then
				Write('User "' .. User.Name .. '" wants to release there Turtle')
				Send.Target = User.ID
				Send.Value = "" --This has no option value and technically the field is redudant but we include it anyways for consistency.
			elseif Command.name == "move" then
				Send.Target = User.ID
				Send.Value = Command.Options[1].value
			elseif Command.name == "turn" then
				Send.Target = User.ID
				Send.Value = Command.Options[1].value
			elseif Command.name == "inspect" then
				Send.Target = User.ID
				Send.Value = Command.Options[1].value
			elseif Command.name == "checkfuel" then
				Send.Target = User.ID
				Send.Value = "" --This has no option value and technically the field is redudant but we include it anyways for consistency.
			end
			Write("Broadcasting " .. textutils.serialize(Send))
			RedNet.Broadcast(Send)
		elseif Data.T == "MESSAGE_CREATE" then	--We dont want to interact with messages, so leaving this empty to stop unknown Dispatch.
		elseif Data.T == "MESSAGE_UPDATE" then	--That holds true for all Message events, we dont react to normal messages.
		elseif Data.T == "MESSAGE_DELETE" then	--Tho using the Delete event for the Bot to also delete its related messages might be Neat.
		else
			Write("Unknown Dispatch Received: " .. JSON)
			DebugToFile("Dispatch", JSON)
		end
	elseif Data.OP == 1 then
		Write("Discord is requesting a Heartbeat.")
		SendHeartbeat()
	elseif Data.OP == 7 then --Discord wants us to Reconnect by closing connection and opening a new one.

		Connect()
	elseif Data.OP == 9 then --Invalid Session, "D" is a boolean saying if we can Resume or need a full Restart.
		if Data.D then
			error("Data: " .. textutils.serialize(Data))
			Resume()
		else
			Identify()
		end
	elseif Data.OP == 10 then
		SendHeartbeat()
		Identify()
	elseif Data.OP == 11 then
		Received_ACK = true
		Write("Discord acknowledged our Heartbeat.")
	else
		Write("Unknown Payload " .. JSON)
		DebugToFile("Payload", JSON)
	end
end

return OpCodes