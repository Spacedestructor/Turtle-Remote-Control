---Broadcasts a given Message
---@param Message string | table
local function broadcast(Message)
	if rednet.isOpen(peripheral.getName(Modem)) then
		rednet.broadcast(Message, Protocol)
	else
		rednet.open(peripheral.getName(Modem))
		broadcast(Message)
	end
end
return {Broadcast = broadcast}