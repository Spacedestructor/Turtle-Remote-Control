local function Create()
	local Commands = {
		{
			type = 1,
			name = "bind",
			description = "Binds a Turtle to you, you can only have one Turtle at a Time.",
			options = {
				{
					type = 4,
					name = "id",
					description = "The ID of the Turtle you want to claim, will return an error if the turtle is already claimed.",
					required = true,
					min_value = 0,
					max_value = Discord_Int53
				}
			}
		},
		{
			type = 1,
			name = "release",
			description = "Releases your Turtle from its Binding.",
			options = {"Remove Me"}
		},
		{
			type = 1,
			name = "move", --names must match the regex ^[\w-]{1,32}$
			description = "Move your Turtle.",
			options = {
				{
					type = 3,
					name = "direction",
					description = "The Direction to move.",
					required = true,
					choices = {
						{
							name = "forward",
							value = "forward"
						},
						{
							name = "back",
							value = "back"
						},
						{
							name = "up",
							value = "up"
						},
						{
							name = "down",
							value = "down"
						}
					}
				}
			}
		},
		{
			type = 1,
			name = "turn",
			description = "Turn your Turtle",
			options = {
				{
					type = 3,
					name = "direction",
					description = "The direction to turn.",
					required = true,
					choices = {
					{
						name = "right",
						value = "right"
					},
					{
						name = "left",
						value = "left"
					}
				}
				}
			}
		},
		{
			type = 1,
			name = "inspect",
			description = "Inspect a block.",
			options = {
				{
					type = 3,
					name = "direction",
					description = "The direction to inspect.",
					required = true,
					choices = {
						{
							name = "forward",
							value = "forward"
						},
						{
							name = "up",
							value = "up"
						},
						{
							name = "down",
							value = "down"
						}
					}
				}
			}
		},
		{
			type = 1,
			name = "checkfuel",
			description = "Gets the Current and Total Fuel Levels of your Turtle.",
			options = {"Remove Me"} --"Remove Me" is a unique string which will automatically be removed from options, this method is done to force in to an empty array.
		}
	}
	local url = "https://discord.com/api/v10/applications/" .. Application_ID .. "/guilds/" .. Guild.ID .. "/commands"
	local JSON = textutils.serializeJSON(Commands)
	while true do
		local Start, End = string.find(JSON, "Remove Me", 1, true)
		if Start and End then
			JSON = string.sub(JSON, 1, Start - 2) .. string.sub(JSON, End + 2, string.len(JSON))
		else
			break
		end
	end
	Write("Attempting to Register Commands.")
	http.request({
		url = url,
		method = "PUT",
		headers = {
			["Authorization"] = Bot_Token,
			["Content-Type"] = "application/json"
		},
		body = JSON
	})
	local Response
	local Event
	while true do
		---@diagnostic disable-next-line: undefined-field
		Event = {os.pullEvent()}
		::RETRY::
		local Name, URL, Handle, Optional_Handle = Event[1], Event[2], Event[3], Event[4]
		if URL == url then
			if Name == "http_success" then
				Response = textutils.unserializeJSON(Handle.readAll())
				Handle.close()
				Write("Commands Registered Successfuly!")
				break
			elseif Name == "http_failure" then
				local Error = Optional_Handle and Optional_Handle.readAll() or "No Response."
				local Response_Handle = Error
				if Optional_Handle then
					Optional_Handle.close()
				end
				if Handle then
					local File = fs.open("/Command.json", "w")
					File.write(JSON)
					File.close()
					local Success, Result = pcall(textutils.unserializeJSON, Error)
					if Success then
						---@diagnostic disable-next-line: undefined-field
						Error = Result.message
						local Message = Result.message
						local Retry = Result.retry_after
						Write("Response:" .. Response_Handle)
						if Message == "Missing Access" then
							error('Discord says the Bot is lacking Permissions, make sure the Role has the following Permissions: "View Channels", "Manage Webhooks", "Read Message History" and "Use Application Commands". Note: Sometimes we do actually have permissions and Discord is just acting weird, in which case just restart the Bot.')
						elseif Error == "Invalid Form Body" then
							error("The Command " .. JSON .. " has an invalid Structure.")
						elseif Error == "Your are being rate limited." then
							local Time = YieldRounding(Retry, "UP")
							Write("Rate Limited to " .. Time .. " Seconds.")
							---@diagnostic disable-next-line: undefined-field
							os.sleep(Time)
							goto RETRY
						else
							Write("Command Register Encountered the Error: " .. Error)
							---@diagnostic disable-next-line: undefined-field
							os.sleep(1)
							goto RETRY
						end
					else
						error("Failed to unserialize Error.")
					end
				end
				break
			end
		end
	end
end
---Takes the JSON Payload from an INTERACTION_CREATE event and return relevant Fields.
---@param JSON string
---@return table
---@nodiscard
local function Get_Metadata(JSON)
	local _, Start = string.find(JSON, '"member":', 1, true)
	Start = Start + 1
	local Open, Close = 0, 0
	local End = Start
	local SubString = ""
	repeat
		End = End + 1
		SubString = JSON:sub(Start, End)
		local Open_Count = 0
		local Close_Count = 0
		for i = 1, SubString:len() do
	    	local Character = SubString:sub(i, i)
	    	if Character == '{' then
	    		Open_Count = Open_Count + 1
	    	elseif Character == '}' then
	    		Close_Count = Close_Count + 1
	    	end
	    end
	until  Open_Count > 0 and Open_Count == Close_Count
	local Data = textutils.unserializeJSON(SubString)
	local Other_Data = textutils.unserializeJSON(JSON:sub(1, Start - 10) .. JSON:sub(End + 2, JSON:len()))
		local Result = {
			User = { --User who used the Command
				Name = Data.user.username, --User Name
				ID = Data.user.id --User ID
			},
			Interaction = { --Interaction Metadata
				ID = Other_Data.d.id, --Interaction ID
				Token = Other_Data.d.token -- Interaction Token
			},
			Command = { --Data about the Command used
				Name = Other_Data.d.data.name, --Command Name
				Options = Other_Data.d.data.options -- Command Options
			}
	}
	return Result
end
return {Register = Create, Metadata = Get_Metadata}