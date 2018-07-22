local serialization = require("serialization")
local component = require("component")
local event = require("event")

local PORT = 123

print("RPC Server v0.4")
print("Adress", component.modem.address)

if not component.modem.isOpen(PORT) then
    print("opening port "..tostring(PORT))
    if not component.modem.open(PORT) then error("open failed") end
end

while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    -- print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
    -- print(port, port)
    -- print(message)
    print(">"..from..":"..port)
    print(">"..tostring(message))
    
    local f = load(message)
    local status, err = pcall(f)
    print("<", status, err)
    -- print("status", status)
    -- print("err", err)
    if not status then
        local traceback = debug.traceback()
        -- print(debug.traceback())
        
        local msg = {status=status, err=err, traceback=traceback}
        component.modem.send(from, port, serialization.serialize(msg))
    else
        local msg = {status=status, result=err}
        component.modem.send(from, port, serialization.serialize(msg))
    end

end