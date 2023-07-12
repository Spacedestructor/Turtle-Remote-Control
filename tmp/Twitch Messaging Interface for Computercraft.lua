-- Twitch Messaging Interface for ComputerCraft
-- By Anavrins
-- MIT License
-- Pastebin: https://pastebin.com/nve0x72X
-- Last updated: April 4 2022

-- Report any issues to Anavrins on https://forums.computercraft.cc/

-- Note: Avoid yielding in callbacks (read(), sleep() os.pullEvent())
-- Usage: The tick function will ingest events, run callbacks if needed, then return the event back
-- Use `local event = tmi.tick(os.pullEvent())` in your event loop

local tmi_url = "wss://irc-ws.chat.twitch.tv/"
local sessions = {}
local noop = function()end
local events = {
    ["websocket_success"] = true,
    ["websocket_message"] = true,
    ["websocket_closed"] = true,
    ["websocket_error"] = true
}

local function split(str, sep)
    local r = {}
    for i in str:gmatch(("([^%s]+)"):format(sep)) do
        r[#r+1] = i
    end
    return r
end

local escapeChar = {
    ["s"] = " ",
    ["n"] = "",
    [":"] = ";",
    ["r"] = " ",
}
local function unescape(msg)
    return msg:gsub("\\(.)", function(char)
        if escapeChar[char] then
            return escapeChar[char]
        end
    end)
end

local function parseIRC(line)
    local prefix, tags, ptags, trailing
    local lineStart = 1
    local params = {}

    if line:sub(1,1) == "@" then
        ptags = {}
        tags, line = line:match("@(%S+) (.+)")
        for _, seg in pairs(split(tags, ";")) do
            local key, value = seg:match("(.+)=(.+)")
            if key then
                local isNum = tonumber(value)
                if isNum then value = isNum
                else value = unescape(value)
                end
                ptags[key] = value
            end
        end
    end
    if line:sub(1,1) == ":" then
        local space = line:find(" ")
        prefix = line:sub(2, space-1)
        lineStart = space
    end
    local _, trailToken = line:find("%s+:", lineStart)
    local lineStop = line:len()
    if trailToken then
        trailing = line:sub(trailToken + 1)
        lineStop = trailToken - 2
    end
    local _, cmdEnd, cmd = line:find("(%S+)", lineStart)
    local pos = cmdEnd + 1
    while true do
        local _, stop, param = line:find("(%S+)", pos)
        if not param or stop > lineStop then
            break
        end
        pos = stop + 1
        params[#params + 1] = param
    end
    if trailing then
        params[#params + 1] = trailing
    end
    return prefix, cmd, params, ptags
end

local function connect(opts)
    local id = math.random(1000, 9999)

    opts.identity = opts.identity or {}
    opts.identity.username = opts.identity.username or ("justinfan" .. id)
    opts.identity.password = opts.identity.password or "kappa"
    opts.channels = opts.channels or {}
    opts.listeners = setmetatable({}, {["__index"] = function() return noop end})
    opts.isGuest = true

    local url = ("%s#T%04d"):format(tmi_url, id)
    sessions[url] = opts

    http.websocketAsync(url)

    sessions[url].listen = function(events, callback)
        if type(events) == "string" then events = {events} end
        for _, event in ipairs(events) do
            opts.listeners[event:upper()] = callback
        end
        return sessions[url]
    end
    sessions[url].disconnect = function()
        sessions[url].connected = false
        sessions[url].listeners.CLOSED("Disconnected")
        if sessions[url].handle then
            sessions[url].handle.close()
        end
    end
    sessions[url].sendMessage = function(channel, message)
        local channel = channel:lower()
        if not sessions[url].connected then
            return false, "Not connected to server"
        end
        if sessions[url].isGuest then
            return false, "Cannot send anonymous messages."
        end
        if not sessions[url].channels[channel] then
            return false, "Not connected to channel: " .. channel
        end
        sessions[url].handle.send("PRIVMSG #" .. channel .. " :" .. message)
        return true
    end
    sessions[url].sendAction = function(channel, action)
        return sessions[url].sendMessage(channel, ("\1ACTION %s\1"):format(action))
    end

    return sessions[url]
end

local function tick(...)
    local event, url, handle = ...
    if events[event] and sessions[url] then
        local session = sessions[url]
        local listeners = session.listeners

        if event == "websocket_success" then
            session.handle = handle
            session.connected = true
            handle.send("CAP REQ :twitch.tv/tags twitch.tv/commands")
            handle.send("PASS " .. session.identity.password)
            handle.send("NICK " .. session.identity.username)
            session.identity.password = nil
            for _, channel in ipairs(session.channels) do
                handle.send("JOIN #" .. channel:lower())
            end

        elseif event == "websocket_closed" then
            sessions[url].connected = false
            listeners.CLOSED("Websocket closed")

        elseif event == "websocket_failure" then
            sessions[url].connected = false
            listeners.FAILURE(handle)

        elseif event == "websocket_message" then
            local lines = split(handle, "\r\n")
            for _, line in ipairs(lines) do
                local ok, prefix, cmd, params, tags = pcall(parseIRC, line)

                if not ok then
                    listeners.ERROR(prefix)

                else
                    listeners.RAW(line)
                    listeners.PARSED(prefix, cmd, params, tags)

                    local channel = params[1] and params[1]:match("#?(.+)") or nil
                    local message = params[2]
                    if tags and tags["badges"] then
                        local badges = {}
                        for _, badge in pairs(split(tags["badges"], ",")) do
                            local name, level = badge:match("(.+)/(.+)")
                            badges[name] = tonumber(level) or level
                        end
                        tags["badges"] = badges
                    end

                    if tonumber(cmd) then
                        listeners[cmd](prefix, params, tags)

                    elseif cmd == "PING" then
                        session.handle.send("PONG :tmi.twitch.tv")
                        listeners.PING()

                    elseif cmd == "PRIVMSG" then
                        local username = tags and (tags["display-name"] or tags["login"]) or split(prefix, "!")[1]
                        local isSelf = tostring(username):lower() == session.identity.username:lower()
                        listeners.PRIVMSG(prefix, params, tags)

                        if username == "jtv" and message:find("hosting you") then
                            local name = split(message, " ")[1]
                            local autohost = message:find("auto")
                            listeners.HOSTED(channel, name, autohost, message)
                        else
                            local actionMessage = message:match("\1ACTION (.+)\1")
                            local msg = actionMessage and actionMessage or message

                            if tags["bits"] then
                                listeners.CHEER(channel, username, tags["bits"], message, tags)
                            else
                                if tags["msg-id"] then
                                    if tags["msg-id"] == "highlighted-message" or tags["msg-id"] == "skip-subs-mode-message" then
                                        listeners.REDEEM(channel, username, tags["msg-id"], message, tags)
                                    end
                                elseif tags["custom-reward-id"] then
                                    listeners.REDEEM(channel, username, tags["custom-reward-id"], message, tags)
                                end
                                if actionMessage then
                                    listeners.ACTION(channel, username, actionMessage, tags, isSelf)
                                else
                                    listeners.CHAT(channel, username, message, tags, isSelf)
                                end
                            end
                        end

                    elseif cmd == "WHISPER" then
                        local username = tags["display-name"] or tags["login"] or split(prefix, "!")[1]
                        listeners.WHISPER(username, message, tags)

                    elseif cmd == "USERNOTICE" then
                        local username = tags["display-name"] or tags["login"]
                        local tier = tonumber(tags["msg-param-sub-plan"]) and tags["msg-param-sub-plan"] / 1000 or tags["msg-param-sub-plan"]
                        local streak = tonumber(tags['msg-param-streak-months'] or 0)
                        local recipient = tags['msg-param-recipient-display-name'] or tags['msg-param-recipient-user-name']
                        local giftSubCount = tonumber(tags['msg-param-mass-gift-count'])
                        local msgId = tags and tags["msg-id"] or nil

                        if msgId == "sub" then listeners.SUB(channel, username, tier, message, tags)
                        elseif msgId == "resub" then listeners.RESUB(channel, username, streak, tier, message, tags)
                        elseif msgId == "subgift" then listeners.SUBGIFT(channel, username, streak, recipient, tier, tags)
                        elseif msgId == "anonsubgift" then listeners.ANONSUBGIFT(channel, streak, recipient, tier, tags)
                        elseif msgId == "submysterygift" then listeners.SUBMYSTERYGIFT(channel, username, giftSubCount, tier, tags)
                        elseif msgId == "primepaidupgrade" then listeners.PRIMEPAIDUPGRADE(channel, username, tier, tags)
                        elseif msgId == "anonsubmysterygift" then listeners.ANONSUBMYSTERYGIFT(channel, giftSubCount, tier, tags)
                        elseif msgId == "anongiftpaidupgrade" then listeners.ANONGIFTPAIDUPGRADE(channel, username, tags)

                        elseif msgId == "giftpaidupgrade" then
                            local gifter = tags['msg-param-sender-name'] or tags['msg-param-sender-login']
                            listeners.GIFTPAIDUPGRADE(channel, username, gifter, tags)

                        elseif msgId == "raid" then
                            local username = tags['msg-param-displayName'] or tags['msg-param-login']
                            local viewers = tonumber(tags['msg-param-viewerCount'])
                            listeners.RAID(channel, username, viewers, tags)

                        elseif msgId == "ritual" then
                            local ritualName = tags['msg-param-ritual-name']
                            if ritualName == "new_chatter" then listeners.NEWCHATTER(channel, username, message, tags) -- Or PRIVMSG tags["first-msg"] == 1
                            else listeners.RITUAL(channel, ritualName, username, message, tags)
                            end

                        else
                            listeners.USERNOTICE(channel, msgId, message, tags)
                        end

                    elseif cmd == "HOSTTARGET" then
                        local msgSplit = split(message, " ")
                        local viewers = tonumber(msgSplit[2]) or 0

                        if msgSplit[1] == "-" then listeners.UNHOST(channel, viewers)
                        else listeners.HOST(channel, msgSplit[1], viewers)
                        end

                    elseif cmd == "CLEARCHAT" then
                        local username = message

                        if #params > 1 then
                            local duration = tonumber(tags["ban-duration"])
                            if not duration then listeners.BAN(channel, username, tags)
                            else listeners.TIMEOUT(channel, username, duration, tags)
                            end
                        else listeners.CLEARCHAT(channel, tags)
                        end

                    elseif cmd == "CLEARMSG" then
                        if #params > 1 then
                            local username = tags["display-name"] or tags["login"]
                            listeners.CLEARMSG(channel, username, message, tags)
                        end

                    elseif cmd == "USERSTATE" then -- User settings in a channel
                        listeners.USERSTATE(channel, tags)

                    elseif cmd == "GLOBALUSERSTATE" then -- Global user settings
                        local username = tags["display-name"] or tags["login"]
                        session.username = username
                        session.isGuest = false
                        listeners.GLOBALUSERSTATE(username, tags)

                    elseif cmd == "ROOMSTATE" then
                        session.channels[channel:lower()] = true
                        local modes = {
                            ["followers-only"] = tags["followers-only"], -- In minutes, -1 = not in followers-mode
                            ["slow-mode"] = tags["slow"] ~= 0 and tags["slow"] or false, -- In seconds
                            ["subs-only"] = tags["subs-only"] ~= 0,
                            ["emote-only"] = tags["emote-only"] ~= 0,
                            ["r9k"] = tags["r9k"] ~= 0,
                            ["rituals"] = tags["rituals"] ~= 0
                        }
                        listeners.ROOMSTATE(channel, modes, tags)

                    elseif cmd == "NOTICE" then -- beefy event, mainly moderation responses, chat mode changes
                        listeners.NOTICE(channel, message, tags)

                    end
                end
            end
        end
    end

    return ...
end

return {
    connect = connect,
    tick = tick
}
