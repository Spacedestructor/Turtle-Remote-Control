-- Usage: > twitch_chat.lua <channel1> <channel2> <channel3> ...

local tmi = require("tmi") -- https://pastebin.com/nve0x72X

local Client = tmi.connect({
    -- identity = { -- Optional
    --     username = "YourUserName",
    --     password = "oauth:token"
    -- },
    channels = { ... }, -- List of channels to connect to
})

local function writeCol(dev, color, text)
    dev.setTextColor(color)
    dev.write(text)
end

-- Emitted when joining a chat
Client.listen("ROOMSTATE", function(channel, modes, tags)
    writeCol(term, colors.white, "Joined ")
    writeCol(term, colors.magenta, channel)
    writeCol(term, colors.white, "'s chat")
    print()
end)

-- Emitted every chat message
Client.listen("CHAT", function(channel, username, message, tags, isSelf)
    if #Client.channels > 1 then
	    writeCol(term, colors.magenta, "#" .. channel)
	    writeCol(term, colors.white, " - ")
    end
    writeCol(term, colors.orange, username)
    writeCol(term, colors.white, ": ")
    print(message)
end)

while true do
    local event, key = tmi.tick(os.pullEventRaw())
    if event == "terminate" then
        Client.disconnect()
        break
    end
end

-- List of event callbacks
--- "ACTION" -> function(channel, username, actionMessage, tags, isSelf)
--- "ANONGIFTPAIDUPGRADE" -> function(channel, username, tags)
--- "ANONSUBGIFT" -> function(channel, streak, recipient, tier, tags)
--- "ANONSUBMYSTERYGIFT" -> function(channel, giftSubCount, tier, tags)
--- "BAN" -> function(channel, username, tags)
--- "CHAT" -> function(channel, username, message, tags, isSelf)
--- "CHEER" -> function(channel, username, bits, message, tags)
--- "CLEARCHAT" -> function(channel, tags)
--- "CLOSED" -> function(reason)
--- "FAILURE" -> function(reason)
--- "GIFTPAIDUPGRADE" -> function(channel, username, gifter, tags)
--- "GLOBALUSERSTATE" -> function(username, tags)
--- "HOST" -> function(channel, target, viewers)
--- "HOSTED" -> function(channel, name, autohost)
--- "MESSAGEDELETED" -> function(channel, username, message, tags)
--- "NEWCHATTER" -> function(channel, username, message, tags)
--- "NOTICE" -> function(channel, message, tags)
--- "PING" -> function()
--- "PRIMEPAIDUPGRADE" -> function(channel, username, tier, tags)
--- "RAID" -> function(channel, username, viewers, tags)
--- "RAW" -> function(line)
--- "REDEEM" -> function(channel, username, reward_id, message, tags)
--- "RESUB" -> function(channel, username, streak, tier, message, tags)
--- "RITUAL" -> function(channel, ritualName, username, message, tags)
--- "ROOMSTATE" -> function(channel, modes, tags)
--- "SUB" -> function(channel, username, tier, message, tags)
--- "SUBGIFT" -> function(channel, username, streak, recipient, tier, tags)
--- "SUBMYSTERYGIFT" -> function(channel, username, giftSubCount, tier, tags)
--- "TIMEOUT" -> function(channel, username, duration, tags)
--- "UNHOST" -> function(channel, viewers)
--- "USERNOTICE" -> function(channel, msgId, message, tags)
--- "USERSTATE" -> function(channel, tags)
--- "WHISPER" -> function(username, message, tags)