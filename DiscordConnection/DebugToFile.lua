local function DebugToFile(Type, JSON)
	if Type == "Dispatch" then
			local File = fs.open("/Dispatch.json", "w")
			File.write(JSON)
			error("Debugging unknown Dispatch Payload.")
		elseif Type == "Payload" then
			local File = fs.open("/Payload.json", "w")
			File.write(JSON)
			File.close()
			error("Debugging unknown Playload Type.")
		elseif Type == "Generic" then
			local File = fs.open("/Generic.json", "w")
			File.write(JSON)
			File.close()
			error("Debugging Generic JSON Payload.")
		end
end
return DebugToFile