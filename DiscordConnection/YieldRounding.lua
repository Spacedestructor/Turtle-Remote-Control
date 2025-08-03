---Rounds Numbers down to increments of 0.05 to comply with CC:T Yield function and Minecraft Game Ticks.
---@param Number number
---@param Mode string
---@return number | nil
---@nodiscard
local function YieldRounding(Number, Mode)
	assert(type(Number) == "number", 'Parameter "Number" must be of type "number"!')
	assert(Mode == "UP" or Mode == "DOWN", 'Parameter "Mode" must be a string of either "UP" or "DOWN"!')
	if Mode == "UP" then
		return math.ceil(Number * 20) / 20
	elseif Mode == "DOWN" then
		return math.floor(Number * 20) / 20
	end
end

return YieldRounding