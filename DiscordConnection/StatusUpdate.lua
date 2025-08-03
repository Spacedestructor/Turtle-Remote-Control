---Puts a semi random string in to "Status" with the guarantee that every call is a different String then the previous result.
local function StatusUpdate()
		local Options = {
			"Controlling Drones in Minecraft",
			"Help available via /help",
			"Listening to Commands in #" .. Channel_Read_Name .. " and talking in #" .. Channel_Write_Name,
			"Created by @" .. Owner_Name
		}
		local function Try()
			local success, result = pcall(function() return Options[math.random(1,#Options)]  end)
			if success and result ~= Status then
				Status = result
			else
				Try()
			end
		end
		Try()
end

return StatusUpdate