local serialization = require("serialization")
local component = require("component")
local event = require("event")

local rpc = {}

function rpc.version()
    return 1
end

function rpc.broadcast(cmd)
    if not component.modem.broadcast(PORT, cmd) then error("broadcast failed") end
    local _, _, from, port, _, message = event.pull("modem_message")
    print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
end

function rpc.call(addr, cmd)
    if not component.modem.send(addr, PORT, cmd) then error("broadcast failed") end
    local _, _, from, port, _, message = event.pull("modem_message")
    -- print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
    message = serialization.unserialize(message)
    if message.status then
        return message.result
    else
        print(message.stacktrace)
        error(message.err)
    end
end

return rpc