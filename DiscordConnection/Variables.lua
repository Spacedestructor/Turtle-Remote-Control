---@type integer
Monitor_Width = 0
---@type integer
Monitor_Height = 0
---@type string
Gateway = nil
---@type string
Application_ID ="INSERT_APPLICATION_ID_HERE" --Lua srewed me here, turning it in to 1.2984354809745e+18 due to type conversion. So its a string now.
---@type string
Bot_Token = "Bot INSERT_TOKEN_HERE"
---@type table
HTTP_Header = {["Authorization"] = Bot_Token, ["User-Agent"] = "CC:T Bot", ["Content-Type"] = "application/json"}
---@type table
WS = nil
---@type string
WS_Error = nil
---@type number
HeartBeat_interval = nil
---@type integer
HeartBeat_Timer = nil
---@type integer
SequenceNumber = nil
---@type table
HeartBeat_Payload = {["op"] = 1, ["d"] = SequenceNumber}
---@type integer
Bot_Intent = 66560
---@type string
Resume_Gateway_URL = nil
---@type table
Guild = {
	ID = "687250381461520453",
	Available = false
}
---@type string
Channel_Read_ID = "INSERT_CHANNEL_ID_HERE"
---@type string
Channel_Read_Name = "INSERT_CHANNEL_NAME_HERE"
---@type string
Channel_Write_ID = "INSERT_CHANNEL_ID_HERE"
---@type string
Channel_Write_Name = "INSERT_CHANNEL_NAME_HERE"
---@type string
Session_ID = nil
---@type boolean
Received_ACK = true
---@type integer
Status_Timer = nil
---@type string
Owner_ID = "INSERT_OWNER_ID_HERE"
---@type string
Owner_Name = "INSERT_OWNER_NAME_HERE"
---@type string
Status = ""
---@type integer
Status_Interval = 60
---@type table
EventQueue = {}
---@type boolean
Attempting = false
---@type string
Protocol = "Discord"
---@type string
Discord_Int53 = "9007199254740991" --Stop forgetting about large numbers.