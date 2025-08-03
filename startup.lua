---https://discord.com/oauth2/authorize?client_id=1298435480974528544
require("..DiscordConnection.Variables")
require("..DiscordConnection.Functions")
local Success, Result = pcall(function()
	---@diagnostic disable-next-line: undefined-field
	os.setComputerLabel("Discord Connection " .. os.getComputerID())
	SetupMonitor()
	Write("Please Terminate the script before shutting down the PC to clean up Websockets gracefully. Also please make sure to keep this Computer loaded at all Times. The first step is more about being nice and letting Discord know when we are done. But the second is to avoid Spamming Connects to the Server and Errors to the Bot whenever someone happens to come by this Machine and briefly loading it in.")
	Bot_Intent = Intents()
	GetGateway()
	---@diagnostic disable-next-line: undefined-field
	Status_Timer = os.startTimer(Status_Interval)
	--Main Loop after connecting, this will run all of the Event based Logic.
	Main()
end)
if not Success then
	Websocket.Close()
	if Result ~= "Terminated" then
		error("The Script has Terminated Early. Reason: " .. Result)
	end
end