---Writes Messages to terminal/monitor/window With Date and Time prefix.
---@param Message string
local function Write(Message)
	if string.len(Message) > 0 then
		local TimeDate = tostring(os.date("%t%d/%m/%Y %H:%M:%S%t"))
		local Debug = debug.getinfo(2, "Sln")
		local Name = tostring(Debug.name)
		--local Origin = string.sub(string.find(tostring(Debug.source), "[%a]+%.lua", 1, false))
		local Origin = string.sub(tostring(Debug.source),string.find(tostring(Debug.source), "[%a]+%.lua", 1, false))
		local Line = tostring(Debug.currentline)
		local Prefix = "[" .. TimeDate .. "] " .. Origin ..":" .. Line .. ": "
		local Rows = Wrap(Prefix .. Message, Monitor_Width)
		for _, Text in pairs(Rows) do
			print(Text)
		end
	end
end

local function Send(Message)
	if string.len(Message) > 0 then
		local Rows = Wrap(Message, 2000)
		for _, Text in pairs(Rows) do
			---@diagnostic disable-next-line: undefined-field
			os.queueEvent("Send", Text)
		end
	end
end

return Write, Send