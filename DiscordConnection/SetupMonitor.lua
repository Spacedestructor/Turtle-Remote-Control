---Sets up The Monitor.
local function SetupMonitor()
	Monitor.clear()
	Monitor.setCursorBlink(false)
	Monitor.setCursorPos(1, 1)
	Monitor.setTextColor(colors.white)
	Monitor.setBackgroundColor(colors.black)
	Monitor_Width, Monitor_Height = Monitor.getSize()
	term.redirect(Monitor)
	Write("Finished Setting up the Monitor.")
end

return SetupMonitor