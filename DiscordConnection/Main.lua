local function Error_Tracking(Error)
	Write("ERROR: " .. Error)
	error(debug.traceback())
end
local function EventCollector()
	while true do
		---@diagnostic disable-next-line: undefined-field
		local Event = {os.pullEventRaw()}
		local Name = Event[1]
		local Timer = Event[2]
		if Event[1] == "terminate" then
			break
		end
		if Name == "websocket_success"
		or Name == "websocket_message"
		or Name == "websocket_closed"
		or Name == "timer" and Timer == HeartBeat_Timer
		or Name == "timer" and Timer == Status_Timer
		or Name == "Send"
		or Name == "Register_Commands"
		or Name == "terminate"
		or Name == "Setup_Rednet"
		or Name == "rednet_message" then
			table.insert(EventQueue, #EventQueue + 1, Event)
		end
	end
end
local function Main()
	while true do
		if not WS and not Attempting then
			Connect()
		else
			if #EventQueue > 0 then
				local EventData = table.remove(EventQueue, 1)
				local EventName = EventData[1]
				if EventName == "terminate" then
					Websocket.Close()
					Write("Terminating Script.")
					break
				elseif EventName == "websocket_success" then
					WS = EventData[3]
					Attempting = false
					Write("Websocket connected successfully.")
				elseif EventName == "websocket_failure" then
					WS_Error = EventData[3]
					WS = nil
					Attempting = false
					Write("Failed to connect to Websocket. Error: " .. WS_Error)
				elseif EventName == "websocket_message" then
					--EventData[3] = Data, EventData[4] = Binary.

					OpCodes(EventData[3])
				elseif EventName == "websocket_closed" then
					--EventData[2] = URL, EventData[3] = Reason or nil, EventData[4] = Error Code or nil. Note: Add this to also trigger a reconnect.

					local EventURL = EventData[2]
					local Error_Code = EventData[3]
					local Error_Message = EventData[4]
					Write('URL "' .. EventURL .. '" closed our connection. Error Code: ' .. tostring(Error_Code) .. ', Error Message: ' .. tostring(Error_Message))
					WS = nil
				elseif EventName == "timer" then
					--EventData[2] = Timer ID.

					local Timer = EventData[2]
					if Timer == HeartBeat_Timer then
						SendHeartbeat()
						---@diagnostic disable-next-line: undefined-field
						HeartBeat_Timer = os.startTimer(HeartBeat_interval)
					elseif Timer == Status_Timer then
						StatusUpdate()
						Write('New Status: "' .. Status .. '"')
						local Status_Payload = '{"op":3,"d":{"since":null,"activities":[{"type":4,"name":"Activity","state":"'..Status..'"}],"status":"online","afk":false}}'
						Websocket.Send(Status_Payload)
						---@diagnostic disable-next-line: undefined-field
						Status_Timer = os.startTimer(Status_Interval)
					end
				elseif EventName == "Send" then
					--EventData[2] = Message to Send to Discord.

					local Message_Body = textutils.serializeJSON({
						content = EventData[2],
						allowed_mentions = {
							parse = {}
						}
					})
					Write("Message Body: " .. Message_Body)
					--http.post("https://discord.com/api/v10/channels/" .. Channel_Write_ID .. "/messages", Message_Body, HTTP_Header, false)
				elseif EventName == "Register_Commands" then
					local Success, Error = xpcall(Commands.Register, Error_Tracking)
					if Success then
						Write("Successfully finished the register() function.")
						---@diagnostic disable-next-line: undefined-field
						os.queueEvent("Setup_Rednet")
						Write("Queued Setup Rednet Event.")
					else
						Write("Failed to finish the register function.")
						if Error ~= 'Discord says the Bot is lacking Permissions, make sure the Role has the following Permissions: "View Channels", "Manage Webhooks", "Read Message History" and "Use Application Commands". Note: Sometimes we do actually have permissions and Discord is just acting weird, in which case just restart the Bot.' then
							---@diagnostic disable-next-line: undefined-field
							os.reboot()
						end
					end
				elseif EventName == "Setup_Rednet" then
					rednet.open(peripheral.getName(Modem))
					Write("Rednet is Open: " .. tostring(rednet.isOpen()))
					---@diagnostic disable-next-line: undefined-field
					local Success, Error = pcall(function() rednet.host(Protocol, tostring(os.getComputerID())) end)
					if Success then
						Write('Now Hosting Protocol "' .. Protocol .. '"')
					else
						error('Failed to Host Protocol "' .. Protocol .. '", Error: ' .. Error)
					end
				elseif EventName == "rednet_message" then
					Write("Event: " .. textutils.serialize(EventData))
					---@type number
					local Sender = EventData[2]
					---@type table
					local Message = EventData[3]
					---@type string
					local Sender_Protocol = EventData[4]
					if Protocol == Sender_Protocol then
						if Message.Success then
							Write("Command Executed Successfully, Message: " .. Message.Message)
						else
							Write("Command failed to Execute, Reason: " .. Message.Message)
						end
						--PATCH https://discord.com/api/v10/webhooks/{application.id}/{interaction.token}/messages/@original
						http.request({
							url = "https://discord.com/api/v10/webhooks/" .. Application_ID .. "/" .. Message.Interaction,
							method = "POST",
							headers = {
								["Authorization"] = Bot_Token,
								["Content-Type"] = "application/json"
							},
							body = textutils.serializeJSON({
								content = "<@" .. Message.User .. "> " .. Message.Message
							})
						})
					end
				end
			else
				---@diagnostic disable-next-line: undefined-field
				os.sleep(0.05)
			end
		end
	end
end

return function() parallel.waitForAll(EventCollector, Main) end